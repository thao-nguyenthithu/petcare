import { Injectable, NotFoundException } from '@nestjs/common';
import {
  BookingStatus,
  ReportStatus,
} from '../../../../generated/prisma/enums';
import { PrismaService } from '../../../prisma/prisma.service';
import {
  TRANG_THAI_DANG_CHAY,
  TRANG_THAI_DANG_MO,
  TRANG_THAI_DA_TRA_TIEN,
} from './admin-users.trang-thai';
import { gopDiaChi, nhanTuoi } from './admin-users.mapper';

const SO_DON_GAN_NHAT = 5;
const SO_HOAT_DONG = 8;

@Injectable()
export class AdminUserDetailService {
  constructor(private readonly prisma: PrismaService) {}

  async chiTiet(id: string) {
    const [user, pets, addresses, donGanNhat, thongKe, khieuNaiGanNhat] =
      await Promise.all([
        this.prisma.user.findUnique({
          where: { id },
          select: {
            id: true,
            fullName: true,
            email: true,
            phone: true,
            role: true,
            avatarUrl: true,
            isActive: true,
            isVerified: true,
            createdAt: true,
            sitter: { select: { status: true, bannedAt: true } },
          },
        }),
        this.prisma.pet.findMany({
          where: { ownerId: id },
          orderBy: { createdAt: 'desc' },
          select: {
            id: true,
            name: true,
            species: true,
            breed: true,
            birthDate: true,
            avatarUrl: true,
            isActive: true,
          },
        }),
        this.prisma.address.findMany({
          where: { userId: id },
          orderBy: [{ isDefault: 'desc' }, { createdAt: 'asc' }],
          select: {
            id: true,
            label: true,
            customLabel: true,
            street: true,
            ward: true,
            province: true,
            isDefault: true,
          },
        }),
        this.donGanNhat(id),
        this.thongKe(id),
        this.prisma.violationReport.findMany({
          where: { reporterId: id },
          orderBy: { createdAt: 'desc' },
          take: SO_DON_GAN_NHAT,
          select: { code: true, status: true, createdAt: true },
        }),
      ]);

    if (!user) {
      throw new NotFoundException({
        code: 'KHONG_TIM_THAY_NGUOI_DUNG',
        message: 'Không tìm thấy người dùng này',
      });
    }

    const diaChiMacDinh = addresses.find((dc) => dc.isDefault);
    const { sitter, ...hoSo } = user;
    return {
      user: {
        ...hoSo,
        defaultAddress: diaChiMacDinh ? gopDiaChi(diaChiMacDinh) : null,
        // Cột role không bao giờ mang PROVIDER, vai suy từ hồ sơ đã duyệt
        isSitter: sitter?.status === 'APPROVED' && sitter.bannedAt === null,
      },
      stats: thongKe,
      pets: pets.map((p) => ({
        id: p.id,
        name: p.name,
        species: p.species,
        breed: p.breed,
        ageLabel: nhanTuoi(p.birthDate),
        avatarUrl: p.avatarUrl,
        isActive: p.isActive,
      })),
      addresses: addresses.map((dc) => ({
        id: dc.id,
        label: dc.label,
        customLabel: dc.customLabel,
        text: gopDiaChi(dc),
        isDefault: dc.isDefault,
      })),
      recentBookings: donGanNhat,
      activities: this.hoatDong(donGanNhat, khieuNaiGanNhat),
    };
  }

  // Lấy theo LÔ id, không include lồng vì Prisma tách mỗi cấp thành một lượt
  private async donGanNhat(ownerId: string) {
    const ds = await this.prisma.booking.findMany({
      where: { ownerId, status: { not: BookingStatus.AWAITING_PAYMENT } },
      orderBy: { createdAt: 'desc' },
      take: SO_DON_GAN_NHAT,
      select: {
        id: true,
        code: true,
        createdAt: true,
        totalPrice: true,
        status: true,
        serviceId: true,
        sitterId: true,
      },
    });
    if (!ds.length) return [];

    const [dichVu, nguoiCham, beTheoDon] = await Promise.all([
      this.prisma.service.findMany({
        where: { id: { in: [...new Set(ds.map((d) => d.serviceId))] } },
        select: { id: true, name: true },
      }),
      this.prisma.sitter.findMany({
        where: { id: { in: [...new Set(ds.map((d) => d.sitterId))] } },
        select: { id: true, user: { select: { fullName: true } } },
      }),
      this.prisma.bookingPet.findMany({
        where: { bookingId: { in: ds.map((d) => d.id) } },
        select: { bookingId: true, pet: { select: { name: true } } },
      }),
    ]);

    const tenDichVu = new Map(dichVu.map((d) => [d.id, d.name]));
    const tenNguoiCham = new Map(nguoiCham.map((s) => [s.id, s.user.fullName]));
    const tenBe = new Map<string, string[]>();
    for (const dong of beTheoDon) {
      const cu = tenBe.get(dong.bookingId) ?? [];
      cu.push(dong.pet.name);
      tenBe.set(dong.bookingId, cu);
    }

    return ds.map((d) => ({
      code: d.code,
      createdAt: d.createdAt,
      serviceName: tenDichVu.get(d.serviceId) ?? null,
      petNames: (tenBe.get(d.id) ?? []).join(', '),
      sitterName: tenNguoiCham.get(d.sitterId) ?? null,
      totalPrice: d.totalPrice,
      status: d.status,
    }));
  }

  private async thongKe(id: string) {
    const [soDon, donDangMo, donDangChay, daChi, danhGia, khieuNai] =
      await Promise.all([
        this.prisma.booking.count({
          where: {
            ownerId: id,
            status: { not: BookingStatus.AWAITING_PAYMENT },
          },
        }),
        this.prisma.booking.count({
          where: { ownerId: id, status: { in: TRANG_THAI_DANG_MO } },
        }),
        // Đơn sẽ treo nếu khoá tài khoản, đếm cả hai vai
        this.prisma.booking.count({
          where: {
            status: { in: TRANG_THAI_DANG_CHAY },
            OR: [{ ownerId: id }, { sitter: { userId: id } }],
          },
        }),
        this.prisma.booking.aggregate({
          where: {
            ownerId: id,
            payments: { some: { status: { in: TRANG_THAI_DA_TRA_TIEN } } },
          },
          _sum: { totalPrice: true },
          _count: { _all: true },
        }),
        this.prisma.review.aggregate({
          where: { reviewerId: id },
          _count: { _all: true },
          _avg: { rating: true },
        }),
        this.prisma.violationReport.groupBy({
          by: ['status'],
          where: { reporterId: id },
          _count: { _all: true },
        }),
      ]);

    const tongChi = daChi._sum.totalPrice ?? 0;
    const soDonDaTra = daChi._count._all;
    return {
      bookingCount: soDon,
      openBookingCount: donDangMo,
      runningBookingCount: donDangChay,
      totalSpent: tongChi,
      // Chưa có đơn trả tiền hay chưa có đánh giá thì để trống, số 0 là nói dối
      avgPerBooking: soDonDaTra ? Math.round(tongChi / soDonDaTra) : null,
      reviewCount: danhGia._count._all,
      avgRating: danhGia._avg.rating,
      disputeCount: khieuNai.reduce((tong, d) => tong + d._count._all, 0),
      resolvedDisputeCount:
        khieuNai.find((d) => d.status === ReportStatus.RESOLVED)?._count._all ??
        0,
    };
  }

  // Không có bảng phiên đăng nhập nên nhật ký chỉ dựng từ việc đã có thật
  private hoatDong(
    don: Array<{ code: string; createdAt: Date; serviceName: string | null }>,
    khieuNai: Array<{ code: string; createdAt: Date }>,
  ) {
    const muc = [
      ...don.map((d) => ({
        kind: 'BOOKING' as const,
        title: 'Tạo đơn đặt lịch',
        detail: [d.code, d.serviceName].filter(Boolean).join(' · '),
        at: d.createdAt,
      })),
      ...khieuNai.map((k) => ({
        kind: 'DISPUTE' as const,
        title: 'Gửi khiếu nại',
        detail: k.code,
        at: k.createdAt,
      })),
    ];
    return muc
      .sort((a, b) => b.at.getTime() - a.at.getTime())
      .slice(0, SO_HOAT_DONG);
  }
}
