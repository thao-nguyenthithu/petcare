import {
  BadRequestException,
  ConflictException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { BookingStatus } from '../../../../generated/prisma/enums';
import { PrismaService } from '../../../prisma/prisma.service';
import { LY_DO_QUAN_TRI_CAN_THIEP } from '../../bookings/booking-enums';
import { NotificationsService } from '../../notifications/notifications.service';
import { NhatKyQuanTriService } from '../chung/nhat-ky-quan-tri.service';

// Ba trạng thái đơn chưa chạy, hoàn đủ mới không oan ai (bộ luật mục 4)
const HUY_DUOC: BookingStatus[] = [
  BookingStatus.AWAITING_PAYMENT,
  BookingStatus.PENDING,
  BookingStatus.CONFIRMED,
];

// Từ lúc bắt đầu trở đi phải đi đường khiếu nại, kể cả đơn đã xong (bộ luật mục 4)
const DA_CHAY: BookingStatus[] = [
  BookingStatus.IN_PROGRESS,
  BookingStatus.AWAITING_OWNER_CONFIRM,
  BookingStatus.COMPLETED,
  BookingStatus.DISPUTED,
  BookingStatus.RESOLVED,
];

@Injectable()
export class AdminBookingCancelService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly nhatKy: NhatKyQuanTriService,
    private readonly thongBao: NotificationsService,
  ) {}

  async canThiepHuy(code: string, reason: string, adminId: string) {
    const don = await this.prisma.booking.findUnique({
      where: { code },
      select: {
        id: true,
        code: true,
        status: true,
        ownerId: true,
        sitter: { select: { userId: true } },
      },
    });
    if (!don) {
      throw new NotFoundException({
        code: 'KHONG_TIM_THAY_DON',
        message: 'Không tìm thấy đơn này',
      });
    }
    if (DA_CHAY.includes(don.status)) {
      throw new BadRequestException({
        code: 'DON_DA_CHAY_PHAI_QUA_KHIEU_NAI',
        message:
          'Đơn đã bắt đầu nên không huỷ thẳng được, xử qua khiếu nại và hoàn tiền',
      });
    }
    if (!HUY_DUOC.includes(don.status)) {
      throw new BadRequestException({
        code: 'DON_DA_HUY',
        message: 'Đơn này đã khép lại từ trước',
      });
    }

    await this.prisma.$transaction(async (db) => {
      // Kẹp trạng thái cũ vào where, không thì đơn vừa huỷ ở lối khác bị ghi đè mất dấu
      const doi = await db.booking.updateMany({
        where: { id: don.id, status: { in: HUY_DUOC } },
        data: {
          status: BookingStatus.CANCELLED_BY_ADMIN,
          cancelledAt: new Date(),
          cancellationReason: LY_DO_QUAN_TRI_CAN_THIEP,
          cancellationNote: reason,
          // Chủ nuôi không đổi ý nên không thu đồng nào của họ, người chăm chưa làm gì
          cancellationFee: 0,
          platformFee: 0,
          sitterPayout: 0,
        },
      });
      if (doi.count === 0) {
        throw new ConflictException({
          code: 'DON_DA_HUY',
          message: 'Đơn vừa được đổi ở nơi khác, tải lại rồi thử tiếp',
        });
      }
      // Phần chuyển thật do cổng làm ở bước sau nên dừng ở REFUNDING (bộ luật mục 2)
      await db.payment.updateMany({
        where: { bookingId: don.id, status: 'HELD' },
        data: { status: 'REFUNDING' },
      });
      await this.nhatKy.lenhGhi(
        {
          adminId,
          action: 'CAN_THIEP_HUY_DON',
          targetType: 'BOOKING',
          targetId: don.id,
          targetCode: don.code,
          reason,
          oldValue: don.status,
          newValue: BookingStatus.CANCELLED_BY_ADMIN,
        },
        db,
      );
    });

    // Đơn chưa trả tiền thì nói có hoàn tiền là bịa
    const chuaTraTien = don.status === BookingStatus.AWAITING_PAYMENT;
    await Promise.all([
      this.thongBao.tao({
        userId: don.ownerId,
        type: 'DON_HUY',
        role: 'CHU_NUOI',
        titleKey: 'tbAdminHuyDonTieuDe',
        bodyKey: chuaTraTien
          ? 'tbAdminHuyDonChuaTraTienNoiDung'
          : 'tbAdminHuyDonHoanDuNoiDung',
        params: { code: don.code, lyDo: reason },
        targetId: don.id,
        urgent: true,
      }),
      this.thongBao.tao({
        userId: don.sitter.userId,
        type: 'DON_HUY',
        role: 'NGUOI_CHAM',
        titleKey: 'tbAdminHuyDonTieuDe',
        bodyKey: 'tbAdminHuyDonNccNoiDung',
        params: { code: don.code, lyDo: reason },
        targetId: don.id,
        urgent: true,
      }),
    ]);
    return { code: don.code, status: BookingStatus.CANCELLED_BY_ADMIN };
  }
}
