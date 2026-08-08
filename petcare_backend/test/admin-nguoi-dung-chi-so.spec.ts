import { PrismaService } from '../src/prisma/prisma.service';
import { AdminUserDetailService } from '../src/modules/admin/users/admin-user-detail.service';

type SoLieu = {
  tongChi: number | null;
  soDonDaTra: number;
  soDanhGia: number;
  diemTrungBinh: number | null;
};

function dungService(so: SoLieu) {
  const prisma = {
    user: {
      findUnique: () =>
        Promise.resolve({
          id: 'u-1',
          fullName: 'Trần Thị Hoa',
          email: 'hoa@example.com',
          phone: '0901234567',
          role: 'OWNER',
          avatarUrl: null,
          isActive: true,
          isVerified: true,
          createdAt: new Date('2026-05-01T02:00:00+07:00'),
        }),
    },
    pet: { findMany: () => Promise.resolve([]) },
    address: { findMany: () => Promise.resolve([]) },
    booking: {
      findMany: () => Promise.resolve([]),
      count: () => Promise.resolve(0),
      aggregate: () =>
        Promise.resolve({
          _sum: { totalPrice: so.tongChi },
          _count: { _all: so.soDonDaTra },
        }),
    },
    review: {
      aggregate: () =>
        Promise.resolve({
          _count: { _all: so.soDanhGia },
          _avg: { rating: so.diemTrungBinh },
        }),
    },
    violationReport: {
      findMany: () => Promise.resolve([]),
      groupBy: () => Promise.resolve([]),
    },
  };
  return new AdminUserDetailService(prisma as unknown as PrismaService);
}

describe('Chỉ số người dùng: thiếu dữ liệu thì để trống', () => {
  it('chưa có đơn nào trả tiền thì trung bình mỗi đơn là null, không phải 0', async () => {
    const service = dungService({
      tongChi: null,
      soDonDaTra: 0,
      soDanhGia: 3,
      diemTrungBinh: 4.5,
    });
    const ket = await service.chiTiet('u-1');
    expect(ket.stats.totalSpent).toBe(0);
    expect(ket.stats.avgPerBooking).toBeNull();
  });

  it('chưa có đánh giá nào thì điểm trung bình là null, không phải 0', async () => {
    const service = dungService({
      tongChi: 900_000,
      soDonDaTra: 3,
      soDanhGia: 0,
      diemTrungBinh: null,
    });
    const ket = await service.chiTiet('u-1');
    expect(ket.stats.reviewCount).toBe(0);
    expect(ket.stats.avgRating).toBeNull();
  });

  it('có dữ liệu thì vẫn tính đúng trên số đơn đã trả tiền', async () => {
    const service = dungService({
      tongChi: 900_000,
      soDonDaTra: 3,
      soDanhGia: 2,
      diemTrungBinh: 4.5,
    });
    const ket = await service.chiTiet('u-1');
    expect(ket.stats.avgPerBooking).toBe(300_000);
    expect(ket.stats.avgRating).toBe(4.5);
  });
});
