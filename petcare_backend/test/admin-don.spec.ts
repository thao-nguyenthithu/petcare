import { PrismaService } from '../src/prisma/prisma.service';
import { AdminBookingCancelService } from '../src/modules/admin/bookings/admin-booking-cancel.service';
import { AdminBookingDetailService } from '../src/modules/admin/bookings/admin-booking-detail.service';
import { AdminBookingsReadService } from '../src/modules/admin/bookings/admin-bookings-read.service';
import { NhatKyQuanTriService } from '../src/modules/admin/chung/nhat-ky-quan-tri.service';
import { AnhKyService } from '../src/modules/media/anh-ky.service';
import { NotificationsService } from '../src/modules/notifications/notifications.service';
import {
  dungCau,
  type KhoaTin,
  type ThamSoTin,
} from '../src/modules/notifications/thong-bao-i18n';

const ADMIN_ID = 'admin-1';

// Trường màn tra soát KHÔNG đọc, trả ra là lộ toạ độ nhà và chi tiết mặc cả giá
const TRUONG_KHONG_DUOC_TRA = [
  'addressLat',
  'addressLng',
  'cancellationNote',
  'cancellationReason',
  'cancelledAt',
  'ownerDepartedAt',
  'etaAt',
  'pickupDistanceKm',
  'priceBreakdown',
];

function dungHuy(trangThai: string | null, soDongDoi = 1) {
  const nhatKy: Array<Record<string, unknown>> = [];
  const daCapNhat: Array<Record<string, unknown>> = [];
  const dieuKienGhi: Array<Record<string, unknown>> = [];
  const daDoiTien: Array<Record<string, unknown>> = [];
  const tinDaGui: Array<Record<string, unknown>> = [];

  const prisma = {
    booking: {
      findUnique: () =>
        Promise.resolve(
          trangThai && {
            id: 'don-1',
            code: 'PC001',
            status: trangThai,
            ownerId: 'u-owner',
            sitter: { userId: 'u-ncc' },
          },
        ),
      updateMany: (arg: {
        where: Record<string, unknown>;
        data: Record<string, unknown>;
      }) => {
        dieuKienGhi.push(arg.where);
        if (soDongDoi === 0) return Promise.resolve({ count: 0 });
        daCapNhat.push(arg.data);
        return Promise.resolve({ count: soDongDoi });
      },
      // Lối KHÔNG kẹp trạng thái cũ, để gỡ bản vá ra là test đỏ vì ghi đè đơn đã huỷ
      update: (arg: { data: Record<string, unknown> }) => {
        daCapNhat.push(arg.data);
        return Promise.resolve({ id: 'don-1' });
      },
    },
    payment: {
      updateMany: (arg: Record<string, unknown>) => {
        daDoiTien.push(arg);
        return Promise.resolve({ count: 1 });
      },
    },
    adminAuditLog: {
      create: (arg: { data: Record<string, unknown> }) => {
        nhatKy.push(arg.data);
        return Promise.resolve({ id: 'log-1' });
      },
    },
    $transaction: (lenh: unknown) =>
      typeof lenh === 'function'
        ? (lenh as (db: unknown) => Promise<unknown>)(prisma)
        : Promise.resolve(lenh),
  };

  const service = new AdminBookingCancelService(
    prisma as unknown as PrismaService,
    new NhatKyQuanTriService(prisma as unknown as PrismaService),
    {
      tao: (tin: Record<string, unknown>) => {
        tinDaGui.push(tin);
        return Promise.resolve({ id: 'tin-1' });
      },
    } as unknown as NotificationsService,
  );
  return { service, nhatKy, daCapNhat, dieuKienGhi, daDoiTien, tinDaGui };
}

describe('Quản trị viên can thiệp huỷ đơn', () => {
  it('đơn chưa chạy thì huỷ được, ghi nhật ký cùng lượt và báo hai bên', async () => {
    const { service, nhatKy, daCapNhat, tinDaGui } = dungHuy('CONFIRMED');

    const ket = await service.canThiepHuy(
      'PC001',
      'chủ nuôi báo lừa',
      ADMIN_ID,
    );

    expect(ket).toEqual({ code: 'PC001', status: 'CANCELLED_BY_ADMIN' });
    expect(daCapNhat[0]).toMatchObject({ status: 'CANCELLED_BY_ADMIN' });
    expect(nhatKy[0]).toMatchObject({
      action: 'CAN_THIEP_HUY_DON',
      targetType: 'BOOKING',
      targetCode: 'PC001',
      oldValue: 'CONFIRMED',
    });
    expect(tinDaGui).toHaveLength(2);
  });

  it('đơn đã bắt đầu thì bắt đi đường khiếu nại, không ghi gì', async () => {
    const { service, nhatKy, daCapNhat } = dungHuy('IN_PROGRESS');

    await expect(
      service.canThiepHuy('PC001', 'thử', ADMIN_ID),
    ).rejects.toMatchObject({
      response: { code: 'DON_DA_CHAY_PHAI_QUA_KHIEU_NAI' },
    });
    expect(daCapNhat).toHaveLength(0);
    expect(nhatKy).toHaveLength(0);
  });

  it('đơn chưa trả tiền thì không nói dối là được hoàn tiền', async () => {
    const { service, tinDaGui } = dungHuy('AWAITING_PAYMENT');

    await service.canThiepHuy('PC001', 'trùng đơn', ADMIN_ID);

    const tin = tinDaGui[0] as { bodyKey: KhoaTin; params: ThamSoTin };
    expect(dungCau(tin.bodyKey, tin.params)).toContain(
      'không có khoản nào bị trừ',
    );
  });

  it('đơn vừa huỷ ở lối khác thì dừng, không ghi đè và không báo hai bên', async () => {
    // Kẹp trạng thái cũ vào where: thiếu thì lượt huỷ của chủ nuôi bị xoá dấu vết
    const { service, nhatKy, dieuKienGhi, tinDaGui } = dungHuy('PENDING', 0);

    await expect(
      service.canThiepHuy('PC001', 'chủ nuôi báo lừa', ADMIN_ID),
    ).rejects.toMatchObject({ response: { code: 'DON_DA_HUY' } });
    expect(dieuKienGhi[0].status).toEqual({
      in: ['AWAITING_PAYMENT', 'PENDING', 'CONFIRMED'],
    });
    expect(nhatKy).toHaveLength(0);
    expect(tinDaGui).toHaveLength(0);
  });
});

function dungChiTiet() {
  const daHoi: Array<Record<string, unknown>> = [];
  const prisma = {
    booking: {
      findUnique: (arg: Record<string, unknown>) => {
        daHoi.push(arg);
        return Promise.resolve({
          id: 'don-1',
          code: 'PC001',
          status: 'COMPLETED',
          scheduledAt: new Date('2026-08-02T01:00:00Z'),
          createdAt: new Date('2026-08-01T01:00:00Z'),
          paidAt: new Date('2026-08-01T02:00:00Z'),
          noShowProofUrls: [],
          owner: { id: 'u-1', fullName: 'Lan', email: 'lan@petcare.vn' },
          sitter: { id: 'ncc-1', ratingAvg: 5, user: { id: 'u-2' } },
          service: { name: 'Dắt đi dạo', type: 'WALKING' },
          pets: [],
          payments: [],
          gpsReport: null,
        });
      },
    },
    locationTrack: { findMany: () => Promise.resolve([]) },
  };
  const service = new AdminBookingDetailService(
    prisma as unknown as PrismaService,
    { kyMang: () => Promise.resolve([]) } as unknown as AnhKyService,
  );
  return { service, daHoi };
}

describe('Chi tiết đơn cho màn tra soát', () => {
  it('không kéo về trường màn không đọc, kể cả toạ độ nhà chủ nuôi', async () => {
    const { service, daHoi } = dungChiTiet();

    const ket = await service.chiTiet('PC001');

    const chon = (daHoi[0].select ?? {}) as Record<string, unknown>;
    for (const truong of TRUONG_KHONG_DUOC_TRA) {
      expect(chon[truong]).toBeUndefined();
      expect(Object.keys(ket.booking)).not.toContain(truong);
    }
  });

  it('vẫn trả hạn nhận đơn vì web không tự suy được công thức bốn bậc', async () => {
    const { service } = dungChiTiet();

    const ket = await service.chiTiet('PC001');

    expect(ket.booking.acceptDeadlineAt).toBeInstanceOf(Date);
  });
});

describe('Số đếm chín tab đơn', () => {
  it('gộp một groupBy cho tám tab, chỉ tab khiếu nại đi lượt riêng', async () => {
    const soLuot: string[] = [];
    const prisma = {
      booking: {
        groupBy: () => {
          soLuot.push('groupBy');
          return Promise.resolve([
            { status: 'PENDING', _count: { _all: 3 } },
            { status: 'IN_PROGRESS', _count: { _all: 2 } },
            { status: 'CANCELLED_UNPAID', _count: { _all: 4 } },
          ]);
        },
        count: () => {
          soLuot.push('count');
          return Promise.resolve(7);
        },
      },
    };
    const service = new AdminBookingsReadService(
      prisma as unknown as PrismaService,
    );

    const ket = await service.demTab();

    // Chín phép đếm rời là chín lượt đi về, mỗi lượt tốn khoảng 50ms
    expect(soLuot).toEqual(['groupBy', 'count']);
    expect(ket).toEqual({
      all: 9,
      awaitingPayment: 0,
      pending: 3,
      confirmed: 0,
      running: 2,
      awaitingConfirm: 0,
      completed: 0,
      cancelled: 4,
      disputed: 7,
    });
  });
});
