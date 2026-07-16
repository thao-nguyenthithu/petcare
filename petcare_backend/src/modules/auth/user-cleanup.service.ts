import { Injectable, Logger } from '@nestjs/common';
import { Cron, CronExpression } from '@nestjs/schedule';
import { PrismaService } from 'src/prisma/prisma.service';

const UNVERIFIED_MAX_AGE_HOURS = 24;

// Dọn định kỳ các tài khoản chưa xác minh 
@Injectable()
export class UserCleanupService {
  private readonly logger = new Logger(UserCleanupService.name);

  constructor(private readonly prisma: PrismaService) {}

  @Cron(CronExpression.EVERY_DAY_AT_3AM)
  async donUserChuaXacMinh() {
    const nguong = new Date(
      Date.now() - UNVERIFIED_MAX_AGE_HOURS * 60 * 60 * 1000,
    );
    const ketQua = await this.prisma.user.deleteMany({
      where: { isVerified: false, createdAt: { lt: nguong } },
    });
    if (ketQua.count > 0) {
      this.logger.log(
        `Đã dọn ${ketQua.count} tài khoản chưa xác minh cũ hơn ${UNVERIFIED_MAX_AGE_HOURS} giờ`,
      );
    }
  }
}
