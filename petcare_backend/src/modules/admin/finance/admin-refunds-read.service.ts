import { Injectable } from '@nestjs/common';
import { Prisma } from '../../../../generated/prisma/client';
import { PaymentStatus } from '../../../../generated/prisma/enums';
import { PrismaService } from '../../../prisma/prisma.service';
import { dungTrang, kepTrang } from '../chung/phan-trang';
import { LocHoanTienDto } from './dto/loc-hoan-tien.dto';
import {
  dieuKienLyDo,
  suyLyDoHoan,
  tinhTienHoan,
  TRANG_THAI_HOAN,
} from './hoan-tien-chung';

@Injectable()
export class AdminRefundsReadService {
  constructor(private readonly prisma: PrismaService) {}

  private dieuKien(loc: LocHoanTienDto): Prisma.PaymentWhereInput {
    const dieu: Prisma.PaymentWhereInput = {
      status: loc.status ? loc.status : { in: TRANG_THAI_HOAN },
    };
    if (loc.bankCode) dieu.bankCode = loc.bankCode;
    // Mốc lệnh hoàn phát sinh không có cột riêng, updatedAt là mốc gần nhất của nó
    if (loc.from || loc.to) {
      dieu.updatedAt = {
        ...(loc.from ? { gte: new Date(loc.from) } : {}),
        ...(loc.to ? { lte: new Date(loc.to) } : {}),
      };
    }
    const nhanh: Prisma.PaymentWhereInput[] = [];
    if (loc.reason) nhanh.push(dieuKienLyDo(loc.reason));
    if (loc.q) {
      const tim = { contains: loc.q, mode: Prisma.QueryMode.insensitive };
      nhanh.push({
        OR: [
          { txnRef: tim },
          { booking: { code: tim } },
          { booking: { owner: { fullName: tim } } },
        ],
      });
    }
    if (nhanh.length) dieu.AND = nhanh;
    return dieu;
  }

  async danhSach(loc: LocHoanTienDto) {
    const khoang = kepTrang(loc.page, loc.limit);
    const where = this.dieuKien(loc);

    const [total, ds] = await Promise.all([
      this.prisma.payment.count({ where }),
      this.prisma.payment.findMany({
        where,
        // Khoản chưa hoàn lên trước, trong đó chờ lâu nhất đứng đầu hàng
        orderBy: [
          { refundedAt: { sort: 'desc', nulls: 'first' } },
          { updatedAt: 'asc' },
        ],
        skip: khoang.boQua,
        take: khoang.moiTrang,
        select: {
          txnRef: true,
          gatewayTxnNo: true,
          gatewayPayDate: true,
          bankCode: true,
          cardType: true,
          amount: true,
          status: true,
          refundReference: true,
          refundNote: true,
          refundedAt: true,
          updatedAt: true,
          booking: {
            select: {
              id: true,
              code: true,
              totalPrice: true,
              cancellationFee: true,
              cancelledAt: true,
              cancellationReason: true,
              cancellationNote: true,
              owner: { select: { fullName: true, phone: true } },
              reports: {
                where: { resolvedAt: { not: null } },
                orderBy: { resolvedAt: 'desc' },
                take: 1,
                select: { resolvedAt: true, refundAmount: true },
              },
            },
          },
        },
      }),
    ]);

    const items = ds.map((p) => {
      const don = p.booking;
      const ketLuan = don.reports[0] ?? null;
      const nguon = {
        totalPrice: don.totalPrice,
        cancellationFee: don.cancellationFee,
        ketLuan,
      };
      const lyDo = suyLyDoHoan(nguon);
      return {
        bookingId: don.id,
        bookingCode: don.code,
        ownerName: don.owner.fullName,
        ownerPhone: don.owner.phone,
        txnRef: p.txnRef,
        gatewayTxnNo: p.gatewayTxnNo,
        gatewayPayDate: p.gatewayPayDate,
        bankCode: p.bankCode,
        cardType: p.cardType,
        amount: tinhTienHoan(nguon, lyDo, p.amount),
        paymentAmount: p.amount,
        reason: lyDo,
        cancelReasonText: don.cancellationNote ?? don.cancellationReason,
        requestedAt: ketLuan?.resolvedAt ?? don.cancelledAt ?? p.updatedAt,
        status: p.status,
        refundReference: p.refundReference,
        refundNote: p.refundNote,
        refundedAt: p.refundedAt,
      };
    });
    return dungTrang(items, total, khoang);
  }

  async demTab() {
    const ds = await this.prisma.payment.groupBy({
      by: ['status'],
      where: { status: { in: TRANG_THAI_HOAN } },
      _count: true,
    });
    const lay = (tt: PaymentStatus) =>
      ds.find((d) => d.status === tt)?._count ?? 0;
    return {
      refunding: lay(PaymentStatus.REFUNDING),
      refunded: lay(PaymentStatus.REFUNDED),
    };
  }
}
