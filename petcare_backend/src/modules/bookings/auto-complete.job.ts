import { Injectable, Logger } from '@nestjs/common';
import { Cron, CronExpression } from '@nestjs/schedule';
import { PrismaService } from '../../prisma/prisma.service';
import { SitterScoreService } from '../search/sitter-score.service';

export const MOI_LUOT = 50;
@Injectable()
export class AutoCompleteJob {
  private readonly logger = new Logger(AutoCompleteJob.name);

  constructor(
    private readonly prisma: PrismaService,
    private readonly diem: SitterScoreService,
  ) {}

  @Cron(CronExpression.EVERY_10_MINUTES)
  async quet() {
    const bayGio = new Date();
    const dsDon = await this.prisma.booking.findMany({
      where: {
        status: 'AWAITING_OWNER_CONFIRM',
        escrowReleaseAt: { lte: bayGio },
      },
      orderBy: { escrowReleaseAt: 'asc' },
      take: MOI_LUOT,
      select: { id: true, code: true, sitterId: true },
    });
    for (const don of dsDon) {
      try {
        const ketQua = await this.prisma.booking.updateMany({
          where: { id: don.id, status: 'AWAITING_OWNER_CONFIRM' },
          data: { status: 'COMPLETED', completedAt: new Date() },
        });
        if (ketQua.count === 0) continue;
        this.logger.log(`Đơn ${don.code} tự hoàn thành khi hết hạn xác nhận`);
        if (don.sitterId) await this.diem.tinhLai(don.sitterId);
      } catch (loi) {
        this.logger.error(`Tự chốt đơn ${don.code} lỗi`, loi as Error);
      }
    }
  }
}
