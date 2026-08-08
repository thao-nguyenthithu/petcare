import {
  ConflictException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { PaymentStatus } from '../../../../generated/prisma/enums';
import { PrismaService } from '../../../prisma/prisma.service';
import { NhatKyQuanTriService } from '../chung/nhat-ky-quan-tri.service';
import { DanhDauHoanDto } from './dto/loc-hoan-tien.dto';

// Lối DUY NHẤT đưa một khoản sang REFUNDED, không có bước duyệt nào trước đó
@Injectable()
export class AdminRefundsWriteService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly nhatKy: NhatKyQuanTriService,
  ) {}

  async danhDauHoanTay(txnRef: string, dto: DanhDauHoanDto, adminId: string) {
    const khoan = await this.prisma.payment.findUnique({
      where: { txnRef },
      select: {
        id: true,
        txnRef: true,
        status: true,
        booking: { select: { code: true } },
      },
    });
    if (!khoan) {
      throw new NotFoundException({
        code: 'KHONG_TIM_THAY_GIAO_DICH',
        message: 'Không tìm thấy giao dịch này',
      });
    }
    if (khoan.status !== PaymentStatus.REFUNDING) {
      throw this.loiTrangThai(khoan.status);
    }

    const bayGio = new Date();
    await this.prisma.$transaction(async (db) => {
      // Kẹp REFUNDING vào where để bấm hai lần không ghi đè mã tham chiếu cũ
      const doi = await db.payment.updateMany({
        where: { id: khoan.id, status: PaymentStatus.REFUNDING },
        data: {
          status: PaymentStatus.REFUNDED,
          refundReference: dto.reference,
          refundNote: dto.note ?? null,
          refundedAt: bayGio,
        },
      });
      if (doi.count === 0) throw this.loiTrangThai(PaymentStatus.REFUNDED);
      await this.nhatKy.lenhGhi(
        {
          adminId,
          action: 'DANH_DAU_HOAN_TIEN',
          targetType: 'PAYMENT',
          targetId: khoan.id,
          targetCode: khoan.txnRef,
          reason: dto.note ?? null,
          oldValue: PaymentStatus.REFUNDING,
          newValue: PaymentStatus.REFUNDED,
        },
        db,
      );
    });

    return {
      txnRef: khoan.txnRef,
      status: PaymentStatus.REFUNDED,
      refundedAt: bayGio,
    };
  }

  private loiTrangThai(dangO: PaymentStatus) {
    return new ConflictException({
      code: 'TRANG_THAI_KHONG_HOP_LE',
      message: `Giao dịch đang ở ${dangO}, chỉ khoản đang hoàn mới đánh dấu được`,
    });
  }
}
