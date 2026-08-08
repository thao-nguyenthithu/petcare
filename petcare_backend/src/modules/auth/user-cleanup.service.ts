import { Injectable, Logger } from '@nestjs/common';
import { Cron, CronExpression } from '@nestjs/schedule';
import { PrismaService } from '../../prisma/prisma.service';
import { homNayVn, ngayDb } from '../../common/thoi-gian-vn';

@Injectable()
export class UserCleanupService {
  private readonly logger = new Logger(UserCleanupService.name);

  constructor(private readonly prisma: PrismaService) {}

  @Cron(CronExpression.EVERY_DAY_AT_3AM)
  async donNgayCaiRiengDaQua() {
    const ketQua = await this.prisma.sitterDaySetting.deleteMany({
      where: { date: { lt: ngayDb(homNayVn()) } },
    });
    if (ketQua.count > 0) {
      this.logger.log(`Đã dọn ${ketQua.count} bản ghi ngày cài riêng đã qua`);
    }
  }
}
