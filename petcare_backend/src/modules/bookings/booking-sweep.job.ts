import { Injectable, Logger } from '@nestjs/common';
import { Cron, CronExpression } from '@nestjs/schedule';
import { MOT_PHUT_MS } from '../../common/thoi-gian-vn';
import { PrismaService } from '../../prisma/prisma.service';
import { BookingChatService } from '../messaging/booking-chat.service';
import { BookingNotifyService } from '../notifications/booking-notify.service';
import { PHUT_QUA_HEN_NCC, PHUT_TU_HUY_NCC_CHUA_TOI } from './booking-cancel';
import {
  NO_SHOW_WAIT,
  PHUT_TU_HUY_KHONG_AI_BAT_DAU,
} from './booking-compensation';
import {
  LY_DO_HE_THONG_NCC_CHUA_TOI,
  LY_DO_KHONG_AI_BAT_DAU,
} from './booking-enums';
import { conGiuCho, mocGuiNguoiCham } from './booking-time';
import { PHAT_NCC_CHUA_TOI } from './sitter-penalty-rules';
import { SitterPenaltyService } from './sitter-penalty.service';

export const MOI_LUOT = 300;
const PHUT_NHAC_SAP_HET_GIO = 10;
const CO_DIEM_DON = ['WALKING', 'GROOMING'] as const;
@Injectable()
export class BookingSweepJob {
  private readonly logger = new Logger(BookingSweepJob.name);

  constructor(
    private readonly prisma: PrismaService,
    private readonly notify: BookingNotifyService,
    private readonly chat: BookingChatService,
    private readonly penalty: SitterPenaltyService,
  ) {}

  @Cron(CronExpression.EVERY_MINUTE)
  async quet() {
    const bayGio = Date.now();
    const [dsCho, dsDangCho] = await Promise.all([
      this.donChoTraLoi(),
      this.donDangCho(bayGio),
    ]);

    for (const don of dsCho) {
      if (conGiuCho(mocGuiNguoiCham(don), don.scheduledAt, bayGio)) continue;
      await this.chay(don.code, 'huỷ vì quá hạn nhận', () =>
        this.huyQuaHan(don.id),
      );
    }

    for (const don of dsDangCho) {
      const loai = don.service.type;
      const coDiemDon = (CO_DIEM_DON as readonly string[]).includes(loai);

      if (coDiemDon && !don.arrivedAt) {
        if (
          bayGio >=
          don.scheduledAt.getTime() + PHUT_TU_HUY_NCC_CHUA_TOI * MOT_PHUT_MS
        ) {
          await this.chay(don.code, 'huỷ vì người chăm chưa tới', () =>
            this.huyNccChuaToi(don.id, don.sitterId),
          );
        }
        continue;
      }

      const tuLuc = coDiemDon
        ? Math.max(don.scheduledAt.getTime(), don.arrivedAt?.getTime() ?? 0)
        : don.scheduledAt.getTime();

      if (bayGio >= tuLuc + PHUT_TU_HUY_KHONG_AI_BAT_DAU * MOT_PHUT_MS) {
        if (!coDiemDon && don.ownerArrivedAt) continue;
        await this.chay(don.code, 'khép vì phiên không bắt đầu', () =>
          this.khepKhongAiBatDau(don.id),
        );
        continue;
      }

      if (
        coDiemDon &&
        !don.arriveRemindedAt &&
        bayGio >= tuLuc + PHUT_NHAC_SAP_HET_GIO * MOT_PHUT_MS &&
        bayGio < tuLuc + NO_SHOW_WAIT * MOT_PHUT_MS
      ) {
        await this.chay(don.code, 'nhắc sắp hết giờ giao bé', () =>
          this.nhacSapHetGio(don.id),
        );
      }
    }
  }

  private async chay(code: string, viec: string, lam: () => Promise<void>) {
    try {
      await lam();
      this.logger.log(`Đơn ${code}: ${viec}`);
    } catch (loi) {
      this.logger.error(`Đơn ${code} khi ${viec} lỗi`, loi as Error);
    }
  }

  private async donChoTraLoi() {
    return this.prisma.booking.findMany({
      where: { status: 'PENDING' },
      orderBy: { scheduledAt: 'asc' },
      take: MOI_LUOT,
      select: {
        id: true,
        code: true,
        scheduledAt: true,
        createdAt: true,
        paidAt: true,
      },
    });
  }

  private async donDangCho(bayGio: number) {
    return this.prisma.booking.findMany({
      where: {
        status: 'CONFIRMED',
        scheduledAt: {
          lte: new Date(bayGio - PHUT_NHAC_SAP_HET_GIO * MOT_PHUT_MS),
        },
      },
      orderBy: { scheduledAt: 'asc' },
      take: MOI_LUOT,
      select: {
        id: true,
        code: true,
        sitterId: true,
        scheduledAt: true,
        arrivedAt: true,
        ownerArrivedAt: true,
        arriveRemindedAt: true,
        service: { select: { type: true } },
      },
    });
  }

  private async huyQuaHan(bookingId: string) {
    const daHuy = await this.prisma.$transaction(async (tx) => {
      const ketQua = await tx.booking.updateMany({
        where: { id: bookingId, status: 'PENDING' },
        data: {
          status: 'CANCELLED_EXPIRED',
          cancelledAt: new Date(),
          cancellationReason: 'Hết hạn chờ người chăm nhận đơn',
          cancellationFee: 0,
        },
      });
      if (ketQua.count === 0) return false;
      await tx.payment.updateMany({
        where: { bookingId, status: 'HELD' },
        data: { status: 'REFUNDING' },
      });
      return true;
    });
    if (!daHuy) return;
    await this.notify.donQuaHanNhan(bookingId);
    await this.chat.heThongHuyQuaHan(bookingId);
  }

  private async huyNccChuaToi(bookingId: string, sitterId: string | null) {
    const daHuy = await this.prisma.$transaction(async (tx) => {
      const ketQua = await tx.booking.updateMany({
        where: { id: bookingId, status: 'CONFIRMED', arrivedAt: null },
        data: {
          status: 'CANCELLED_BY_SITTER',
          cancelledAt: new Date(),
          cancellationReason: LY_DO_HE_THONG_NCC_CHUA_TOI,
          cancellationFee: 0,
          platformFee: 0,
        },
      });
      if (ketQua.count === 0) return false;
      await tx.payment.updateMany({
        where: { bookingId, status: 'HELD' },
        data: { status: 'REFUNDING' },
      });
      if (sitterId) {
        await this.penalty.ghiPhat(
          sitterId,
          bookingId,
          PHAT_NCC_CHUA_TOI,
          LY_DO_HE_THONG_NCC_CHUA_TOI,
          Date.now(),
          tx,
        );
      }
      return true;
    });
    if (!daHuy) return;
    await this.notify.donHuyViNccChuaToi(bookingId);
    await this.chat.heThongHuyViNccChuaToi(bookingId);
  }

  private async khepKhongAiBatDau(bookingId: string) {
    const daHuy = await this.prisma.$transaction(async (tx) => {
      const ketQua = await tx.booking.updateMany({
        where: { id: bookingId, status: 'CONFIRMED' },
        data: {
          status: 'CANCELLED_NO_SHOW',
          cancelledAt: new Date(),
          cancellationReason: LY_DO_KHONG_AI_BAT_DAU,
          cancellationFee: 0,
          platformFee: 0,
        },
      });
      if (ketQua.count === 0) return false;
      await tx.payment.updateMany({
        where: { bookingId, status: 'HELD' },
        data: { status: 'REFUNDING' },
      });
      return true;
    });
    if (!daHuy) return;
    await this.notify.donHuyViKhongAiBatDau(bookingId);
    await this.chat.heThongHuyViKhongAiBatDau(bookingId);
  }

  // Ghi mốc trước khi bắn tin và ghi có điều kiện để không nhắc hai lần
  private async nhacSapHetGio(bookingId: string) {
    const ketQua = await this.prisma.booking.updateMany({
      where: { id: bookingId, arriveRemindedAt: null },
      data: { arriveRemindedAt: new Date() },
    });
    if (ketQua.count === 0) return;
    await this.notify.sapHetGioGiaoBe(bookingId);
  }

  static readonly phutChuNuoiDuocBao = PHUT_QUA_HEN_NCC;
}
