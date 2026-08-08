import { BadRequestException, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../src/prisma/prisma.service';
import { NhatKyQuanTriService } from '../src/modules/admin/chung/nhat-ky-quan-tri.service';
import {
  kepTrang,
  MOI_TRANG_MAC_DINH,
  TRAN_MOI_TRANG,
} from '../src/modules/admin/chung/phan-trang';
import { chonChieu, chonCot } from '../src/modules/admin/chung/sap-xep';
import { AdminUsersReadService } from '../src/modules/admin/users/admin-users-read.service';
import { AdminUsersWriteService } from '../src/modules/admin/users/admin-users-write.service';
import { COT_SAP_XEP_NGUOI_DUNG } from '../src/modules/admin/users/dto/loc-nguoi-dung.dto';
import { nhanTuoi } from '../src/modules/admin/users/admin-users.mapper';

const ADMIN_ID = 'admin-1';

type LoiGoi = {
  where?: unknown;
  take?: number;
  skip?: number;
  orderBy?: unknown;
};

function prismaGia(
  nguoiDung: Record<string, unknown> | null = null,
  soDonDangChay = 0,
  soDongDoi = 1,
) {
  const loiGoi: LoiGoi[] = [];
  const nhatKy: Array<Record<string, unknown>> = [];
  const daCapNhat: Array<Record<string, unknown>> = [];
  const locDon: LoiGoi[] = [];
  const prisma = {
    loiGoi,
    nhatKy,
    daCapNhat,
    locDon,
    booking: {
      count: (arg: LoiGoi) => {
        locDon.push(arg);
        return Promise.resolve(soDonDangChay);
      },
    },
    user: {
      count: () => Promise.resolve(0),
      findMany: (arg: LoiGoi) => {
        loiGoi.push(arg);
        return Promise.resolve([]);
      },
      findUnique: () => Promise.resolve(nguoiDung),
      updateMany: (arg: Record<string, unknown>) => {
        daCapNhat.push(arg);
        return Promise.resolve({ count: soDongDoi });
      },
      // Lối KHÔNG kẹp trạng thái cũ, để gỡ bản vá ra là test đỏ vì nhật ký thừa dòng
      update: (arg: Record<string, unknown>) => {
        daCapNhat.push(arg);
        return { __lenh: 'update' };
      },
    },
    pet: {
      findUnique: () => Promise.resolve(nguoiDung),
      updateMany: (arg: Record<string, unknown>) => {
        daCapNhat.push(arg);
        return Promise.resolve({ count: soDongDoi });
      },
      // Lối KHÔNG kẹp trạng thái cũ, để gỡ bản vá ra là test đỏ vì nhật ký thừa dòng
      update: (arg: Record<string, unknown>) => {
        daCapNhat.push(arg);
        return { __lenh: 'update' };
      },
    },
    adminAuditLog: {
      create: (arg: { data: Record<string, unknown> }) => {
        nhatKy.push(arg.data);
        return { __lenh: 'audit' };
      },
    },
    $transaction: (lenh: unknown) =>
      typeof lenh === 'function'
        ? (lenh as (db: unknown) => Promise<unknown>)(prisma)
        : Promise.resolve(lenh),
  };
  return prisma;
}

function dungServiceGhi(
  nguoiDung: Record<string, unknown> | null,
  soDonDangChay = 0,
  soDongDoi = 1,
) {
  const prisma = prismaGia(nguoiDung, soDonDangChay, soDongDoi);
  const service = new AdminUsersWriteService(
    prisma as unknown as PrismaService,
    new NhatKyQuanTriService(prisma as unknown as PrismaService),
  );
  return { prisma, service };
}

describe('Phân trang chung của trang quản trị', () => {
  it('không có tham số thì lấy mặc định', () => {
    expect(kepTrang()).toEqual({
      trang: 1,
      moiTrang: MOI_TRANG_MAC_DINH,
      boQua: 0,
    });
  });

  it('vượt trần thì kẹp về trần chứ không báo lỗi', () => {
    expect(kepTrang(2, 5000).moiTrang).toBe(TRAN_MOI_TRANG);
  });

  it('trang nhỏ hơn 1 vẫn về trang đầu', () => {
    expect(kepTrang(0, 10)).toEqual({ trang: 1, moiTrang: 10, boQua: 0 });
  });

  it('bỏ qua đúng số dòng của trang trước', () => {
    expect(kepTrang(3, 10).boQua).toBe(20);
  });
});

describe('Whitelist cột sắp xếp', () => {
  it('tên cột lạ rơi về cột mặc định', () => {
    expect(chonCot(COT_SAP_XEP_NGUOI_DUNG, 'passwordHash', 'createdAt')).toBe(
      'createdAt',
    );
  });

  it('tên cột trong whitelist thì giữ nguyên', () => {
    expect(chonCot(COT_SAP_XEP_NGUOI_DUNG, 'fullName', 'createdAt')).toBe(
      'fullName',
    );
  });

  it('chiều lạ rơi về chiều mặc định', () => {
    expect(chonChieu('drop table', 'desc')).toBe('desc');
    expect(chonChieu('asc', 'desc')).toBe('asc');
  });
});

describe('Danh sách người dùng', () => {
  const service = () => {
    const prisma = prismaGia();
    return {
      prisma,
      service: new AdminUsersReadService(prisma as unknown as PrismaService),
    };
  };

  it('không lấy quá trần dù query xin nhiều hơn', async () => {
    const { prisma, service: doc } = service();
    await doc.danhSach({ limit: 999 });
    expect(prisma.loiGoi[0].take).toBe(TRAN_MOI_TRANG);
  });

  it('lọc tỉnh bắt cả địa chỉ mặc định lẫn hồ sơ người chăm', async () => {
    const { prisma, service: doc } = service();
    await doc.danhSach({ province: 'Hà Nội' });
    const where = prisma.loiGoi[0].where as {
      AND: [{ OR: unknown[] }];
    };
    expect(where.AND[0].OR).toEqual([
      { addresses: { some: { isDefault: true, province: 'Hà Nội' } } },
      { sitter: { is: { province: 'Hà Nội' } } },
    ]);
  });

  it('lọc ngày tính hết ngày cuối theo giờ Việt Nam', async () => {
    const { prisma, service: doc } = service();
    await doc.danhSach({ from: '2026-08-01', to: '2026-08-05' });
    const where = prisma.loiGoi[0].where as {
      createdAt: { gte: Date; lt: Date };
    };
    expect(where.createdAt.gte.toISOString()).toBe('2026-07-31T17:00:00.000Z');
    expect(where.createdAt.lt.toISOString()).toBe('2026-08-05T17:00:00.000Z');
  });

  it('tìm kiếm chỉ chạm ba cột hiển thị, không chạm cột riêng tư', async () => {
    const { prisma, service: doc } = service();
    await doc.danhSach({ q: 'lan' });
    const where = prisma.loiGoi[0].where as {
      OR: Array<Record<string, unknown>>;
    };
    const cot = where.OR.flatMap((dieu) => Object.keys(dieu)).sort();
    expect(cot).toEqual(['email', 'fullName', 'phone']);
  });
});

describe('Khoá và mở khoá tài khoản', () => {
  it('không khoá được chính tài khoản đang đăng nhập', async () => {
    const { service } = dungServiceGhi({
      email: 'a@b.c',
      role: 'OWNER',
      isActive: true,
    });
    await expect(
      service.datTrangThai(ADMIN_ID, false, 'thử', ADMIN_ID),
    ).rejects.toBeInstanceOf(BadRequestException);
  });

  it('không khoá được tài khoản quản trị', async () => {
    const { service } = dungServiceGhi({
      email: 'a@b.c',
      role: 'ADMIN',
      isActive: true,
    });
    await expect(
      service.datTrangThai('u-2', false, 'thử', ADMIN_ID),
    ).rejects.toBeInstanceOf(BadRequestException);
  });

  it('không có người dùng thì báo không tìm thấy', async () => {
    const { service } = dungServiceGhi(null);
    await expect(
      service.datTrangThai('u-3', false, 'thử', ADMIN_ID),
    ).rejects.toBeInstanceOf(NotFoundException);
  });

  it('khoá xong thì nhật ký ghi cùng lượt, có lý do và giá trị trước sau', async () => {
    const { prisma, service } = dungServiceGhi({
      email: 'lan@petcare.vn',
      role: 'OWNER',
      isActive: true,
    });
    const ket = await service.datTrangThai(
      'u-4',
      false,
      'spam đánh giá',
      ADMIN_ID,
    );
    expect(ket).toEqual({
      id: 'u-4',
      isActive: false,
      runningBookingCount: 0,
    });
    expect(prisma.nhatKy).toEqual([
      {
        adminId: ADMIN_ID,
        action: 'KHOA_TAI_KHOAN',
        targetType: 'USER',
        targetId: 'u-4',
        targetCode: 'lan@petcare.vn',
        reason: 'spam đánh giá',
        oldValue: 'true',
        newValue: 'false|donDangChay=0',
      },
    ]);
  });

  it('vẫn khoá được khi còn đơn chạy dở, kèm số đơn để cảnh báo và truy lại', async () => {
    const { prisma, service } = dungServiceGhi(
      { email: 'nam@petcare.vn', role: 'PROVIDER', isActive: true },
      3,
    );
    const ket = await service.datTrangThai('u-6', false, 'gian lận', ADMIN_ID);
    expect(ket.runningBookingCount).toBe(3);
    expect(prisma.nhatKy[0].newValue).toBe('false|donDangChay=3');
  });

  it('đếm đơn đang chạy của cả hai vai, chỉ ba trạng thái làm đơn treo', async () => {
    const { prisma, service } = dungServiceGhi({
      email: 'nam@petcare.vn',
      role: 'PROVIDER',
      isActive: true,
    });
    await service.datTrangThai('u-7', false, 'gian lận', ADMIN_ID);
    const where = prisma.locDon[0].where as {
      status: { in: string[] };
      OR: Array<Record<string, unknown>>;
    };
    expect(where.status.in).toEqual([
      'CONFIRMED',
      'IN_PROGRESS',
      'AWAITING_OWNER_CONFIRM',
    ]);
    expect(where.OR).toEqual([
      { ownerId: 'u-7' },
      { sitter: { userId: 'u-7' } },
    ]);
  });

  it('kẹp trạng thái cũ vào where, ai đó khoá trước thì không ghi nhật ký thứ hai', async () => {
    const { prisma, service } = dungServiceGhi(
      { email: 'lan@petcare.vn', role: 'OWNER', isActive: true },
      0,
      0,
    );

    await expect(
      service.datTrangThai('u-8', false, 'spam', ADMIN_ID),
    ).rejects.toMatchObject({ response: { code: 'TRANG_THAI_KHONG_HOP_LE' } });
    expect(prisma.daCapNhat[0].where).toEqual({ id: 'u-8', isActive: true });
    expect(prisma.nhatKy).toHaveLength(0);
  });

  it('trạng thái không đổi thì không ghi nhật ký', async () => {
    const { prisma, service } = dungServiceGhi({
      email: 'lan@petcare.vn',
      role: 'OWNER',
      isActive: false,
    });
    await service.datTrangThai('u-5', false, 'thử', ADMIN_ID);
    expect(prisma.nhatKy).toHaveLength(0);
  });
});

describe('Ẩn hồ sơ thú cưng', () => {
  it('ẩn xong ghi nhật ký kèm tên bé', async () => {
    const { prisma, service } = dungServiceGhi({
      name: 'Milo',
      isActive: true,
    });
    await service.datTrangThaiThuCung('p-1', false, 'ảnh sai', ADMIN_ID);
    expect(prisma.nhatKy[0]).toMatchObject({
      action: 'AN_HO_SO_THU_CUNG',
      targetType: 'PET',
      targetCode: 'Milo',
    });
  });
});

describe('Nhãn tuổi thú cưng', () => {
  it('chưa khai ngày sinh thì để trống chứ không đoán', () => {
    expect(nhanTuoi(null)).toBe('Chưa rõ tuổi');
  });

  it('dưới một năm thì đếm theo tháng', () => {
    const sauThangTruoc = new Date(Date.now() - 182 * 24 * 3600_000);
    expect(nhanTuoi(sauThangTruoc)).toMatch(/tháng$/);
  });

  it('trên một năm thì đếm theo năm', () => {
    const haiNamTruoc = new Date(Date.now() - 800 * 24 * 3600_000);
    expect(nhanTuoi(haiNamTruoc)).toBe('2 tuổi');
  });
});
