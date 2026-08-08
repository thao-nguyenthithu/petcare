import {
  BadRequestException,
  ConflictException,
  Injectable,
  Logger,
  NotFoundException,
} from '@nestjs/common';
import { InjectQueue } from '@nestjs/bullmq';
import { Queue } from 'bullmq';
import { Prisma } from 'generated/prisma/client';
import { PrismaService } from '../../prisma/prisma.service';
import { hanGiuCho } from '../bookings/booking-time';
import { BookingNotifyService } from '../notifications/booking-notify.service';
import { KetQuaCong } from './gateways/payment-gateway.interface';
import { PaymentGatewayResolver } from './gateways/payment-gateway.resolver';
import { PAYMENT_QUEUE, VIEC_HET_HAN_GIU_CHO } from './payments.constants';


type DonTraTien = {
  id: string;
  code: string;
  status: string;
  ownerId: string;
  totalPrice: number | null;
  createdAt: Date;
};

@Injectable()
export class PaymentsService {
  private readonly logger = new Logger(PaymentsService.name);

  constructor(
    private readonly prisma: PrismaService,
    private readonly notify: BookingNotifyService,
    private readonly chonCong: PaymentGatewayResolver,
    @InjectQueue(PAYMENT_QUEUE) private readonly hangDoi: Queue,
  ) {}

  async taoPhien(userId: string, bookingId: string, ip: string) {
    const don = await this.donCuaToi(userId, bookingId);
    if (don.status !== 'AWAITING_PAYMENT') {
      throw new ConflictException({
        code: 'DON_KHONG_CHO_THANH_TOAN',
        message: 'Đơn này không còn ở bước chờ thanh toán',
      });
    }
    const hetHan = hanGiuCho(don.createdAt);
    if (Date.now() >= hetHan.getTime()) {
      throw new ConflictException({
        code: 'HET_HAN_GIU_CHO',
        message: 'Đã quá hạn giữ chỗ, bạn cần đặt lại đơn mới',
      });
    }
    const soTien = don.totalPrice ?? 0;
    if (soTien <= 0) {
      throw new BadRequestException({
        code: 'SO_TIEN_KHONG_HOP_LE',
        message: 'Đơn chưa có số tiền để thanh toán',
      });
    }

    const cong = await this.chonCong.cong();
    const txnRef = maGiaoDich(don.code);
    await this.prisma.payment.create({
      data: {
        bookingId: don.id,
        txnRef,
        amount: soTien,
        gateway: cong.ten,
        expiresAt: hetHan,
      },
    });

    if (cong.tuDongChot) {
      await this.xacNhanTra(cong.docKetQua({ txnRef, soTien: String(soTien) }));
      return {
        payUrl: null,
        txnRef,
        expiresAt: hetHan,
        tuDongThanhCong: true,
      };
    }

    const phien = cong.taoPhien({
      txnRef,
      soTien,
      moTa: `Thanh toan don ${don.code}`,
      ip,
      hetHan,
    });
    return {
      payUrl: phien.payUrl,
      txnRef,
      expiresAt: hetHan,
      tuDongThanhCong: false,
    };
  }

  async trangThai(userId: string, bookingId: string) {
    const don = await this.donCuaToi(userId, bookingId);
    const moiNhat = await this.prisma.payment.findFirst({
      where: { bookingId },
      orderBy: { createdAt: 'desc' },
      select: {
        status: true,
        txnRef: true,
        gatewayTxnNo: true,
        responseCode: true,
        expiresAt: true,
      },
    });
    return {
      bookingStatus: don.status,
      paymentStatus: moiNhat?.status ?? null,
      txnRef: moiNhat?.txnRef ?? null,
      transactionNo: moiNhat?.gatewayTxnNo ?? null,
      responseCode: moiNhat?.responseCode ?? null,
      expiresAt: hanGiuCho(don.createdAt),
    };
  }

  async boGiuCho(userId: string, bookingId: string) {
    const don = await this.donCuaToi(userId, bookingId);
    if (don.status !== 'AWAITING_PAYMENT') {
      throw new ConflictException({
        code: 'DON_KHONG_CHO_THANH_TOAN',
        message: 'Đơn này không còn ở bước chờ thanh toán',
      });
    }
    await this.huyGiuCho(bookingId);
    return { status: 'CANCELLED_UNPAID' };
  }

  async xacNhanTra(ketQua: KetQuaCong) {
    const ket = await this.prisma.$transaction(async (tx) => {
      // Cổng gọi lại IPN nhiều lần là bình thường, không khoá là ghi hai lần tiền
      await tx.$executeRaw`SELECT pg_advisory_xact_lock(hashtext(${ketQua.txnRef}))`;
      const tra = await tx.payment.findUnique({
        where: { txnRef: ketQua.txnRef },
        select: {
          id: true,
          bookingId: true,
          amount: true,
          status: true,
          booking: { select: { status: true } },
        },
      });
      if (!tra) return { ma: 'KHONG_TIM_THAY' as const };
      if (tra.status !== 'PENDING') return { ma: 'DA_XU_LY' as const };
      if (!Number.isInteger(ketQua.soTien) || tra.amount !== ketQua.soTien) {
        await tx.payment.update({
          where: { id: tra.id },
          data: {
            status: 'FAILED',
            responseCode: ketQua.maPhanHoi,
            rawReturn: ketQua.duLieuGoc,
          },
        });
        return { ma: 'LECH_TIEN' as const };
      }

      const chung = {
        gatewayTxnNo: ketQua.maGiaoDich,
        gatewayPayDate: ketQua.ngayTraCong,
        bankCode: ketQua.bankCode,
        cardType: ketQua.cardType,
        responseCode: ketQua.maPhanHoi,
        rawReturn: ketQua.duLieuGoc as Prisma.InputJsonValue,
      };
      if (!ketQua.thanhCong) {
        await tx.payment.update({
          where: { id: tra.id },
          data: { ...chung, status: 'FAILED' },
        });
        return { ma: 'THAT_BAI' as const };
      }

      const bayGio = new Date();
      await tx.payment.update({
        where: { id: tra.id },
        data: { ...chung, status: 'HELD', paidAt: bayGio },
      });
      if (tra.booking.status !== 'AWAITING_PAYMENT') {
        return { ma: 'DON_DA_CHET' as const, bookingId: tra.bookingId };
      }
      await tx.booking.update({
        where: { id: tra.bookingId },
        data: { status: 'PENDING', paidAt: bayGio },
      });
      return { ma: 'THANH_CONG' as const, bookingId: tra.bookingId };
    });

    if (ket.ma === 'THANH_CONG') {
      await this.notify.donMoi(ket.bookingId);
    }
    if (ket.ma === 'DON_DA_CHET') {
      this.logger.warn(
        `Tiền về sau khi đơn ${ket.bookingId} đã huỷ vì quá hạn giữ chỗ, cần hoàn lại`,
      );
    }
    return ket;
  }

  async huyGiuCho(bookingId: string) {
    await this.prisma.$transaction(async (tx) => {
      const don = await tx.booking.findUnique({
        where: { id: bookingId },
        select: { status: true },
      });
      if (!don || don.status !== 'AWAITING_PAYMENT') return;
      await tx.booking.update({
        where: { id: bookingId },
        data: { status: 'CANCELLED_UNPAID', cancelledAt: new Date() },
      });
      await tx.payment.updateMany({
        where: { bookingId, status: 'PENDING' },
        data: { status: 'EXPIRED' },
      });
    });
  }

  async henDonGiuCho(bookingId: string, hetHan: Date) {
    const treMs = Math.max(0, hetHan.getTime() - Date.now());
    await this.hangDoi.add(
      VIEC_HET_HAN_GIU_CHO,
      { bookingId },
      {
        delay: treMs,
        jobId: `giu-cho-${bookingId}`,
        removeOnComplete: true,
        attempts: 3,
        backoff: { type: 'exponential', delay: 5000 },
      },
    );
  }

  private async donCuaToi(
    userId: string,
    bookingId: string,
  ): Promise<DonTraTien> {
    const don = await this.prisma.booking.findFirst({
      where: { id: bookingId, ownerId: userId },
      select: {
        id: true,
        code: true,
        status: true,
        ownerId: true,
        totalPrice: true,
        createdAt: true,
      },
    });
    if (!don) {
      throw new NotFoundException({
        code: 'KHONG_TIM_THAY_DON',
        message: 'Không tìm thấy đơn này',
      });
    }
    return don;
  }
}

function maGiaoDich(maDon: string): string {
  const moc = Date.now().toString(36).toUpperCase();
  return `${maDon}${moc}`;
}
