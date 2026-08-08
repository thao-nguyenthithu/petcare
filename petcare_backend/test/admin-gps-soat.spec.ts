import { NotFoundException } from '@nestjs/common';
import { PrismaService } from '../src/prisma/prisma.service';
import { NhatKyQuanTriService } from '../src/modules/admin/chung/nhat-ky-quan-tri.service';
import { AdminGpsReportsService } from '../src/modules/admin/bookings/admin-gps-reports.service';

const ADMIN_ID = 'admin-1';

// Cờ và mốc soát là hai chuyện, mọi tổ hợp của chúng đều dựng được ở đây
type BanGhi = { flaggedForReview: boolean; reviewedAt?: Date | null } | null;

function dungGhi(
  banGhi: BanGhi,
  dong: Record<string, unknown>[] = [],
  soDongDoi = 1,
) {
  const nhatKy: Array<Record<string, unknown>> = [];
  const daCapNhat: Array<Record<string, unknown>> = [];
  const dieuKienGhi: Array<Record<string, unknown>> = [];
  const dieuKienDaHoi: Array<unknown> = [];
  const thuTuDaHoi: Array<unknown> = [];
  const prisma = {
    nhatKy,
    daCapNhat,
    dieuKienGhi,
    dieuKienDaHoi,
    thuTuDaHoi,
    bookingGpsReport: {
      findFirst: () =>
        Promise.resolve(
          banGhi
            ? {
                id: 'gps-1',
                flaggedForReview: banGhi.flaggedForReview,
                reviewedAt: banGhi.reviewedAt ?? null,
                booking: { id: 'don-1', code: 'PC-001' },
              }
            : null,
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
      // Lối KHÔNG kẹp cờ cũ, để gỡ bản vá ra là test đỏ vì nhật ký thừa dòng
      update: (arg: { data: Record<string, unknown> }) => {
        daCapNhat.push(arg.data);
        return Promise.resolve({ id: 'gps-1' });
      },
      count: (arg: { where: unknown }) => {
        dieuKienDaHoi.push(arg.where);
        return Promise.resolve(dong.length);
      },
      findMany: (arg: { where: unknown; orderBy: unknown }) => {
        dieuKienDaHoi.push(arg.where);
        thuTuDaHoi.push(arg.orderBy);
        return Promise.resolve(dong);
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
  const service = new AdminGpsReportsService(
    prisma as unknown as PrismaService,
    new NhatKyQuanTriService(prisma as unknown as PrismaService),
  );
  return { service, prisma };
}

function dongGps(claimedDistanceKm: number | null) {
  return {
    // Không có số app khai thì không có điểm, đúng như máy chủ chốt báo cáo
    suspicionScore: claimedDistanceKm === null ? null : 0.42,
    flaggedForReview: true,
    suspicionNote: 'App báo 3.0 km, lộ trình về tới server 1.0 km',
    totalDistanceM: 1000,
    totalWaypoints: 90,
    durationMinutes: 30,
    avgSpeedKmh: 2,
    mockedCount: 0,
    speedFlag: false,
    createdAt: new Date('2026-08-07T02:00:00.000Z'),
    booking: {
      code: 'PC-001',
      distanceKm: claimedDistanceKm,
      sitter: { id: 'ncc-1', legalName: null, user: { fullName: 'Nam' } },
    },
  };
}

describe('Soát đơn gắn cờ lộ trình', () => {
  it('gỡ cờ thì hạ cờ, ghi nhật ký và không đụng đơn hay tiền', async () => {
    const { service, prisma } = dungGhi({ flaggedForReview: true });

    const ket = await service.soat(
      'PC-001',
      true,
      'Đi qua hầm nên mất sóng',
      ADMIN_ID,
    );

    expect(ket).toEqual({ bookingCode: 'PC-001', flaggedForReview: false });
    expect(prisma.daCapNhat[0]).toMatchObject({
      flaggedForReview: false,
      suspicionNote: 'Đi qua hầm nên mất sóng',
    });
    // Mốc soát là thứ duy nhất phân biệt đơn đã xem với đơn chưa ai đụng
    expect(prisma.daCapNhat[0].reviewedAt).toBeInstanceOf(Date);
    expect(prisma.nhatKy).toHaveLength(1);
    expect(prisma.nhatKy[0]).toMatchObject({
      adminId: ADMIN_ID,
      action: 'GO_CO_GPS',
      targetType: 'BOOKING',
      targetCode: 'PC-001',
      oldValue: 'true',
      newValue: 'false',
    });
    // Không có booking.update hay payment nào trong prisma giả: gọi tới là vỡ ngay
    expect(Object.keys(prisma)).not.toContain('payment');
  });

  it('giữ cờ thì cờ vẫn còn và nhật ký ghi đúng hành động', async () => {
    const { service, prisma } = dungGhi({ flaggedForReview: true });

    const ket = await service.soat(
      'PC-001',
      false,
      'Số liệu vẫn đáng ngờ',
      ADMIN_ID,
    );

    expect(ket.flaggedForReview).toBe(true);
    expect(prisma.daCapNhat[0]).toMatchObject({ flaggedForReview: true });
    expect(prisma.nhatKy[0]).toMatchObject({
      action: 'GIU_CO_GPS',
      oldValue: 'true',
      newValue: 'true',
    });
  });

  it('cờ vừa bị người khác hạ giữa chừng thì chặn, không ghi dòng nhật ký nào', async () => {
    // Kẹp cờ cũ vào where: thiếu thì hai lượt soát cùng lúc ghi hai dòng nhật ký
    const { service, prisma } = dungGhi({ flaggedForReview: true }, [], 0);

    await expect(
      service.soat('PC-001', true, 'Xem xong', ADMIN_ID),
    ).rejects.toMatchObject({ response: { code: 'BAO_CAO_GPS_DA_SOAT' } });
    expect(prisma.dieuKienGhi[0]).toMatchObject({ flaggedForReview: true });
    expect(prisma.nhatKy).toHaveLength(0);
  });

  it('đơn không có bản ghi lộ trình thì báo không tìm thấy', async () => {
    const { service } = dungGhi(null);

    await expect(
      service.soat('PC-404', true, 'Xem xong', ADMIN_ID),
    ).rejects.toThrow(NotFoundException);
  });

  it('đơn đã có người gỡ cờ thì chặn, không ghi thêm dòng nhật ký nào', async () => {
    const { service, prisma } = dungGhi({
      flaggedForReview: false,
      reviewedAt: new Date('2026-08-07T02:00:00.000Z'),
    });

    await expect(
      service.soat('PC-001', true, 'Soát lại', ADMIN_ID),
    ).rejects.toMatchObject({
      response: { code: 'BAO_CAO_GPS_DA_SOAT' },
    });
    expect(prisma.nhatKy).toHaveLength(0);
    expect(prisma.daCapNhat).toHaveLength(0);
  });

  it('đơn sạch chưa ai đụng thì báo không có cờ, KHÔNG báo đã soát xong', async () => {
    const { service, prisma } = dungGhi({
      flaggedForReview: false,
      reviewedAt: null,
    });

    // Nói "đã soát xong" với đơn chưa ai mở ra là hệ thống nói dối người soát
    await expect(
      service.soat('PC-001', true, 'Xem qua thấy sạch', ADMIN_ID),
    ).rejects.toMatchObject({
      response: { code: 'KHONG_CO_CO_DE_SOAT' },
    });
    expect(prisma.nhatKy).toHaveLength(0);
  });

  it('đơn đã soát mà vẫn giữ cờ thì soát lại được, việc chưa khép', async () => {
    const { service, prisma } = dungGhi({
      flaggedForReview: true,
      reviewedAt: new Date('2026-08-07T02:00:00.000Z'),
    });

    const ket = await service.soat(
      'PC-001',
      true,
      'Đã có ảnh chứng minh',
      ADMIN_ID,
    );

    expect(ket.flaggedForReview).toBe(false);
    // Mốc soát nhảy sang lượt mới, lịch sử đầy đủ nằm ở AdminAuditLog
    expect(prisma.daCapNhat[0].reviewedAt).toBeInstanceOf(Date);
    expect(prisma.nhatKy[0]).toMatchObject({ action: 'GO_CO_GPS' });
  });

  it('tab đã soát lọc theo mốc soát, đơn sạch chưa ai đụng không lọt vào', async () => {
    const { service, prisma } = dungGhi(null, [dongGps(3)]);

    await service.danhSach({ tab: 'reviewed' });

    // Cờ tắt là mặc định của đơn sạch, lọc theo nó là gom cả đơn chưa ai nhìn tới
    expect(prisma.dieuKienDaHoi[0]).toEqual({ reviewedAt: { not: null } });
    expect(prisma.dieuKienDaHoi[0]).not.toHaveProperty('flaggedForReview');
  });

  it('hàng chờ chỉ còn việc chưa ai làm, đơn đã soát mà giữ cờ không nằm đó', async () => {
    const { service, prisma } = dungGhi(null, [dongGps(3)]);

    await service.danhSach({ tab: 'flagged' });

    expect(prisma.dieuKienDaHoi[0]).toEqual({
      flaggedForReview: true,
      reviewedAt: null,
    });
  });

  it('tab chưa khai lọc thẳng theo dữ liệu, không dựng ngưỡng nào', async () => {
    const { service, prisma } = dungGhi(null, [dongGps(null)]);

    await service.danhSach({ tab: 'noClaim' });

    expect(prisma.dieuKienDaHoi[0]).toEqual({ booking: { distanceKm: null } });
  });

  it('app chưa khai số km thì cả số khai lẫn điểm nghi ngờ đều để trống', async () => {
    const { service } = dungGhi(null, [dongGps(null)]);

    const ket = await service.danhSach({});

    expect(ket.items[0]).toMatchObject({
      bookingCode: 'PC-001',
      sitterName: 'Nam',
      claimedDistanceKm: null,
      suspicionScore: null,
      totalDistanceM: 1000,
    });
  });

  it('sắp theo điểm thì đơn không có điểm dồn về cuối chứ không lẫn vào dải số', async () => {
    const { service, prisma } = dungGhi(null, [dongGps(3)]);

    await service.danhSach({ sort: 'suspicionScore', dir: 'desc' });

    expect(prisma.thuTuDaHoi[0]).toEqual({
      suspicionScore: { sort: 'desc', nulls: 'last' },
    });
  });
});
