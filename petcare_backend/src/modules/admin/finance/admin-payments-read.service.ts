import { Injectable, NotFoundException } from '@nestjs/common';
import { Prisma } from '../../../../generated/prisma/client';
import { PaymentStatus } from '../../../../generated/prisma/enums';
import { PrismaService } from '../../../prisma/prisma.service';
import { dungTrang, kepTrang } from '../chung/phan-trang';
import { LocThanhToanDto } from './dto/loc-thanh-toan.dto';

// Bốn tab phủ hết bảy trạng thái, phiên chưa xong vẫn thuộc nhánh tiền chưa nhả
const TAB_THEO_TRANG_THAI: Record<PaymentStatus, keyof DemTab> = {
  PENDING: 'escrow',
  HELD: 'escrow',
  RELEASED: 'released',
  REFUNDING: 'refunding',
  REFUNDED: 'refunding',
  FAILED: 'failed',
  EXPIRED: 'failed',
};

type DemTab = {
  escrow: number;
  released: number;
  refunding: number;
  failed: number;
};

@Injectable()
export class AdminPaymentsReadService {
  constructor(private readonly prisma: PrismaService) {}

  private dieuKien(loc: LocThanhToanDto): Prisma.PaymentWhereInput {
    const dieu: Prisma.PaymentWhereInput = {};
    if (loc.status?.length) dieu.status = { in: loc.status };
    if (loc.gateway) dieu.gateway = loc.gateway;
    if (loc.bankCode) dieu.bankCode = loc.bankCode;
    if (loc.from || loc.to) {
      dieu.createdAt = {
        ...(loc.from ? { gte: new Date(loc.from) } : {}),
        ...(loc.to ? { lte: new Date(loc.to) } : {}),
      };
    }
    if (loc.q) {
      const tim = { contains: loc.q, mode: Prisma.QueryMode.insensitive };
      dieu.OR = [
        { txnRef: tim },
        { gatewayTxnNo: tim },
        { booking: { code: tim } },
        { booking: { owner: { fullName: tim } } },
      ];
    }
    return dieu;
  }

  async danhSach(loc: LocThanhToanDto) {
    const khoang = kepTrang(loc.page, loc.limit);
    const where = this.dieuKien(loc);

    const [total, ds] = await Promise.all([
      this.prisma.payment.count({ where }),
      this.prisma.payment.findMany({
        where,
        orderBy: { createdAt: 'desc' },
        skip: khoang.boQua,
        take: khoang.moiTrang,
        select: {
          id: true,
          bookingId: true,
          txnRef: true,
          gateway: true,
          gatewayTxnNo: true,
          gatewayPayDate: true,
          bankCode: true,
          cardType: true,
          responseCode: true,
          amount: true,
          status: true,
          paidAt: true,
          releasedAt: true,
          expiresAt: true,
          createdAt: true,
          booking: {
            select: {
              code: true,
              owner: { select: { fullName: true, phone: true } },
            },
          },
        },
      }),
    ]);

    const items = ds.map((p) => ({
      id: p.id,
      bookingId: p.bookingId,
      bookingCode: p.booking.code,
      ownerName: p.booking.owner.fullName,
      ownerPhone: p.booking.owner.phone,
      txnRef: p.txnRef,
      gateway: p.gateway,
      gatewayTxnNo: p.gatewayTxnNo,
      gatewayPayDate: p.gatewayPayDate,
      bankCode: p.bankCode,
      cardType: p.cardType,
      responseCode: p.responseCode,
      amount: p.amount,
      status: p.status,
      paidAt: p.paidAt,
      releasedAt: p.releasedAt,
      expiresAt: p.expiresAt,
      createdAt: p.createdAt,
    }));
    return dungTrang(items, total, khoang);
  }

  // Một lượt groupBy rồi cộng về bốn tab ở máy chủ, không bắt màn gọi bốn lần
  async demTab(): Promise<DemTab> {
    const ds = await this.prisma.payment.groupBy({
      by: ['status'],
      _count: true,
    });
    const dem: DemTab = { escrow: 0, released: 0, refunding: 0, failed: 0 };
    for (const dong of ds) {
      dem[TAB_THEO_TRANG_THAI[dong.status]] += dong._count;
    }
    return dem;
  }

  async payloadTho(txnRef: string) {
    const khoan = await this.prisma.payment.findUnique({
      where: { txnRef },
      select: { txnRef: true, gateway: true, rawReturn: true },
    });
    if (!khoan) {
      throw new NotFoundException({
        code: 'KHONG_TIM_THAY_GIAO_DICH',
        message: 'Không tìm thấy giao dịch này',
      });
    }
    return khoan;
  }
}
