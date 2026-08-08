import { BadRequestException, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../src/prisma/prisma.service';
import { THAM_SO } from '../src/modules/admin/tham-so.dinh-nghia';
import { SystemSettingsService } from '../src/modules/admin/system-settings.service';

// Tham số vận hành (bộ luật mục 15); bảng rỗng là hợp lệ, mọi khoá rơi về mặc định

type DongThamSo = {
  key: string;
  value: string;
  updatedBy: string | null;
  updatedAt: Date;
};

type NhatKy = {
  action: string;
  targetType: string;
  targetId: string | null;
  oldValue: string | null;
  newValue: string | null;
  reason: string | null;
};

function bangGia(banDau: Record<string, string> = {}) {
  const dong = new Map<string, DongThamSo>(
    Object.entries(banDau).map(([key, value]) => [
      key,
      { key, value, updatedBy: null, updatedAt: new Date('2026-08-01') },
    ]),
  );
  const nhatKy: NhatKy[] = [];
  let soLuotDoc = 0;
  const prisma = {
    dong,
    nhatKy,
    soLuotDoc: () => soLuotDoc,
    systemSetting: {
      findMany: () => {
        soLuotDoc++;
        return Promise.resolve([...dong.values()]);
      },
      upsert: (arg: {
        where: { key: string };
        create: { key: string; value: string; updatedBy: string };
      }) => {
        const luc = new Date('2026-08-06T10:00:00Z');
        dong.set(arg.where.key, {
          key: arg.where.key,
          value: arg.create.value,
          updatedBy: arg.create.updatedBy,
          updatedAt: luc,
        });
        return Promise.resolve({ updatedAt: luc });
      },
    },
    adminAuditLog: {
      create: (arg: { data: NhatKy }) => {
        nhatKy.push(arg.data);
        return Promise.resolve({ id: 'log-1' });
      },
    },
    user: {
      findMany: () => Promise.resolve([{ id: 'ad-1', fullName: 'Quản trị' }]),
    },
    $transaction: (ops: Promise<unknown>[]) => Promise.all(ops),
  };
  return prisma;
}

async function dichVu(banDau: Record<string, string> = {}) {
  const prisma = bangGia(banDau);
  const service = new SystemSettingsService(prisma as unknown as PrismaService);
  await service.onModuleInit();
  return { service, prisma };
}

describe('rơi về mặc định', () => {
  it('bảng rỗng thì mọi khoá lấy mặc định của bộ khai', async () => {
    const { service } = await dichVu();
    expect(service.so('platform.fee.percent')).toBe(15);
    expect(service.so('escrow.hours')).toBe(48);
    expect(service.so('withdraw.min')).toBe(50_000);
    expect(service.bat('sitter.auto_approve')).toBe(false);
  });

  it('giá trị rác trong bảng thì lấy mặc định', async () => {
    const { service } = await dichVu({ 'escrow.hours': 'bốn tám' });
    expect(service.so('escrow.hours')).toBe(48);
  });

  it('giá trị ngoài khoảng trong bảng thì lấy mặc định', async () => {
    const { service } = await dichVu({ 'platform.fee.percent': '90' });
    expect(service.so('platform.fee.percent')).toBe(15);
  });

  it('công tắc ghi sai chính tả thì lấy mặc định', async () => {
    const { service } = await dichVu({ 'sitter.auto_approve': 'bat' });
    expect(service.bat('sitter.auto_approve')).toBe(false);
  });

  it('mất kết nối lúc khởi động vẫn chạy được bằng mặc định', async () => {
    const prisma = {
      systemSetting: {
        findMany: () => Promise.reject(new Error('mất kết nối')),
      },
    };
    const service = new SystemSettingsService(
      prisma as unknown as PrismaService,
    );
    await service.onModuleInit();
    expect(service.so('platform.fee.percent')).toBe(15);
  });
});

describe('chặn khoảng khi ghi', () => {
  it('vượt trần thì ném NGOAI_KHOANG_CHO_PHEP', async () => {
    const { service } = await dichVu();
    await expect(
      service.dat('platform.fee.percent', 31, 'ad-1'),
    ).rejects.toThrow(BadRequestException);
    expect(service.so('platform.fee.percent')).toBe(15);
  });

  it('dưới sàn thì ném', async () => {
    const { service } = await dichVu();
    await expect(service.dat('withdraw.per_day', 0, 'ad-1')).rejects.toThrow(
      BadRequestException,
    );
  });

  it('đúng hai biên thì nhận', async () => {
    const { service } = await dichVu();
    await service.dat('platform.fee.percent', 5, 'ad-1');
    expect(service.so('platform.fee.percent')).toBe(5);
    await service.dat('platform.fee.percent', 30, 'ad-1');
    expect(service.so('platform.fee.percent')).toBe(30);
  });

  it('số lẻ thì ném vì mọi khoá đều là số nguyên', async () => {
    const { service } = await dichVu();
    await expect(
      service.dat('platform.fee.percent', 15.5, 'ad-1'),
    ).rejects.toThrow(BadRequestException);
  });

  it('khoá lạ thì ném KHONG_TIM_THAY_THAM_SO', async () => {
    const { service } = await dichVu();
    await expect(service.dat('phi.linh.tinh', 10, 'ad-1')).rejects.toThrow(
      NotFoundException,
    );
  });

  it('công tắc nhận số thì ném', async () => {
    const { service } = await dichVu();
    await expect(service.dat('sitter.auto_approve', 1, 'ad-1')).rejects.toThrow(
      BadRequestException,
    );
  });

  it('tham số dạng số nhận true thì ném', async () => {
    const { service } = await dichVu();
    await expect(service.dat('escrow.hours', true, 'ad-1')).rejects.toThrow(
      BadRequestException,
    );
  });
});

describe('cache', () => {
  it('đọc nhiều lần chỉ tốn một lượt đi về cơ sở dữ liệu', async () => {
    const { service, prisma } = await dichVu({ 'escrow.hours': '72' });
    service.so('escrow.hours');
    service.so('escrow.hours');
    service.so('platform.fee.percent');
    expect(prisma.soLuotDoc()).toBe(1);
  });

  it('làm mới ngay sau lệnh ghi, không chờ nhịp nạp lại', async () => {
    const { service, prisma } = await dichVu();
    await service.dat('escrow.hours', 72, 'ad-1');
    expect(service.so('escrow.hours')).toBe(72);
    expect(prisma.soLuotDoc()).toBe(1);
  });

  it('nạp lại theo nhịp thì ăn giá trị ai đó sửa thẳng cơ sở dữ liệu', async () => {
    const { service, prisma } = await dichVu();
    prisma.dong.set('escrow.hours', {
      key: 'escrow.hours',
      value: '96',
      updatedBy: null,
      updatedAt: new Date('2026-08-06'),
    });
    expect(service.so('escrow.hours')).toBe(48);
    await service.lamMoi();
    expect(service.so('escrow.hours')).toBe(96);
  });
});

describe('nhật ký quản trị', () => {
  it('ghi oldValue và newValue, giá trị cũ là mặc định khi bảng chưa có dòng', async () => {
    const { service, prisma } = await dichVu();
    await service.dat('withdraw.min', 100_000, 'ad-1', 'demo bảo vệ');
    expect(prisma.nhatKy).toHaveLength(1);
    expect(prisma.nhatKy[0]).toMatchObject({
      action: 'CAP_NHAT_THAM_SO',
      targetType: 'SETTING',
      targetId: 'withdraw.min',
      oldValue: '50000',
      newValue: '100000',
      reason: 'demo bảo vệ',
    });
  });

  it('lần đổi thứ hai lấy giá trị cũ từ bảng', async () => {
    const { service, prisma } = await dichVu();
    await service.dat('withdraw.min', 100_000, 'ad-1');
    await service.dat('withdraw.min', 20_000, 'ad-1');
    expect(prisma.nhatKy[1]).toMatchObject({
      oldValue: '100000',
      newValue: '20000',
    });
  });

  it('lệnh ghi bị chặn thì không để lại vết trong nhật ký', async () => {
    const { service, prisma } = await dichVu();
    await expect(service.dat('withdraw.min', 10, 'ad-1')).rejects.toThrow();
    expect(prisma.nhatKy).toHaveLength(0);
  });
});

describe('danh sách và cấu hình công khai', () => {
  it('trả đủ khoá kèm khoảng, mặc định và người đổi cuối', async () => {
    const { service } = await dichVu();
    await service.dat('escrow.hours', 72, 'ad-1');
    const ket = await service.danhSachChoQuanTri();
    expect(ket.items).toHaveLength(Object.keys(THAM_SO).length);
    const escrow = ket.items.find((i) => i.key === 'escrow.hours');
    expect(escrow).toMatchObject({
      giaTri: 72,
      macDinh: 48,
      min: 24,
      max: 168,
      donVi: 'gio',
      nguoiDoi: { id: 'ad-1', hoTen: 'Quản trị' },
    });
    const congTac = ket.items.find((i) => i.key === 'sitter.auto_approve');
    expect(congTac).toMatchObject({ kieu: 'batTat', min: null, max: null });
  });

  it('cấu hình công khai giấu khoá nội bộ', async () => {
    const { service } = await dichVu();
    const congKhai = service.congKhai();
    expect(congKhai['platform.fee.percent']).toBe(15);
    expect(congKhai['payment.vnpay.enabled']).toBe(false);
    expect(congKhai['sitter.auto_approve']).toBeUndefined();
  });

  it('mốc cập nhật đổi sau khi ghi, để ETag của khách hết hiệu lực', async () => {
    const { service } = await dichVu();
    expect(service.capNhatLuc()).toBeNull();
    await service.dat('escrow.hours', 72, 'ad-1');
    expect(service.capNhatLuc()).not.toBeNull();
  });
});
