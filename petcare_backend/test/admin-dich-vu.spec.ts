import { BadRequestException, ConflictException } from '@nestjs/common';
import { ServiceType } from '../generated/prisma/enums';
import { AdminServicesReadService } from '../src/modules/admin/services/admin-services-read.service';
import { AdminServicesWriteService } from '../src/modules/admin/services/admin-services-write.service';
import {
  doiBangGia,
  thieuDeBat,
} from '../src/modules/admin/services/rang-buoc-dich-vu';
import { NhatKyQuanTriService } from '../src/modules/admin/chung/nhat-ky-quan-tri.service';
import { PrismaService } from '../src/prisma/prisma.service';

type BanGhi = Record<string, unknown>;

function nhanhTransaction(prisma: BanGhi) {
  return (lenh: unknown) =>
    typeof lenh === 'function'
      ? (lenh as (db: unknown) => Promise<unknown>)(prisma)
      : Promise.resolve(lenh);
}

const GIA_DAT_DU = {
  priceByDuration: { 30: 100000, 60: 160000 },
  additionalPetFee: 40000,
  maxPets: 3,
};

const GIA_GROOMING_DU = {
  priceByPackage: { bath: { duoi5: 180000 } },
  durationByPackage: { bath: { duoi5: 60 } },
  maxPets: 1,
};

describe('Cửa bật một dịch vụ, mở lại từ trang quản trị đi đúng cửa đó', () => {
  it('dắt khai đủ hai mức thời lượng và phụ phí thì qua', () => {
    expect(thieuDeBat(doiBangGia(ServiceType.WALKING, GIA_DAT_DU))).toBeNull();
  });

  it('dắt thiếu giá mức 60 phút thì chặn, câu báo nói đúng mức thiếu', () => {
    const gia = doiBangGia(ServiceType.WALKING, {
      ...GIA_DAT_DU,
      priceByDuration: { 30: 100000 },
    });

    expect(thieuDeBat(gia)).toMatchObject({ code: 'BANG_GIA_CHUA_DU' });
    expect(thieuDeBat(gia)?.message).toContain('60');
  });

  it('nhận từ 2 bé mà bỏ trống phụ phí bé thêm thì chặn', () => {
    const gia = doiBangGia(ServiceType.WALKING, {
      ...GIA_DAT_DU,
      additionalPetFee: null,
    });

    expect(thieuDeBat(gia)).toMatchObject({ code: 'BANG_GIA_CHUA_DU' });
  });

  it('chưa khai số bé tối đa mỗi đơn thì chặn trước mọi kiểm tra khác', () => {
    const gia = doiBangGia(ServiceType.BOARDING, { pricePerDay: 320000 });

    expect(thieuDeBat(gia)?.message).toContain('số bé tối đa');
  });

  it('trông giữ có số bé mỗi đơn vượt sức chứa đã khai thì chặn', () => {
    const gia = doiBangGia(ServiceType.BOARDING, {
      pricePerDay: 320000,
      capacity: 2,
      additionalPetFee: 50000,
      maxPets: 4,
    });

    expect(thieuDeBat(gia)?.message).toContain('sức chứa');
  });

  it('dắt khai quá 5 bé mỗi đơn thì chặn (bộ luật mục 1)', () => {
    const gia = doiBangGia(ServiceType.WALKING, {
      ...GIA_DAT_DU,
      maxPets: 10,
    });

    expect(thieuDeBat(gia)?.message).toContain('5 bé');
  });

  it('grooming thời lượng lẻ trong khoảng vẫn qua', () => {
    const gia = doiBangGia(ServiceType.GROOMING, {
      ...GIA_GROOMING_DU,
      durationByPackage: { bath: { duoi5: 100 } },
    });

    expect(thieuDeBat(gia)).toBeNull();
  });

  it('grooming ô giá nào có giá thì phải có thời lượng đi kèm', () => {
    const gia = doiBangGia(ServiceType.GROOMING, {
      ...GIA_GROOMING_DU,
      durationByPackage: {},
    });

    expect(thieuDeBat(gia)?.message).toContain('thời lượng');
  });

  it.each([20, 245])(
    'grooming thời lượng %i phút nằm ngoài khoảng cho phép thì chặn',
    (phut) => {
      const gia = doiBangGia(ServiceType.GROOMING, {
        ...GIA_GROOMING_DU,
        durationByPackage: { bath: { duoi5: phut } },
      });

      expect(thieuDeBat(gia)).toMatchObject({ code: 'BANG_GIA_CHUA_DU' });
    },
  );

  it('grooming khai một ô giá hợp lệ là đủ để bật', () => {
    expect(
      thieuDeBat(doiBangGia(ServiceType.GROOMING, GIA_GROOMING_DU)),
    ).toBeNull();
  });
});

describe('Bảng giá đọc ra API luôn là số nguyên đồng', () => {
  it('số lẻ lọt vào cột Json thì cắt xuống, không làm tròn lên', () => {
    const gia = doiBangGia(ServiceType.BOARDING, {
      pricePerDay: 320000.6,
      capacity: 4,
      additionalPetFee: 49999.4,
      maxPets: 2,
    });

    expect(gia).toMatchObject({ pricePerDay: 320000, additionalPetFee: 49999 });
  });

  it('ô giá không phải số hoặc bằng 0 thì bỏ hẳn chứ không hiện 0 đồng', () => {
    const gia = doiBangGia(ServiceType.WALKING, {
      priceByDuration: { 30: 0, 60: 'nhieu' },
      maxPets: 1,
    });

    expect(gia).toMatchObject({ type: 'WALKING', priceByDuration: {} });
  });
});

function dungCauHinh(dangBat: boolean, pricing: unknown) {
  const nhatKy: BanGhi[] = [];
  const daDoi: BanGhi[] = [];
  const prisma: BanGhi = {
    sitterService: {
      findUnique: () =>
        Promise.resolve({
          id: 'ss-1',
          sitterId: 'ncc-1',
          type: ServiceType.WALKING,
          enabled: dangBat,
          pricing,
          sitter: { user: { fullName: 'Đặng Khắc Duy' } },
        }),
      updateMany: (arg: { data: BanGhi }) => {
        daDoi.push(arg.data);
        return Promise.resolve({ count: 1 });
      },
    },
    adminAuditLog: {
      create: (arg: { data: BanGhi }) => {
        nhatKy.push(arg.data);
        return Promise.resolve({ id: 'log-1' });
      },
    },
  };
  prisma.$transaction = nhanhTransaction(prisma);

  const service = new AdminServicesWriteService(
    prisma as unknown as PrismaService,
    new NhatKyQuanTriService(prisma as unknown as PrismaService),
  );
  return { service, nhatKy, daDoi };
}

describe('Khoá và mở lại một cấu hình giá', () => {
  it('khoá thì đổi cột và ghi nhật ký trong cùng một lượt', async () => {
    const { service, nhatKy, daDoi } = dungCauHinh(true, GIA_DAT_DU);

    const ket = await service.datBat(
      'ss-1',
      false,
      'Bảng giá sai mức 60 phút',
      'admin-1',
    );

    expect(ket).toEqual({ id: 'ss-1', enabled: false });
    expect(daDoi[0]).toEqual({ enabled: false });
    expect(nhatKy[0]).toMatchObject({
      action: 'KHOA_CAU_HINH_DICH_VU',
      targetType: 'SITTER',
      targetId: 'ncc-1',
      targetCode: 'Đặng Khắc Duy',
      reason: 'Bảng giá sai mức 60 phút',
      newValue: 'WALKING=false',
    });
  });

  it('mở lại cấu hình còn thiếu giá thì chặn, không ghi gì', async () => {
    const { service, nhatKy, daDoi } = dungCauHinh(false, {
      priceByDuration: { 30: 100000 },
      maxPets: 1,
    });

    await expect(
      service.datBat('ss-1', true, 'Người chăm đã sửa xong', 'admin-1'),
    ).rejects.toThrow(BadRequestException);
    expect(daDoi).toHaveLength(0);
    expect(nhatKy).toHaveLength(0);
  });

  it('mở lại cấu hình đã khai đủ thì ghi đúng mã hành động', async () => {
    const { service, nhatKy } = dungCauHinh(false, GIA_DAT_DU);

    await service.datBat('ss-1', true, 'Người chăm đã sửa xong', 'admin-1');

    expect(nhatKy[0]).toMatchObject({
      action: 'MO_CAU_HINH_DICH_VU',
      oldValue: 'WALKING=false',
      newValue: 'WALKING=true',
    });
  });

  it('bấm khoá lần hai trên cấu hình đang tắt thì chặn', async () => {
    const { service, daDoi } = dungCauHinh(false, GIA_DAT_DU);

    await expect(
      service.datBat('ss-1', false, 'Khoá lại lần nữa', 'admin-1'),
    ).rejects.toThrow(ConflictException);
    expect(daDoi).toHaveLength(0);
  });

  it('không tìm thấy cấu hình thì trả đúng mã lỗi', async () => {
    const prisma: BanGhi = {
      sitterService: { findUnique: () => Promise.resolve(null) },
    };
    const service = new AdminServicesWriteService(
      prisma as unknown as PrismaService,
      new NhatKyQuanTriService(prisma as unknown as PrismaService),
    );

    await expect(
      service.datBat('ss-9', false, 'Bảng giá sai', 'admin-1'),
    ).rejects.toMatchObject({
      response: { code: 'KHONG_TIM_THAY_CAU_HINH' },
    });
  });
});

function dungDanhMuc() {
  const nhatKy: BanGhi[] = [];
  const daGhi: BanGhi[] = [];
  const prisma: BanGhi = {
    service: {
      findUnique: () => Promise.resolve({ name: 'Dắt đi dạo' }),
      upsert: (arg: { create: BanGhi; update: BanGhi }) => {
        daGhi.push(arg.update);
        return Promise.resolve({
          id: 'sv-1',
          type: ServiceType.WALKING,
          name: arg.update.name,
          description: arg.update.description,
        });
      },
    },
    adminAuditLog: {
      create: (arg: { data: BanGhi }) => {
        nhatKy.push(arg.data);
        return Promise.resolve({ id: 'log-1' });
      },
    },
  };
  prisma.$transaction = nhanhTransaction(prisma);

  const service = new AdminServicesWriteService(
    prisma as unknown as PrismaService,
    new NhatKyQuanTriService(prisma as unknown as PrismaService),
  );
  return { service, nhatKy, daGhi };
}

describe('Sửa danh mục chỉ chạm tên và mô tả', () => {
  it('không có đường nào ghi giá hay thời lượng vào bảng danh mục', async () => {
    const { service, daGhi } = dungDanhMuc();

    await service.suaDanhMuc(
      ServiceType.WALKING,
      { name: 'Dắt chó đi dạo' },
      'admin-1',
    );

    expect(Object.keys(daGhi[0]).sort()).toEqual(['description', 'name']);
    expect(daGhi[0]).toEqual({ name: 'Dắt chó đi dạo', description: null });
  });

  it('ghi nhật ký kèm tên trước và sau', async () => {
    const { service, nhatKy } = dungDanhMuc();

    await service.suaDanhMuc(
      ServiceType.WALKING,
      { name: 'Dắt chó đi dạo', description: 'Có GPS suốt buổi' },
      'admin-1',
    );

    expect(nhatKy[0]).toMatchObject({
      action: 'CAP_NHAT_DANH_MUC_DICH_VU',
      targetType: 'SETTING',
      targetCode: 'WALKING',
      oldValue: 'Dắt đi dạo',
      newValue: 'Dắt chó đi dạo',
    });
  });
});

describe('Danh mục luôn hiện đủ ba loại dịch vụ', () => {
  it('loại chưa có đơn nào thì tên để trống và đếm bằng 0', async () => {
    const prisma: BanGhi = {
      service: {
        findMany: () =>
          Promise.resolve([
            {
              id: 'sv-1',
              type: ServiceType.WALKING,
              name: 'Dắt đi dạo',
              description: null,
            },
          ]),
      },
      sitterService: {
        groupBy: () =>
          Promise.resolve([
            { type: ServiceType.WALKING, _count: { _all: 12 } },
          ]),
      },
    };
    const service = new AdminServicesReadService(
      prisma as unknown as PrismaService,
    );

    const ket = await service.danhMuc();

    expect(ket.items).toHaveLength(3);
    expect(ket.items[0]).toEqual({
      id: 'sv-1',
      type: ServiceType.WALKING,
      name: 'Dắt đi dạo',
      description: null,
      enabledSitterCount: 12,
    });
    expect(ket.items[1]).toMatchObject({
      id: null,
      name: null,
      enabledSitterCount: 0,
    });
  });
});

describe('Danh sách cấu hình giá', () => {
  it('chỉ trả tên người chăm, không kèm trường riêng tư nào', async () => {
    let daChon: BanGhi = {};
    const prisma: BanGhi = {
      sitterService: {
        count: () => Promise.resolve(1),
        findMany: (arg: { select: BanGhi }) => {
          daChon = arg.select;
          return Promise.resolve([
            {
              id: 'ss-1',
              sitterId: 'ncc-1',
              type: ServiceType.BOARDING,
              enabled: true,
              petKind: 'BOTH',
              pricing: { pricePerDay: 320000.4, capacity: 4, maxPets: 1 },
              updatedAt: new Date('2026-08-02T02:00:00Z'),
              sitter: { user: { fullName: 'Lý Mai Phương' } },
            },
          ]);
        },
      },
    };
    const service = new AdminServicesReadService(
      prisma as unknown as PrismaService,
    );

    const ket = await service.cauHinh({ page: 1, limit: 8 });

    expect(ket).toMatchObject({ total: 1, page: 1, limit: 8 });
    expect(ket.items[0]).toMatchObject({
      sitterName: 'Lý Mai Phương',
      pricing: { type: 'BOARDING', pricePerDay: 320000, maxPets: 1 },
    });
    const nguoiCham = daChon.sitter as { select: { user: { select: BanGhi } } };
    expect(Object.keys(nguoiCham.select.user.select)).toEqual(['fullName']);
  });
});
