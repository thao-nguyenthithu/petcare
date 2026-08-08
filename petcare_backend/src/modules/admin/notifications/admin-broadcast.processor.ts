import { OnWorkerEvent, Processor, WorkerHost } from '@nestjs/bullmq';
import { Logger } from '@nestjs/common';
import { Job } from 'bullmq';
import { NotificationType } from '../../../../generated/prisma/enums';
import { PrismaService } from '../../../prisma/prisma.service';
import { FirebaseService } from '../../firebase/firebase.service';
import { NOTIFICATION_QUEUE } from '../../notifications/notifications.module';
import {
  CO_LO_NGUOI_NHAN,
  TRAN_SO_LO,
  VIEC_GUI_THONG_BAO,
  ViecGuiThongBao,
} from './admin-notifications.constants';
import { lopNguoiNhan, LopNguoiNhan, NhomNguoiNhan } from './nguoi-nhan';

type LuotGui = {
  id: string;
  title: string;
  body: string;
  urgent: boolean;
  audienceKind: string;
  audienceValue: string | null;
  role: LopNguoiNhan['role'];
};

// Gửi theo lô: một lượt tới cả nền tảng mà ghi từng tin là hàng nghìn lượt đi về
@Processor(NOTIFICATION_QUEUE)
export class AdminBroadcastProcessor extends WorkerHost {
  private readonly logger = new Logger(AdminBroadcastProcessor.name);

  constructor(
    private readonly prisma: PrismaService,
    private readonly firebase: FirebaseService,
  ) {
    super();
  }

  async process(job: Job<ViecGuiThongBao>) {
    if (job.name !== VIEC_GUI_THONG_BAO) return;
    const luot = await this.prisma.notificationCampaign.findUnique({
      where: { id: job.data.campaignId },
      select: {
        id: true,
        title: true,
        body: true,
        urgent: true,
        audienceKind: true,
        audienceValue: true,
        role: true,
        sentAt: true,
      },
    });
    // Lượt gửi đã bị huỷ lịch hoặc job chạy lại sau khi chốt
    if (!luot || luot.sentAt) return;

    let tong = 0;
    for (const lop of lopNguoiNhan(
      luot.audienceKind as NhomNguoiNhan,
      luot.audienceValue,
      luot.role,
    )) {
      tong += await this.guiTheoLop(luot, lop);
    }

    await this.prisma.notificationCampaign.update({
      where: { id: luot.id },
      data: { recipientCount: tong, sentAt: new Date() },
    });
    this.logger.log(`Lượt gửi ${luot.id} đã tới ${tong} tài khoản`);
  }

  private async guiTheoLop(luot: LuotGui, lop: LopNguoiNhan) {
    let tong = 0;
    for (let vong = 0; vong < TRAN_SO_LO; vong += 1) {
      // Lọc người đã có tin của lượt này để chạy lại job không gửi trùng
      const nguoi = await this.prisma.user.findMany({
        where: {
          ...lop.where,
          notifications: { none: { campaignId: luot.id, role: lop.role } },
        },
        orderBy: { id: 'asc' },
        take: CO_LO_NGUOI_NHAN,
        select: { id: true },
      });
      if (nguoi.length === 0) return tong;

      const ids = nguoi.map((n) => n.id);
      await this.prisma.notification.createMany({
        data: ids.map((userId) => ({
          userId,
          campaignId: luot.id,
          type: NotificationType.NOI_DUNG,
          role: lop.role,
          title: luot.title,
          body: luot.body,
          urgent: luot.urgent,
        })),
      });
      tong += ids.length;
      await this.dayPush(ids, luot, lop);
      if (nguoi.length < CO_LO_NGUOI_NHAN) return tong;
    }
    this.logger.warn(`Lượt gửi ${luot.id} chạm trần số lô, dừng ở ${tong}`);
    return tong;
  }

  // Lỗi push không được làm hỏng lượt gửi: tin đã nằm trong ứng dụng rồi
  private async dayPush(ids: string[], luot: LuotGui, lop: LopNguoiNhan) {
    const thietBi = await this.prisma.deviceToken.findMany({
      where: { userId: { in: ids } },
      select: { token: true },
    });
    if (thietBi.length === 0) return;
    const tokenChet: string[] = [];
    for (let i = 0; i < thietBi.length; i += CO_LO_NGUOI_NHAN) {
      const lo = thietBi.slice(i, i + CO_LO_NGUOI_NHAN).map((t) => t.token);
      const chet = await this.firebase.guiPush(lo, {
        title: luot.title,
        body: luot.body,
        data: { type: NotificationType.NOI_DUNG, role: lop.role },
      });
      tokenChet.push(...chet);
    }
    if (tokenChet.length > 0) {
      await this.prisma.deviceToken.deleteMany({
        where: { token: { in: tokenChet } },
      });
    }
  }

  @OnWorkerEvent('failed')
  onFailed(job: Job<ViecGuiThongBao>, error: Error) {
    if (job.attemptsMade >= (job.opts.attempts ?? 1)) {
      this.logger.error(
        `Gửi thông báo hệ thống ${job.data.campaignId} thất bại: ${error.message}`,
      );
    }
  }
}
