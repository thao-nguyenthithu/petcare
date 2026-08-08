import { ConflictException, Injectable, Logger } from '@nestjs/common';
import { BookingStatus } from 'generated/prisma/enums';
import { MOT_NGAY_MS } from '../../../common/thoi-gian-vn';
import { PrismaService } from '../../../prisma/prisma.service';
import { LY_DO_HUY_NCC_BAN } from '../../bookings/booking-enums';
import { conGiuCho, mocGuiNguoiCham } from '../../bookings/booking-time';
import { SitterSlotsService } from '../../bookings/sitter-slots.service';
import { BookingChatService } from '../../messaging/booking-chat.service';
import { BookingNotifyService } from '../../notifications/booking-notify.service';
import {
  DonTrenLich,
  chongGio,
  hetCuaNhan,
  loaiCuaDon,
  vuotSucChua,
} from './sitter-lich-trung';
import { DonMayTrangThai } from './sitter-order-store.service';

const NGAY_DOC_QUANH = 40;

const DA_NHAN: BookingStatus[] = [
  'CONFIRMED',
  'IN_PROGRESS',
  'AWAITING_OWNER_CONFIRM',
];

const CHON_LICH = {
  id: true,
  status: true,
  createdAt: true,
  paidAt: true,
  scheduledAt: true,
  scheduledEndAt: true,
  durationMinutes: true,
  service: { select: { type: true, durationMinutes: true } },
  _count: { select: { pets: true } },
};

@Injectable()
export class SitterLichService {
  private readonly logger = new Logger(SitterLichService.name);

  constructor(
    private readonly prisma: PrismaService,
    private readonly slots: SitterSlotsService,
    private readonly notify: BookingNotifyService,
    private readonly chat: BookingChatService,
  ) {}

  async donCungLich(
    don: DonMayTrangThai,
  ): Promise<{ daNhan: DonTrenLich[]; dangCho: DonTrenLich[] }> {
    const tu = new Date(
      don.scheduledAt.getTime() - NGAY_DOC_QUANH * MOT_NGAY_MS,
    );
    const den = new Date(
      (don.scheduledEndAt ?? don.scheduledAt).getTime() +
        NGAY_DOC_QUANH * MOT_NGAY_MS,
    );
    const ds = await this.prisma.booking.findMany({
      where: {
        sitterId: don.sitterId,
        id: { not: don.id },
        status: { in: [...DA_NHAN, 'PENDING'] },
        scheduledAt: { gte: tu, lte: den },
      },
      select: CHON_LICH,
    });
    const bayGio = Date.now();
    return {
      daNhan: ds.filter((d) => d.status !== 'PENDING'),
      dangCho: ds.filter(
        (d) =>
          d.status === 'PENDING' &&
          conGiuCho(mocGuiNguoiCham(d), d.scheduledAt, bayGio),
      ),
    };
  }

  async chanTrungLich(don: DonMayTrangThai, daNhan: DonTrenLich[]) {
    const dangXet = await this.doiSangDonTrenLich(don);
    if (loaiCuaDon(dangXet) === 'boarding') {
      const sucChua = await this.slots.sucChuaTrongGiu(don.sitterId);
      const kyDaNhan = daNhan.filter((d) => loaiCuaDon(d) === 'boarding');
      if (vuotSucChua(dangXet, kyDaNhan, sucChua)) {
        throw new ConflictException({
          code: 'HET_CHO_TRONG_GIU',
          message: `Bạn chỉ nhận được ${sucChua} bé mỗi đêm, các đêm của đơn này đã kín chỗ`,
        });
      }
      return;
    }
    const trung = daNhan.find(
      (d) => loaiCuaDon(d) !== 'boarding' && chongGio(dangXet, d),
    );
    if (trung) {
      throw new ConflictException({
        code: 'TRUNG_LICH_DON_KHAC',
        message: 'Khung giờ này bạn đã nhận một đơn khác',
      });
    }
  }

  async donDepDonChoChet(vuaNhan: DonMayTrangThai, dangCho: DonTrenLich[]) {
    if (dangCho.length === 0) return;
    const dangXet = await this.doiSangDonTrenLich(vuaNhan);
    const { daNhan } = await this.donCungLich(vuaNhan);
    const coTrongGiu =
      loaiCuaDon(dangXet) === 'boarding' ||
      dangCho.some((d) => loaiCuaDon(d) === 'boarding');
    const sucChua = coTrongGiu
      ? await this.slots.sucChuaTrongGiu(vuaNhan.sitterId)
      : 0;
    for (const ung of dangCho) {
      if (!hetCuaNhan(ung, dangXet, [...daNhan, dangXet], sucChua)) continue;
      try {
        await this.huyViNccBan(ung.id);
      } catch (loi) {
        this.logger.error(
          `Huỷ đơn chờ ${ung.id} theo lịch bận lỗi`,
          loi as Error,
        );
      }
    }
  }

  private async huyViNccBan(bookingId: string) {
    const ketQua = await this.prisma.$transaction(async (tx) => {
      const kq = await tx.booking.updateMany({
        // Điều kiện status nằm trong lệnh update để cron chạy cùng lúc vô hại
        where: { id: bookingId, status: 'PENDING' },
        data: {
          status: 'CANCELLED_EXPIRED',
          cancelledAt: new Date(),
          cancellationReason: LY_DO_HUY_NCC_BAN,
          cancellationFee: 0,
        },
      });
      if (kq.count === 0) return 0;
      await tx.payment.updateMany({
        where: { bookingId, status: 'HELD' },
        data: { status: 'REFUNDING' },
      });
      return kq.count;
    });
    if (ketQua === 0) return;
    await this.notify.donHuyViNccBan(bookingId);
    await this.chat.heThongHuyViNccBan(bookingId);
  }

  private async doiSangDonTrenLich(don: DonMayTrangThai): Promise<DonTrenLich> {
    const day = await this.prisma.booking.findUniqueOrThrow({
      where: { id: don.id },
      select: CHON_LICH,
    });
    return day;
  }
}
