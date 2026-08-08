import { Injectable, Logger } from '@nestjs/common';
import { Cron, CronExpression } from '@nestjs/schedule';
import { PrismaService } from '../../prisma/prisma.service';
import { gioGiuTienCuaDon } from '../bookings/booking-compensation';
import { TRANG_THAI_HUY } from '../bookings/booking-enums';
import { BookingChatService } from '../messaging/booking-chat.service';
import { WalletLedgerService } from './wallet-ledger.service';
import { khoanNccNhan } from './wallet-booking.mapper';

@Injectable()
export class EscrowReleaseJob {
  private readonly logger = new Logger(EscrowReleaseJob.name);

  constructor(
    private readonly prisma: PrismaService,
    private readonly ledger: WalletLedgerService,
    private readonly chat: BookingChatService,
  ) {}

  @Cron(CronExpression.EVERY_10_MINUTES)
  async quet() {
    const bayGio = new Date();
    const dsDon = await this.prisma.booking.findMany({
      where: {
        escrowReleaseAt: { lte: bayGio },
        payments: { some: { status: 'HELD' } },
        reports: { none: { status: { not: 'RESOLVED' } } },
      },
      select: {
        id: true,
        code: true,
        status: true,
        sitterPayout: true,
        totalPrice: true,
        platformFee: true,
        endedAt: true,
        escrowReleaseAt: true,
      },
      take: 50,
    });
    for (const don of dsDon) {
      try {
        const daNha = await this.ledger.nhaEscrow(don.id);
        if (daNha) {
          this.logger.log(`Đã nhả tiền đơn ${don.code} vào ví người chăm`);
          if (!TRANG_THAI_HUY.includes(don.status)) {
            await this.chat.daXacNhanHoanThanh(
              don.id,
              khoanNccNhan(don),
              gioGiuTienCuaDon(don),
            );
          }
        }
      } catch (loi) {
        this.logger.error(`Nhả tiền đơn ${don.code} lỗi`, loi as Error);
      }
    }
  }
}
