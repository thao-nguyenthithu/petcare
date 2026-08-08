import { Injectable } from '@nestjs/common';
import { Prisma } from '../../../../generated/prisma/client';
import {
  BookingStatus,
  ReportStatus,
} from '../../../../generated/prisma/enums';
import { PrismaService } from '../../../prisma/prisma.service';
import { TRANG_THAI_HUY } from '../../bookings/booking-enums';
import { dungTrang, KetQuaTrang, kepTrang } from '../chung/phan-trang';
import { chonChieu, chonCot } from '../chung/sap-xep';
import { COT_SAP_XEP_DON, LocDonDto, TabDon } from './dto/loc-don.dto';

// Cộng thêm CANCELLED_UNPAID vì chỉ quản trị viên nhìn thấy nhánh đó, không thì nó tàng hình
const TAB_DA_HUY = [...TRANG_THAI_HUY, BookingStatus.CANCELLED_UNPAID];

// Bắt cả hai dấu hiệu: máy trạng thái có lối vào DISPUTED nên đơn ở đó phải có tab đứng
const CON_KHIEU_NAI: Prisma.BookingWhereInput = {
  OR: [
    { status: BookingStatus.DISPUTED },
    { reports: { some: { status: { not: ReportStatus.RESOLVED } } } },
  ],
};

function dieuKienTab(tab: TabDon): Prisma.BookingWhereInput {
  switch (tab) {
    case 'awaitingPayment':
      return { status: BookingStatus.AWAITING_PAYMENT };
    case 'pending':
      return { status: BookingStatus.PENDING };
    case 'confirmed':
      return { status: BookingStatus.CONFIRMED };
    case 'running':
      return { status: BookingStatus.IN_PROGRESS };
    case 'awaitingConfirm':
      return { status: BookingStatus.AWAITING_OWNER_CONFIRM };
    case 'completed':
      return {
        status: { in: [BookingStatus.COMPLETED, BookingStatus.RESOLVED] },
      };
    case 'cancelled':
      return { status: { in: TAB_DA_HUY } };
    case 'disputed':
      return CON_KHIEU_NAI;
    default:
      return {};
  }
}

@Injectable()
export class AdminBookingsReadService {
  constructor(private readonly prisma: PrismaService) {}

  private dieuKien(loc: LocDonDto): Prisma.BookingWhereInput {
    const dieu: Prisma.BookingWhereInput = {
      ...(loc.tab ? dieuKienTab(loc.tab) : {}),
    };
    if (loc.serviceType) dieu.service = { type: loc.serviceType };
    if (loc.from || loc.to) {
      dieu.scheduledAt = {
        ...(loc.from ? { gte: new Date(loc.from) } : {}),
        ...(loc.to ? { lte: new Date(loc.to) } : {}),
      };
    }
    if (loc.q) {
      const tim = { contains: loc.q, mode: Prisma.QueryMode.insensitive };
      // Gộp vào AND để không đè mất nhánh điều kiện của tab
      dieu.AND = [
        {
          OR: [
            { code: tim },
            { owner: { fullName: tim } },
            { sitter: { legalName: tim } },
            { sitter: { user: { fullName: tim } } },
          ],
        },
      ];
    }
    return dieu;
  }

  async danhSach(loc: LocDonDto): Promise<KetQuaTrang<unknown>> {
    const khoang = kepTrang(loc.page, loc.limit);
    const where = this.dieuKien(loc);
    const cot = chonCot(COT_SAP_XEP_DON, loc.sort, 'createdAt');
    const chieu = chonChieu(loc.dir, 'desc');

    const [total, ds] = await Promise.all([
      this.prisma.booking.count({ where }),
      this.prisma.booking.findMany({
        where,
        orderBy: { [cot]: chieu },
        skip: khoang.boQua,
        take: khoang.moiTrang,
        select: {
          code: true,
          status: true,
          scheduledAt: true,
          scheduledEndAt: true,
          durationMinutes: true,
          totalPrice: true,
          createdAt: true,
          owner: { select: { fullName: true } },
          sitter: {
            select: {
              ratingAvg: true,
              user: { select: { fullName: true } },
            },
          },
          service: { select: { name: true, type: true } },
          pets: { select: { pet: { select: { name: true } } } },
        },
      }),
    ]);

    const items = ds.map((d) => ({
      code: d.code,
      status: d.status,
      ownerName: d.owner.fullName,
      petNames: d.pets.map((p) => p.pet.name),
      sitterName: d.sitter.user.fullName,
      sitterRating: d.sitter.ratingAvg,
      serviceName: d.service.name,
      serviceType: d.service.type,
      durationMinutes: d.durationMinutes,
      scheduledAt: d.scheduledAt,
      scheduledEndAt: d.scheduledEndAt,
      totalPrice: d.totalPrice,
      createdAt: d.createdAt,
    }));
    return dungTrang(items, total, khoang);
  }

  // Tám tab đầu chỉ đọc cột status nên gộp một groupBy, chuông gọi lại theo nhịp màn
  async demTab() {
    const [theoTrangThai, disputed] = await Promise.all([
      this.prisma.booking.groupBy({ by: ['status'], _count: { _all: true } }),
      this.prisma.booking.count({ where: CON_KHIEU_NAI }),
    ]);
    const dem = (...ds: BookingStatus[]) =>
      theoTrangThai
        .filter((d) => ds.includes(d.status))
        .reduce((tong, d) => tong + d._count._all, 0);
    return {
      all: theoTrangThai.reduce((tong, d) => tong + d._count._all, 0),
      awaitingPayment: dem(BookingStatus.AWAITING_PAYMENT),
      pending: dem(BookingStatus.PENDING),
      confirmed: dem(BookingStatus.CONFIRMED),
      running: dem(BookingStatus.IN_PROGRESS),
      awaitingConfirm: dem(BookingStatus.AWAITING_OWNER_CONFIRM),
      completed: dem(BookingStatus.COMPLETED, BookingStatus.RESOLVED),
      cancelled: dem(...TAB_DA_HUY),
      disputed,
    };
  }
}
