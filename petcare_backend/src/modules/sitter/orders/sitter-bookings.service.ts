import { Injectable } from '@nestjs/common';
import { Prisma } from 'generated/prisma/client';
import { PrismaService } from '../../../prisma/prisma.service';
import { LOAI_RA_DB, TRANG_THAI_AN } from '../../bookings/booking-enums';
import {
  conGiuCho,
  hanNhanDonCua,
  mocGuiNguoiCham,
} from '../../bookings/booking-time';
import { AnhKyService } from '../../media/anh-ky.service';
import { ListSitterBookingsDto, NhomDonNccDto } from './dto/sitter-order.dto';
import { anhCuaDon, raChiTiet, raDong } from './sitter-booking-detail.mapper';
import {
  CHON_CHI_TIET,
  CHON_DONG,
  MOI_TRANG_MAC_DINH,
  NHOM_TRANG_THAI,
} from './sitter-booking-select';
import { layNccCuaToi, khongTimThayDon } from './sitter-guard';
import { SitterPenaltyService } from '../../bookings/sitter-penalty.service';

// Chỉ còn trình tự truy vấn; bảng cột ở sitter-booking-select, payload ở mapper

// Trần đọc đơn chờ trước khi xếp theo hạn trong bộ nhớ
const TRAN_DOC_DON_CHO = 50;

@Injectable()
export class SitterBookingsService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly penalty: SitterPenaltyService,
    private readonly kyAnh: AnhKyService,
  ) {}

  async danhSach(userId: string, dto: ListSitterBookingsDto) {
    const trang = dto.page ?? 1;
    const moiTrang = dto.limit ?? MOI_TRANG_MAC_DINH;
    if (dto.status === 'pending') {
      return this.donChoTraLoi(userId, dto, trang, moiTrang);
    }
    const dieuKien: Prisma.BookingWhereInput = {
      sitter: { userId },
      ...(dto.status
        ? { status: { in: NHOM_TRANG_THAI[dto.status] } }
        : { status: { notIn: TRANG_THAI_AN } }),
      ...(dto.serviceType
        ? { service: { type: LOAI_RA_DB[dto.serviceType] } }
        : {}),
    };
    const [, tong, dons] = await Promise.all([
      layNccCuaToi(this.prisma, userId),
      this.prisma.booking.count({ where: dieuKien }),
      this.prisma.booking.findMany({
        where: dieuKien,
        orderBy: { scheduledAt: this.chieuSap(dto.status) },
        skip: (trang - 1) * moiTrang,
        take: moiTrang,
        select: CHON_DONG,
      }),
    ]);
    const conHan = dons.filter(
      (d) =>
        d.status !== 'PENDING' ||
        conGiuCho(mocGuiNguoiCham(d), d.scheduledAt, Date.now()),
    );
    return {
      items: conHan.map((d) => raDong(d)),
      total: tong - (dons.length - conHan.length),
      page: trang,
      limit: moiTrang,
    };
  }

  private async donChoTraLoi(
    userId: string,
    dto: ListSitterBookingsDto,
    trang: number,
    moiTrang: number,
  ) {
    const [, dons] = await Promise.all([
      layNccCuaToi(this.prisma, userId),
      this.prisma.booking.findMany({
        where: {
          sitter: { userId },
          status: { in: NHOM_TRANG_THAI.pending },
          ...(dto.serviceType
            ? { service: { type: LOAI_RA_DB[dto.serviceType] } }
            : {}),
        },
        orderBy: { scheduledAt: 'asc' },
        take: TRAN_DOC_DON_CHO,
        select: CHON_DONG,
      }),
    ]);
    const conHan = dons
      .filter((d) => conGiuCho(mocGuiNguoiCham(d), d.scheduledAt, Date.now()))
      .sort((a, b) => hanNhanDonCua(a).getTime() - hanNhanDonCua(b).getTime());
    return {
      items: conHan
        .slice((trang - 1) * moiTrang, trang * moiTrang)
        .map((d) => raDong(d)),
      total: conHan.length,
      page: trang,
      limit: moiTrang,
    };
  }

  // Tách khỏi GET /sitter/home để in một dòng chữ không phải kéo về cả dashboard
  async tomTat(userId: string) {
    const ncc = await layNccCuaToi(this.prisma, userId);
    const bayGio = new Date();
    const [cho, ke] = await Promise.all([
      this.prisma.booking.findMany({
        where: { sitterId: ncc.id, status: 'PENDING' },
        select: { scheduledAt: true, paidAt: true, createdAt: true },
      }),
      this.prisma.booking.findFirst({
        where: {
          sitterId: ncc.id,
          status: 'CONFIRMED',
          scheduledAt: { gte: bayGio },
        },
        orderBy: { scheduledAt: 'asc' },
        select: { scheduledAt: true },
      }),
    ]);
    return {
      pendingCount: cho.filter((d) =>
        conGiuCho(mocGuiNguoiCham(d), d.scheduledAt, bayGio.getTime()),
      ).length,
      nextStartAt: ke?.scheduledAt.toISOString() ?? null,
    };
  }

  async chiTiet(userId: string, id: string) {
    const ncc = await layNccCuaToi(this.prisma, userId);
    const don = await this.prisma.booking.findFirst({
      where: { id, sitterId: ncc.id, status: { notIn: TRANG_THAI_AN } },
      select: CHON_CHI_TIET,
    });
    if (!don) khongTimThayDon();
    const [soDonChuNuoi, uyTin, ky] = await Promise.all([
      this.prisma.booking.count({ where: { ownerId: don.owner.id } }),
      this.penalty.hoSoUyTin(ncc.id),
      this.kyAnh.kyLo(anhCuaDon(don)),
    ]);
    return raChiTiet(don, soDonChuNuoi, uyTin, ky);
  }

  private chieuSap(nhom?: NhomDonNccDto): Prisma.SortOrder {
    return nhom === 'completed' || nhom === 'cancelled' ? 'desc' : 'asc';
  }
}
