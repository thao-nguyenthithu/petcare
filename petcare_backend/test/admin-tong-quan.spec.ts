import { AdminDashboardService } from '../src/modules/admin/dashboard/admin-dashboard.service';
import { AdminQueueService } from '../src/modules/admin/dashboard/admin-queue.service';
import {
  dauThangVn,
  dayKhoaThang,
  haiKy,
  khoaThangVn,
} from '../src/modules/admin/dashboard/dashboard-ky';

// Khoá tháng phải tính lúc chạy, chốt cứng '2026-08' là test tự rớt khi sang tháng mới
const KHOA_THANG_NAY = khoaThangVn(new Date());
import { PrismaService } from '../src/prisma/prisma.service';

type BanGhi = Record<string, unknown>;

const SO_RONG: BanGhi = {
  usersTotal: 0,
  usersTruoc: 0,
  sittersActive: 0,
  sittersPending: 0,
  bookingsNay: 0,
  bookingsTruoc: 0,
  bookingsOngoing: 0,
  revenueNay: 0,
  revenueTruoc: 0,
  commissionNay: 0,
  escrowHeld: 0,
};

// Nhận diện từng câu truy vấn bằng chữ chỉ nó mới có, vì cả bốn cùng đi qua $queryRaw
function nhanDang(sql: string): string {
  if (sql.includes('usersTotal')) return 'chiSo';
  if (sql.includes('date_trunc')) return 'theoThang';
  if (sql.includes('GROUP BY s."type"')) return 'coCau';
  return 'donGanDay';
}

function dungTongQuan(ket: Record<string, BanGhi[]>) {
  const luot: string[] = [];
  const prisma = {
    $queryRaw: (strings: TemplateStringsArray) => {
      const khoa = nhanDang(strings.join(' '));
      luot.push(khoa);
      return Promise.resolve(ket[khoa] ?? []);
    },
  };
  const service = new AdminDashboardService(prisma as unknown as PrismaService);
  return { service, luot };
}

function dungHangCho(dong: BanGhi) {
  const prisma = { $queryRaw: () => Promise.resolve([dong]) };
  return new AdminQueueService(prisma as unknown as PrismaService);
}

describe('Kỳ so sánh của màn tổng quan', () => {
  it('kỳ trước cắt đúng phần đã trôi, không tràn sang tháng này', () => {
    const { nay, truoc } = haiKy(new Date('2026-08-07T05:00:00.000Z'));

    expect(nay.tu.toISOString()).toBe('2026-07-31T17:00:00.000Z');
    expect(truoc.tu.toISOString()).toBe('2026-06-30T17:00:00.000Z');
    expect(truoc.den.getTime() - truoc.tu.getTime()).toBe(
      nay.den.getTime() - nay.tu.getTime(),
    );
  });

  it('tháng dài hơn tháng trước thì kỳ trước bị kẹp lại ở mùng 1', () => {
    const { nay, truoc } = haiKy(new Date('2026-03-31T10:00:00.000Z'));

    expect(truoc.den.getTime()).toBe(nay.tu.getTime());
  });

  it('dãy khoá tháng kết ở tháng đang chạy và đọc theo giờ Việt Nam', () => {
    const day = dayKhoaThang(new Date('2026-01-31T17:30:00.000Z'), 12);

    expect(day).toHaveLength(12);
    expect(day[11]).toBe('2026-02');
    expect(day[0]).toBe('2025-03');
  });

  it('mốc đầu tháng là 00:00 giờ Việt Nam chứ không phải 00:00 UTC', () => {
    expect(dauThangVn(new Date('2026-08-20T00:00:00.000Z')).toISOString()).toBe(
      '2026-07-31T17:00:00.000Z',
    );
  });
});

describe('Bốn chỉ số và hai biểu đồ của màn tổng quan', () => {
  it('cả màn chỉ tốn bốn lượt đi về database', async () => {
    const { service, luot } = dungTongQuan({ chiSo: [SO_RONG] });

    await service.tongQuan();

    expect(luot.sort()).toEqual(['chiSo', 'coCau', 'donGanDay', 'theoThang']);
  });

  it('kỳ trước không có gì thì mức so sánh là rỗng chứ không phải 0', async () => {
    const { service } = dungTongQuan({
      chiSo: [{ ...SO_RONG, usersTotal: 120, bookingsNay: 8, revenueNay: 900 }],
    });

    const ket = await service.tongQuan();

    expect(ket.users.delta).toBeNull();
    expect(ket.bookings.delta).toBeNull();
    expect(ket.revenue.delta).toBeNull();
  });

  it('kỳ trước có số thì trả phần trăm chênh lệch có dấu', async () => {
    const { service } = dungTongQuan({
      chiSo: [
        {
          ...SO_RONG,
          usersTotal: 120,
          usersTruoc: 100,
          bookingsNay: 5,
          bookingsTruoc: 10,
          revenueNay: 300,
          revenueTruoc: 300,
        },
      ],
    });

    const ket = await service.tongQuan();

    expect(ket.users.delta).toBe(20);
    expect(ket.bookings.delta).toBe(-50);
    expect(ket.revenue.delta).toBe(0);
  });

  it('thẻ người chăm để trống mức so sánh vì schema không lưu mốc duyệt', async () => {
    const { service } = dungTongQuan({
      chiSo: [{ ...SO_RONG, sittersActive: 386, sittersPending: 8 }],
    });

    const ket = await service.tongQuan();

    expect(ket.sitters).toEqual({ active: 386, pending: 8, delta: null });
  });

  it('SUM cột Int trả bigint, tiền ra API vẫn là số thường', async () => {
    const { service } = dungTongQuan({
      chiSo: [
        {
          ...SO_RONG,
          revenueNay: 428600000n,
          revenueTruoc: 214300000n,
          commissionNay: 64290000n,
          escrowHeld: 23100000n,
        },
      ],
      theoThang: [
        {
          khoa: KHOA_THANG_NAY,
          sitterPayout: 364310000n,
          platformFee: 64290000n,
        },
      ],
      donGanDay: [
        {
          code: 'PC6Q5MT3',
          status: 'IN_PROGRESS',
          totalPrice: 180000,
          durationMinutes: 60,
          ownerName: 'Trần Minh Anh',
          ownerPhone: '0912345678',
          serviceName: 'Dắt đi dạo',
        },
      ],
    });

    const ket = await service.tongQuan();

    expect(ket.revenue).toMatchObject({
      total: 428600000,
      commission: 64290000,
      escrowHeld: 23100000,
      delta: 100,
    });
    for (const v of Object.values(ket.revenue)) {
      expect(typeof v).toBe('number');
    }
    const thangNay = ket.revenueByMonth[ket.revenueByMonth.length - 1];
    expect(thangNay.sitterPayout).toBe(364310000);
    expect(typeof thangNay.platformFee).toBe('number');
    expect(ket.recentBookings[0].totalPrice).toBe(180000);
  });

  it('đơn chưa chốt giá thì để trống, không lấp bằng 0', async () => {
    const { service } = dungTongQuan({
      chiSo: [SO_RONG],
      donGanDay: [
        {
          code: 'PC8B2FD7',
          status: 'PENDING',
          totalPrice: null,
          durationMinutes: null,
          ownerName: 'Lê Thu Hà',
          ownerPhone: null,
          serviceName: 'Trông giữ',
        },
      ],
    });

    const ket = await service.tongQuan();

    expect(ket.recentBookings[0]).toMatchObject({
      totalPrice: null,
      durationMinutes: null,
      ownerPhone: null,
      status: 'PENDING',
    });
  });

  it('biểu đồ luôn đủ 12 cột, tháng không có đơn thì cột bằng 0', async () => {
    const { service } = dungTongQuan({
      chiSo: [SO_RONG],
      theoThang: [
        { khoa: KHOA_THANG_NAY, sitterPayout: 340000.4, platformFee: 60000.6 },
      ],
    });

    const ket = await service.tongQuan();
    const thangNay = ket.revenueByMonth[11];

    expect(ket.revenueByMonth).toHaveLength(12);
    expect(thangNay.sitterPayout + thangNay.platformFee).toBeGreaterThan(0);
    expect(ket.revenueByMonth[0]).toMatchObject({
      sitterPayout: 0,
      platformFee: 0,
    });
  });

  it('cơ cấu dịch vụ đủ ba lát theo thứ tự enum kể cả khi thiếu loại', async () => {
    const { service } = dungTongQuan({
      chiSo: [SO_RONG],
      coCau: [
        { type: 'GROOMING', count: 1 },
        { type: 'WALKING', count: 3 },
      ],
    });

    const ket = await service.tongQuan();

    expect(ket.serviceMix.map((m) => m.type)).toEqual([
      'WALKING',
      'BOARDING',
      'GROOMING',
    ]);
    expect(ket.serviceMix.map((m) => m.percent)).toEqual([75, 0, 25]);
  });
});

describe('Bốn dòng việc của chuông hàng chờ', () => {
  it('tổng bằng tổng bốn dòng và dòng đếm 0 vẫn giữ chỗ', async () => {
    const service = dungHangCho({
      sitterPending: 8,
      sitterOldest: new Date(Date.now() - 2 * 24 * 3600_000),
      disputeReview: 5,
      withdrawalPending: 0,
      penaltyReview: 1,
    });

    const ket = await service.danhSach();

    expect(ket.total).toBe(14);
    expect(ket.items.map((m) => m.key)).toEqual([
      'sitterPending',
      'disputeReview',
      'withdrawalPending',
      'penaltyReview',
    ]);
    expect(ket.items[2]).toMatchObject({
      count: 0,
      hint: 'Không còn lệnh rút nào chờ chuyển',
    });
  });

  it('dòng hồ sơ chờ duyệt nói rõ hồ sơ cũ nhất đã chờ mấy ngày', async () => {
    const service = dungHangCho({
      sitterPending: 3,
      sitterOldest: new Date(Date.now() - 5 * 24 * 3600_000 - 1000),
      disputeReview: 0,
      withdrawalPending: 0,
      penaltyReview: 0,
    });

    const ket = await service.danhSach();

    expect(ket.items[0].hint).toBe('Hồ sơ cũ nhất đã chờ 5 ngày');
  });

  it('hết sạch việc thì tổng bằng 0 và bốn dòng đều nói đã hết', async () => {
    const service = dungHangCho({
      sitterPending: 0,
      sitterOldest: null,
      disputeReview: 0,
      withdrawalPending: 0,
      penaltyReview: 0,
    });

    const ket = await service.danhSach();

    expect(ket.total).toBe(0);
    expect(ket.items.every((m) => m.hint.startsWith('Không còn'))).toBe(true);
  });
});
