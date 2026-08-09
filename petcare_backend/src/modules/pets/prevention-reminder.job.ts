import { Injectable, Logger } from '@nestjs/common';
import { Cron } from '@nestjs/schedule';
import {
  MUI_GIO_VN,
  homNayVn,
  ngayDb,
  themNgay,
} from '../../common/thoi-gian-vn';
import { PrismaService } from '../../prisma/prisma.service';
import { PreventionNotifyService } from '../notifications/prevention-notify.service';

export const MOC_NHAC = [7, 3, 1];
export const MOI_LUOT = 500;
@Injectable()
export class PreventionReminderJob {
  private readonly logger = new Logger(PreventionReminderJob.name);

  constructor(
    private readonly prisma: PrismaService,
    private readonly notify: PreventionNotifyService,
  ) {}

  @Cron('0 8 * * *', { timeZone: MUI_GIO_VN })
  async quet() {
    const homNay = homNayVn();
    const dsMui = await this.prisma.preventionDose.findMany({
      where: {
        nextDueAt: {
          gte: ngayDb(themNgay(homNay, 1)),
          lte: ngayDb(themNgay(homNay, MOC_NHAC[0])),
        },
      },
      take: MOI_LUOT,
      select: {
        id: true,
        nextDueAt: true,
        remindedDays: true,
        record: {
          select: {
            code: true,
            customName: true,
            pet: { select: { name: true, ownerId: true, isActive: true } },
          },
        },
      },
    });

    for (const mui of dsMui) {
      const be = mui.record.pet;
      if (!be.isActive || !mui.nextDueAt) continue;
      const conMayNgay = this.soNgayToiHan(homNay, mui.nextDueAt);
      const moc = MOC_NHAC.find((m) => m === conMayNgay);
      if (moc === undefined || mui.remindedDays.includes(moc)) continue;
      try {
        await this.notify.toiHan(
          be.ownerId,
          be.name,
          mui.record.customName ?? mui.record.code,
          moc,
        );
        await this.prisma.preventionDose.update({
          where: { id: mui.id },
          data: { remindedDays: { push: moc } },
        });
      } catch (loi) {
        this.logger.error(`Nhắc phòng bệnh mũi ${mui.id} lỗi`, loi as Error);
      }
    }
  }

  private soNgayToiHan(homNay: string, han: Date): number {
    const khoaHan = han.toISOString().slice(0, 10);
    return Math.round(
      (Date.parse(`${khoaHan}T00:00:00Z`) - Date.parse(`${homNay}T00:00:00Z`)) /
        86_400_000,
    );
  }
}
