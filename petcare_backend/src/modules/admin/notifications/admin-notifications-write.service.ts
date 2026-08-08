import { InjectQueue } from '@nestjs/bullmq';
import {
  BadRequestException,
  ConflictException,
  Injectable,
  Logger,
  NotFoundException,
} from '@nestjs/common';
import { Queue } from 'bullmq';
import { PrismaService } from '../../../prisma/prisma.service';
import { NOTIFICATION_QUEUE } from '../../notifications/notifications.module';
import { NhatKyQuanTriService } from '../chung/nhat-ky-quan-tri.service';
import { AdminNotificationsReadService } from './admin-notifications-read.service';
import {
  CUA_SO_DANG_GUI_MS,
  CUA_SO_TRUNG_MS,
  maJobLuotGui,
  VIEC_GUI_THONG_BAO,
} from './admin-notifications.constants';
import { GuiThongBaoDto } from './dto/thong-bao-quan-tri.dto';
import { NHOM_CAN_THAM_SO, vaiMacDinh, vaiTheoVaiTaiKhoan } from './nguoi-nhan';

@Injectable()
export class AdminNotificationsWriteService {
  private readonly logger = new Logger(AdminNotificationsWriteService.name);

  constructor(
    private readonly prisma: PrismaService,
    private readonly doc: AdminNotificationsReadService,
    private readonly nhatKy: NhatKyQuanTriService,
    @InjectQueue(NOTIFICATION_QUEUE) private readonly hangDoi: Queue,
  ) {}

  async gui(dto: GuiThongBaoDto, adminId: string) {
    const hen = this.mocHen(dto.scheduledAt);
    const { vai, soNguoi } = await this.chuanBi(dto);
    if (soNguoi === 0) {
      throw new BadRequestException({
        code: 'KHONG_CO_NGUOI_NHAN',
        message: 'Nhóm này chưa có tài khoản nào nhận tin, chọn nhóm khác',
      });
    }
    await this.chanBamHaiLan(dto.title);

    const luot = await this.prisma.$transaction(async (db) => {
      const ban = await db.notificationCampaign.create({
        data: {
          adminId,
          title: dto.title,
          body: dto.body,
          role: vai,
          audienceKind: dto.audienceKind,
          audienceValue: dto.audienceValue ?? null,
          urgent: dto.urgent ?? false,
          scheduledAt: hen,
        },
        select: { id: true },
      });
      await this.nhatKy.lenhGhi(
        {
          adminId,
          action: 'GUI_THONG_BAO_HE_THONG',
          targetType: 'NOTIFICATION',
          targetId: ban.id,
          targetCode: dto.title,
          newValue: String(soNguoi),
        },
        db,
      );
      return ban;
    });

    await this.hangDoi.add(
      VIEC_GUI_THONG_BAO,
      { campaignId: luot.id },
      {
        delay: hen ? Math.max(0, hen.getTime() - Date.now()) : 0,
        // Trùng id thì BullMQ bỏ qua, một lượt gửi không bao giờ có hai job
        jobId: maJobLuotGui(luot.id),
        removeOnComplete: true,
        attempts: 3,
        backoff: { type: 'exponential', delay: 5000 },
      },
    );

    return { id: luot.id, scheduledAt: hen?.toISOString() ?? null };
  }

  async huyLich(id: string, adminId: string) {
    const luot = await this.prisma.notificationCampaign.findUnique({
      where: { id },
      select: { id: true, title: true, sentAt: true, scheduledAt: true },
    });
    if (!luot) {
      throw new NotFoundException({
        code: 'KHONG_TIM_THAY_LUOT_GUI',
        message: 'Không tìm thấy lượt gửi này',
      });
    }
    if (luot.sentAt) {
      throw new ConflictException({
        code: 'DA_GUI_KHONG_HUY_DUOC',
        message: 'Tin đã tới tay người nhận, không thu hồi được nữa',
      });
    }
    if (!luot.scheduledAt) {
      throw new ConflictException({
        code: 'DANG_GUI_KHONG_HUY_DUOC',
        message: 'Lượt gửi này đang chạy, chờ chạy xong rồi xem lại',
      });
    }

    await this.prisma.$transaction([
      this.prisma.notificationCampaign.delete({ where: { id } }),
      this.nhatKy.lenhGhi({
        adminId,
        action: 'HUY_LICH_THONG_BAO',
        targetType: 'NOTIFICATION',
        targetId: id,
        targetCode: luot.title,
        oldValue: luot.scheduledAt.toISOString(),
      }),
    ]);

    // Job mồ côi vẫn vô hại vì lúc chạy không còn lượt gửi để đọc
    await this.hangDoi
      .remove(maJobLuotGui(id))
      .catch((e: Error) =>
        this.logger.warn(`Không gỡ được job hẹn giờ ${id}: ${e.message}`),
      );
    return { id, daHuy: true };
  }

  private mocHen(gia?: string): Date | null {
    if (!gia) return null;
    const moc = new Date(gia);
    if (moc.getTime() <= Date.now()) {
      throw new BadRequestException({
        code: 'MOC_HEN_DA_QUA',
        message: 'Mốc hẹn gửi phải nằm ở tương lai',
      });
    }
    return moc;
  }

  private async chuanBi(dto: GuiThongBaoDto) {
    if (NHOM_CAN_THAM_SO.includes(dto.audienceKind) && !dto.audienceValue) {
      throw new BadRequestException({
        code: 'THIEU_THAM_SO_NHOM_NHAN',
        message: 'Nhóm người nhận này cần chọn tỉnh hoặc chọn một tài khoản',
      });
    }
    if (dto.audienceKind === 'SINGLE_USER') {
      const nguoi = await this.prisma.user.findFirst({
        where: { id: dto.audienceValue, isActive: true },
        select: { role: true },
      });
      if (!nguoi) {
        throw new NotFoundException({
          code: 'KHONG_TIM_THAY_NGUOI_NHAN',
          message: 'Tài khoản nhận tin không còn hoạt động',
        });
      }
      return { vai: vaiTheoVaiTaiKhoan(nguoi.role), soNguoi: 1 };
    }
    const soNguoi = await this.doc.demNguoiNhan(
      dto.audienceKind,
      dto.audienceValue,
    );
    return { vai: vaiMacDinh(dto.audienceKind), soNguoi };
  }

  // Gửi ra toàn hệ thống không thu hồi được nên hai cửa chặn đi chung một lượt hỏi
  private async chanBamHaiLan(title: string) {
    const bayGio = Date.now();
    const trung = await this.prisma.notificationCampaign.findFirst({
      where: {
        OR: [
          {
            sentAt: null,
            scheduledAt: null,
            createdAt: { gte: new Date(bayGio - CUA_SO_DANG_GUI_MS) },
          },
          { title, createdAt: { gte: new Date(bayGio - CUA_SO_TRUNG_MS) } },
        ],
      },
      select: { sentAt: true, scheduledAt: true },
    });
    if (!trung) return;
    if (!trung.sentAt && !trung.scheduledAt) {
      throw new ConflictException({
        code: 'LUOT_GUI_DANG_CHAY',
        message: 'Một lượt gửi khác đang chạy, chờ xong rồi gửi tiếp',
      });
    }
    throw new ConflictException({
      code: 'TRUNG_LUOT_GUI',
      message: 'Vừa có lượt gửi cùng tiêu đề, kiểm lại lịch sử trước khi gửi',
    });
  }
}
