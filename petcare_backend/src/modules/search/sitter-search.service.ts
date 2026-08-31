import { BadRequestException, Injectable } from '@nestjs/common';
import { Prisma, ServiceType } from '../../../generated/prisma/client';
import { khuVucHaiCap, lamTronToaDo } from '../../common/khu-vuc';
import { PrismaService } from '../../prisma/prisma.service';
import { SystemSettingsService } from '../admin/system-settings.service';
import {
  dieuKienNccCongKhai,
  TRUONG_USER_CONG_KHAI,
} from '../sitter/public/sitter-public';
import { SearchSittersDto } from './dto/search-sitters.dto';
import {
  coDiemMoc,
  coToaDo,
  dieuKienLoaiBe,
  dieuKienTuKhoa,
  doLech,
  doLechKinh,
  khoangNgay,
} from './sitter-search-dieu-kien';
import { demNgayKinCho, demNgayNghi, tinhTyLeHuy } from './sitter-search-lich';
import {
  coGoiGrooming,
  DIEM_TOI_THIEU_KHOI_NOI_BAT,
  diemDanhGiaCoTrongSo,
  diemDong,
  giaThapNhat,
  LUOT_TOI_THIEU,
  khoangCachKm,
  loaiBeEpTheoDichVu,
  soBeToiDa,
} from './sitter-search.helpers';

@Injectable()
export class SitterSearchService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly thamSo: SystemSettingsService,
  ) {}

  async search(dto: SearchSittersDto, userId?: string) {
    const banKinhToiDa = this.thamSo.so('search.radius_max_km');
    if (dto.radiusKm !== undefined && dto.radiusKm > banKinhToiDa) {
      throw new BadRequestException({
        code: 'VUOT_BAN_KINH_TOI_DA',
        message: `Bán kính tìm tối đa là ${banKinhToiDa} km`,
      });
    }
    const trang = dto.page ?? 1;
    const moiTrang = dto.limit ?? 20;
    const loaiDv = dto.service
      ? (dto.service.toUpperCase() as ServiceType)
      : undefined;

    const loaiBe = loaiBeEpTheoDichVu(loaiDv) ?? dto.species;

    const dieuKienDichVu: Prisma.SitterServiceWhereInput = {
      enabled: true,
      ...(loaiDv ? { type: loaiDv } : {}),
      ...dieuKienLoaiBe(loaiBe),
    };

    const where: Prisma.SitterWhereInput = {
      ...dieuKienNccCongKhai(),
      ...(userId ? { userId: { not: userId } } : {}),
      services: { some: dieuKienDichVu },
      ...(dto.minRating ? { ratingAvg: { gte: dto.minRating } } : {}),
      ...(dto.trusted ? { trustedBadge: true } : {}),
      ...(dto.q ? dieuKienTuKhoa(dto.q, dieuKienDichVu) : {}),
      ...(coToaDo(dto)
        ? {
            lat: {
              gte: dto.lat! - doLech(dto.radiusKm!),
              lte: dto.lat! + doLech(dto.radiusKm!),
            },
            lng: {
              gte: dto.lng! - doLechKinh(dto.radiusKm!, dto.lat!),
              lte: dto.lng! + doLechKinh(dto.radiusKm!, dto.lat!),
            },
          }
        : {}),
    };

    const ncc = await this.prisma.sitter.findMany({
      where,
      select: {
        id: true,
        userId: true,
        ratingAvg: true,
        totalReviews: true,
        trustedBadge: true,
        staticScore: true,
        createdAt: true,
        serviceAddress: true,
        lat: true,
        lng: true,
        user: { select: TRUONG_USER_CONG_KHAI },
        services: {
          where: dieuKienDichVu,
          select: { type: true, pricing: true },
        },
        photos: {
          orderBy: [{ sortOrder: 'asc' }, { createdAt: 'asc' }],
          take: 1,
          select: { url: true },
        },
      },
      take: moiTrang * trang + moiTrang,
      orderBy: [{ staticScore: 'desc' }, { createdAt: 'desc' }],
    });

    const nccIds = ncc.map((e) => e.id);
    const khoang = khoangNgay(dto);
    const [soDon, nghiTheoNcc, kinTheoNcc, tyLeHuy] = await Promise.all([
      this.prisma.booking.groupBy({
        by: ['sitterId'],
        where: { sitterId: { in: nccIds }, status: 'COMPLETED' },
        _count: { _all: true },
      }),
      demNgayNghi(this.prisma, nccIds, khoang),
      khoang
        ? demNgayKinCho(this.prisma, ncc, khoang, loaiDv)
        : Promise.resolve(new Map<string, number>()),
      tinhTyLeHuy(this.prisma, ncc, this.thamSo.so('penalty.window_days')),
    ]);
    const donTheoNcc = new Map(soDon.map((e) => [e.sitterId, e._count._all]));

    let ketQua = ncc.map((e) => {
      const dichVu = loaiDv
        ? e.services.filter((s) => s.type === loaiDv)
        : e.services;
      const giaTu = dichVu
        .map((s) => giaThapNhat(s.type, s.pricing, dto.package))
        .filter((g): g is number => g !== null)
        .sort((a, b) => a - b)[0];
      const nhanToiDa = dichVu
        .map((s) => soBeToiDa(s.pricing))
        .reduce<number | null>(
          (max, e) => (e === null || max === null ? null : Math.max(max, e)),
          0,
        );
      return {
        maxPets: nhanToiDa,
        availableDays: khoang
          ? Math.max(
              khoang.soNgay -
                (nghiTheoNcc.get(e.id) ?? 0) -
                (kinTheoNcc.get(e.id) ?? 0),
              0,
            )
          : 0,
        selectedDays: khoang?.soNgay ?? 0,
        cancelRate: tyLeHuy.get(e.id) ?? 0,
        id: e.id,
        fullName: e.user?.fullName ?? null,
        avatarUrl: e.user?.avatarUrl ?? null,
        photoUrl: e.photos[0]?.url ?? null,
        ratingAvg: e.ratingAvg,
        totalReviews: e.totalReviews,
        completedOrders: donTheoNcc.get(e.id) ?? 0,
        trusted: e.trustedBadge,
        staticScore: e.staticScore,
        createdAt: e.createdAt,
        area: khuVucHaiCap(e.serviceAddress),
        lat: lamTronToaDo(e.lat),
        lng: lamTronToaDo(e.lng),
        serviceTypes: dichVu.map((s) => s.type.toLowerCase()),
        priceFrom: giaTu ?? null,
        distanceKm:
          coDiemMoc(dto) && e.lat !== null && e.lng !== null
            ? Number(khoangCachKm(dto.lat!, dto.lng!, e.lat, e.lng).toFixed(2))
            : null,
      };
    });

    if (dto.package !== undefined && loaiDv === 'GROOMING') {
      const coGoi = new Set(
        ncc
          .filter((e) =>
            e.services.some(
              (s) =>
                s.type === 'GROOMING' && coGoiGrooming(s.pricing, dto.package!),
            ),
          )
          .map((e) => e.id),
      );
      ketQua = ketQua.filter((e) => coGoi.has(e.id));
    }

    if (coToaDo(dto)) {
      ketQua = ketQua.filter(
        (e) => e.distanceKm !== null && e.distanceKm <= dto.radiusKm!,
      );
    }
    if (dto.priceMin !== undefined) {
      ketQua = ketQua.filter(
        (e) => e.priceFrom !== null && e.priceFrom >= dto.priceMin!,
      );
    }
    if (dto.priceMax !== undefined) {
      ketQua = ketQua.filter(
        (e) => e.priceFrom !== null && e.priceFrom <= dto.priceMax!,
      );
    }
    if (dto.petCount !== undefined) {
      ketQua = ketQua.filter(
        (e) => e.maxPets === null || e.maxPets >= dto.petCount!,
      );
    }

    // Khối trang chủ khoe người làm tốt nên có cửa vào riêng (bộ luật mục 9)
    if (dto.sort === 'topRated') {
      ketQua = ketQua.filter(
        (e) =>
          e.totalReviews >= LUOT_TOI_THIEU &&
          diemDanhGiaCoTrongSo(e.ratingAvg, e.totalReviews) >=
            DIEM_TOI_THIEU_KHOI_NOI_BAT,
      );
    }

    ketQua.sort((a, b) => {
      switch (dto.sort ?? 'recommended') {
        case 'nearest':
          return (a.distanceKm ?? Infinity) - (b.distanceKm ?? Infinity);
        case 'completed':
          return b.completedOrders - a.completedOrders;
        case 'price':
          return (a.priceFrom ?? Infinity) - (b.priceFrom ?? Infinity);
        case 'cancelRate':
          return a.cancelRate - b.cancelRate;
        case 'rating':
        case 'topRated':
          return (
            diemDanhGiaCoTrongSo(b.ratingAvg, b.totalReviews) -
            diemDanhGiaCoTrongSo(a.ratingAvg, a.totalReviews)
          );
        case 'recommended':
        default:
          return (
            b.staticScore +
            diemDong(b, banKinhToiDa) -
            (a.staticScore + diemDong(a, banKinhToiDa))
          );
      }
    });

    const boQua = (trang - 1) * moiTrang;
    return {
      total: ketQua.length,
      page: trang,
      limit: moiTrang,
      items: ketQua
        .slice(boQua, boQua + moiTrang)
        .map(({ createdAt: _, ...con }) => con),
    };
  }
}
