import { ServiceType } from '../generated/prisma/enums';
import { AdminSittersReadService } from '../src/modules/admin/sitters/admin-sitters-read.service';
import { AdminPenaltiesService } from '../src/modules/admin/sitters/admin-penalties.service';
import { SitterPenaltyService } from '../src/modules/bookings/sitter-penalty.service';
import { SupabaseService } from '../src/modules/media/supabase.service';
import { PrismaService } from '../src/prisma/prisma.service';

type BanGhi = Record<string, unknown>;

function dungDoc(services: BanGhi[]) {
  const prisma: BanGhi = {
    sitter: {
      findUnique: () =>
        Promise.resolve({
          id: 'ncc-1',
          userId: 'u-1',
          legalName: 'Trịnh Văn Nam',
          status: 'APPROVED',
          hiddenUntil: null,
          hiddenCount: 0,
          bannedAt: null,
          ratingAvg: 4.8,
          totalReviews: 20,
          cccdFrontPath: null,
          cccdBackPath: null,
          user: {
            fullName: 'Nam Trịnh',
            email: 'nam@example.com',
            phone: null,
            createdAt: new Date('2026-05-01T02:00:00Z'),
            avatarUrl: null,
          },
          services,
        }),
    },
    booking: { count: () => Promise.resolve(0) },
    sitterPenalty: { findMany: () => Promise.resolve([]) },
    adminAuditLog: { findFirst: () => Promise.resolve(null) },
  };

  return new AdminSittersReadService(
    prisma as unknown as PrismaService,
    {
      hoSoUyTin: () => Promise.resolve({ tyLeHuy: null }),
    } as unknown as SitterPenaltyService,
    {
      soLanAnTrongCuaSo: () => Promise.resolve(0),
    } as unknown as AdminPenaltiesService,
    {} as unknown as SupabaseService,
  );
}

function motDichVu(type: ServiceType, pricing: BanGhi): BanGhi {
  return { type, enabled: true, petKind: 'DOG', pricing };
}

describe('Hồ sơ người chăm trả bảng giá cùng hình dạng với danh sách cấu hình', () => {
  it('dắt đi dạo mang nhãn type, cắt số lẻ và bỏ mức thời lượng lạ', async () => {
    const doc = dungDoc([
      motDichVu(ServiceType.WALKING, {
        priceByDuration: { 30: 100000.7, 60: 0, 90: 200000 },
        additionalPetFee: 40000,
        maxPets: 2,
        khoaLa: 'gia tri thua',
      }),
    ]);

    const ket = await doc.chiTiet('ncc-1');

    expect(ket.services[0].pricing).toEqual({
      type: 'WALKING',
      priceByDuration: { '30': 100000 },
      additionalPetFee: 40000,
      maxPets: 2,
    });
  });

  it('trông giữ trả kèm sức chứa, không để cột Json lọt nguyên văn ra ngoài', async () => {
    const doc = dungDoc([
      motDichVu(ServiceType.BOARDING, {
        pricePerDay: 320000.6,
        capacity: 4,
        additionalPetFee: 49999.4,
        maxPets: 2,
      }),
    ]);

    const ket = await doc.chiTiet('ncc-1');

    expect(ket.services[0].pricing).toEqual({
      type: 'BOARDING',
      pricePerDay: 320000,
      capacity: 4,
      additionalPetFee: 49999,
      maxPets: 2,
    });
  });

  it('grooming trả thời lượng và bỏ hẳn phụ phí bé thêm của loại khác', async () => {
    const doc = dungDoc([
      motDichVu(ServiceType.GROOMING, {
        priceByPackage: { bath: { duoi5: 180000, canLa: 90000 } },
        durationByPackage: { bath: { duoi5: 60 } },
        additionalPetFee: 50000,
        maxPets: 1,
      }),
    ]);

    const ket = await doc.chiTiet('ncc-1');

    expect(ket.services[0].pricing).toEqual({
      type: 'GROOMING',
      priceByPackage: { bath: { duoi5: 180000 } },
      durationByPackage: { bath: { duoi5: 60 } },
      maxPets: 1,
    });
  });

  it('người chăm chưa khai gì thì vẫn có nhãn type để màn phân nhánh được', async () => {
    const doc = dungDoc([motDichVu(ServiceType.BOARDING, {})]);

    const ket = await doc.chiTiet('ncc-1');

    expect(ket.services[0].pricing).toMatchObject({
      type: 'BOARDING',
      pricePerDay: null,
      maxPets: null,
    });
  });

  it('giữ nguyên loại thú cưng và trạng thái bật của từng dịch vụ', async () => {
    const doc = dungDoc([
      {
        type: ServiceType.WALKING,
        enabled: false,
        petKind: 'BOTH',
        pricing: {},
      },
    ]);

    const ket = await doc.chiTiet('ncc-1');

    expect(ket.services[0]).toMatchObject({
      type: ServiceType.WALKING,
      enabled: false,
      petKind: 'BOTH',
    });
  });
});
