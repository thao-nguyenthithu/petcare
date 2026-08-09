import { Injectable, Logger } from '@nestjs/common';
import { Cron } from '@nestjs/schedule';
import { PrismaService } from '../../prisma/prisma.service';
import { MUI_GIO_VN, homNayVn, ngayDb } from '../../common/thoi-gian-vn';

@Injectable()
export class UserCleanupService {
  private readonly logger = new Logger(UserCleanupService.name);

  constructor(private readonly prisma: PrismaService) {}

  @Cron('0 3 * * *', { timeZone: MUI_GIO_VN })
  async donNgayCaiRiengDaQua() {
    const ketQua = await this.prisma.sitterDaySetting.deleteMany({
      where: { date: { lt: ngayDb(homNayVn()) } },
    });
    if (ketQua.count > 0) {
      this.logger.log(`Đã dọn ${ketQua.count} bản ghi ngày cài riêng đã qua`);
    }
  }
}
