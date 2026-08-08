import { ForbiddenException, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../src/prisma/prisma.service';
import { SitterSlotsService } from '../src/modules/bookings/sitter-slots.service';
import { SittersService } from '../src/modules/sitter/public/sitters.service';
import { SitterPenaltyService } from '../src/modules/bookings/sitter-penalty.service';
import { SitterActionsService } from '../src/modules/sitter/orders/sitter-actions.service';
import { SitterOrderStore } from '../src/modules/sitter/orders/sitter-order-store.service';
import { SitterLichService } from '../src/modules/sitter/orders/sitter-lich.service';
import { BookingNotifyService } from '../src/modules/notifications/booking-notify.service';
import { BookingChatService } from '../src/modules/messaging/booking-chat.service';
import { dieuKienNccCongKhai } from '../src/modules/sitter/public/sitter-public';
import { layNccCuaToi } from '../src/modules/sitter/orders/sitter-guard';

// Ba cơ chế tách biệt cùng phải chặn ba lối công khai: isActive, hiddenUntil, bannedAt

const MOT_NGAY_MS = 24 * 3600_000;
const TUONG_LAI = new Date(Date.now() + 3 * MOT_NGAY_MS);
const QUA_KHU = new Date(Date.now() - 3 * MOT_NGAY_MS);

type HoSo = {
  status: string;
  user: { isActive: boolean };
  bannedAt: Date | null;
  hiddenUntil: Date | null;
};

const BINH_THUONG: HoSo = {
  status: 'APPROVED',
  user: { isActive: true },
  bannedAt: null,
  hiddenUntil: null,
};

// Lọc đúng như cơ sở dữ liệu làm, kể cả nhánh AND lồng OR
function khopDieuKien(ncc: HoSo, where: Record<string, unknown>): boolean {
  if (where.status !== undefined && ncc.status !== where.status) return false;
  const and = (where.AND ?? []) as Array<Record<string, unknown>>;
  return and.every((dieu) => khopMotVe(ncc, dieu));
}

function khopMotVe(ncc: HoSo, dieu: Record<string, unknown>): boolean {
  if (Array.isArray(dieu.OR)) {
    return (dieu.OR as Array<Record<string, unknown>>).some((ve) =>
      khopMotVe(ncc, ve),
    );
  }
  const user = dieu.user as { isActive?: boolean } | undefined;
  if (user?.isActive !== undefined && ncc.user.isActive !== user.isActive) {
    return false;
  }
  if (dieu.bannedAt === null && ncc.bannedAt !== null) return false;
  if (dieu.hiddenUntil === null && ncc.hiddenUntil !== null) return false;
  const han = dieu.hiddenUntil as { lte?: Date } | null | undefined;
  if (han?.lte !== undefined) {
    if (ncc.hiddenUntil === null) return false;
    if (ncc.hiddenUntil > han.lte) return false;
  }
  return true;
}

function prismaGia(ncc: HoSo) {
  const tra = (arg: { where?: Record<string, unknown> }) => {
    const where = arg.where ?? {};
    if (!khopDieuKien(ncc, where)) return Promise.resolve(null);
    return Promise.resolve({
      id: 'ncc-1',
      userId: 'u-ncc',
      status: ncc.status,
      workStart: '07:00',
      workEnd: '20:00',
      workDays: [1, 2, 3, 4, 5, 6],
      lat: 21,
      lng: 105,
      serviceRadiusKm: 10,
      user: { id: 'u-ncc', fullName: 'Nam', avatarUrl: null },
      photos: [],
      services: [],
    });
  };
  return {
    sitter: { findFirst: tra, findUnique: tra },
    booking: { count: () => Promise.resolve(0) },
  };
}

function dungSlots(ncc: HoSo) {
  return new SitterSlotsService(prismaGia(ncc) as unknown as PrismaService);
}

function dungHoSoCongKhai(ncc: HoSo) {
  return new SittersService(
    prismaGia(ncc) as unknown as PrismaService,
    {
      tyLeNhanDon: () => Promise.resolve(100),
    } as unknown as SitterPenaltyService,
  );
}

// Người chăm đã có hồ sơ hợp lệ, chỉ khác nhau ở mốc tạm ẩn
function dungNhanDon(hiddenUntil: Date | null, trangThaiDon = 'PENDING') {
  const daCapNhat: Array<Record<string, unknown>> = [];
  const prisma = {
    booking: {
      update: (arg: Record<string, unknown>) => {
        daCapNhat.push(arg);
        return Promise.resolve({ id: 'don-1' });
      },
    },
  };
  const store = {
    timDon: () =>
      Promise.resolve({
        ncc: { id: 'ncc-1', userId: 'u-ncc', hiddenUntil, bannedAt: null },
        don: {
          id: 'don-1',
          status: trangThaiDon,
          scheduledAt: new Date(Date.now() + MOT_NGAY_MS),
          paidAt: new Date(),
          createdAt: new Date(),
          service: { type: 'WALKING' },
        },
      }),
  };
  const lich = {
    donCungLich: () => Promise.resolve({ daNhan: [], dangCho: [] }),
    chanTrungLich: () => Promise.resolve(undefined),
    donDepDonChoChet: () => Promise.resolve(undefined),
  };
  const service = new SitterActionsService(
    prisma as unknown as PrismaService,
    store as unknown as SitterOrderStore,
    {
      daNhanDon: () => Promise.resolve(undefined),
    } as unknown as BookingNotifyService,
    {
      daNhanDon: () => Promise.resolve(undefined),
    } as unknown as BookingChatService,
    lich as unknown as SitterLichService,
  );
  return { service, daCapNhat };
}

describe('Điều kiện hồ sơ công khai', () => {
  it('dựng lại mốc bây giờ mỗi lần gọi, không chốt lúc nạp mô đun', () => {
    const som = dieuKienNccCongKhai();
    const muon = dieuKienNccCongKhai(new Date(Date.now() + MOT_NGAY_MS));
    const lay = (dieu: ReturnType<typeof dieuKienNccCongKhai>) =>
      (dieu.AND as Array<{ OR?: Array<{ hiddenUntil?: { lte?: Date } }> }>)
        .find((ve) => ve.OR)
        ?.OR?.find((ve) => ve.hiddenUntil?.lte)?.hiddenUntil?.lte;
    expect(lay(muon)!.getTime()).toBeGreaterThan(lay(som)!.getTime());
  });

  it('lọc tài khoản bị khoá nằm trong AND nên không bị lọc từ khoá đè mất', () => {
    // Lọc theo từ khoá trả về khoá `user` và cả `OR`, spread sau sẽ đè nếu để cùng cấp
    const where = {
      ...dieuKienNccCongKhai(),
      ...{ user: { fullName: { contains: 'nam' } }, OR: [{ ratingAvg: 5 }] },
    };
    expect(where.AND).toHaveLength(3);
  });
});

describe('Người chăm bị khoá tài khoản', () => {
  const BI_KHOA: HoSo = { ...BINH_THUONG, user: { isActive: false } };

  it('lối TẠO ĐƠN không tìm thấy hồ sơ', async () => {
    await expect(
      dungSlots(BI_KHOA).layNccCongKhai('ncc-1'),
    ).rejects.toBeInstanceOf(NotFoundException);
  });

  it('lối XEM HỒ SƠ công khai không tìm thấy', async () => {
    await expect(
      dungHoSoCongKhai(BI_KHOA).getPublicProfile('ncc-1'),
    ).rejects.toBeInstanceOf(NotFoundException);
  });

  it('người chăm bình thường vẫn đặt được', async () => {
    await expect(
      dungSlots(BINH_THUONG).layNccCongKhai('ncc-1'),
    ).resolves.toMatchObject({ id: 'ncc-1' });
  });
});

describe('Người chăm bị khoá vĩnh viễn', () => {
  const BI_BAN: HoSo = { ...BINH_THUONG, bannedAt: QUA_KHU };

  it('lối TẠO ĐƠN không tìm thấy, không để chủ nuôi trả tiền rồi mới hỏng', async () => {
    await expect(
      dungSlots(BI_BAN).layNccCongKhai('ncc-1'),
    ).rejects.toBeInstanceOf(NotFoundException);
  });

  it('lối XEM HỒ SƠ công khai không tìm thấy', async () => {
    await expect(
      dungHoSoCongKhai(BI_BAN).getPublicProfile('ncc-1'),
    ).rejects.toBeInstanceOf(NotFoundException);
  });
});

describe('Người chăm đang bị tạm ẩn', () => {
  const DANG_AN: HoSo = { ...BINH_THUONG, hiddenUntil: TUONG_LAI };

  it('lối TẠO ĐƠN không tìm thấy', async () => {
    await expect(
      dungSlots(DANG_AN).layNccCongKhai('ncc-1'),
    ).rejects.toBeInstanceOf(NotFoundException);
  });

  it('lối XEM HỒ SƠ công khai không tìm thấy', async () => {
    await expect(
      dungHoSoCongKhai(DANG_AN).getPublicProfile('ncc-1'),
    ).rejects.toBeInstanceOf(NotFoundException);
  });

  it('KHÔNG nhận được đơn chờ, kể cả đơn đã trả tiền từ trước', async () => {
    const { service, daCapNhat } = dungNhanDon(TUONG_LAI);
    await expect(
      service.nhanDon('u-ncc', 'don-1', { safetyCommitted: true }),
    ).rejects.toBeInstanceOf(ForbiddenException);
    expect(daCapNhat).toHaveLength(0);
  });

  it('đơn đã nhận thì lỗi là do trạng thái chứ không phải do bị ẩn', async () => {
    const { service } = dungNhanDon(TUONG_LAI, 'CONFIRMED');
    await expect(
      service.nhanDon('u-ncc', 'don-1', { safetyCommitted: true }),
    ).rejects.toMatchObject({
      response: { code: 'TRANG_THAI_KHONG_HOP_LE' },
    });
  });

  it('VẪN qua được guard để làm tiếp đơn đã nhận, đúng vế ba của bộ luật mục 6', async () => {
    // Chặn ở guard là chặn MỌI thao tác, kể cả bấm kết thúc đơn đang chạy dở
    const prisma = {
      sitter: {
        findUnique: () =>
          Promise.resolve({
            id: 'ncc-1',
            userId: 'u-ncc',
            hiddenUntil: TUONG_LAI,
            hiddenCount: 1,
            bannedAt: null,
          }),
      },
    };
    await expect(
      layNccCuaToi(prisma as unknown as PrismaService, 'u-ncc'),
    ).resolves.toMatchObject({ id: 'ncc-1' });
  });
});

describe('Người chăm đã hết hạn tạm ẩn', () => {
  const HET_AN: HoSo = { ...BINH_THUONG, hiddenUntil: QUA_KHU };

  it('hiện lại trong lối TẠO ĐƠN mà không cần ai gỡ tay', async () => {
    await expect(
      dungSlots(HET_AN).layNccCongKhai('ncc-1'),
    ).resolves.toMatchObject({ id: 'ncc-1' });
  });

  it('hiện lại ở lối XEM HỒ SƠ công khai', async () => {
    await expect(
      dungHoSoCongKhai(HET_AN).getPublicProfile('ncc-1'),
    ).resolves.toBeDefined();
  });

  it('nhận đơn lại được bình thường', async () => {
    const { service, daCapNhat } = dungNhanDon(QUA_KHU);
    await service.nhanDon('u-ncc', 'don-1', { safetyCommitted: true });
    expect(daCapNhat).toHaveLength(1);
  });
});
