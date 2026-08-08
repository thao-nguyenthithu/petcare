import { Injectable, NotFoundException } from '@nestjs/common';
import type { PaymentStatus } from 'generated/prisma/enums';
import { PrismaService } from '../../prisma/prisma.service';
import { CHON_DON_VI, raTheDon } from '../wallet/wallet-booking.mapper';
import {
  dauKy,
  dungCot,
  luiMotKy,
  nhanKy,
  phanTramDoi,
  tieuDeBieuDo,
  type Ky,
} from '../wallet/ky-thong-ke';
import { thangVn } from '../wallet/wallet.service';
import { LOAI_RA_APP } from '../bookings/booking-enums';

@Injectable()
export class OwnerPaymentsService {
  constructor(private readonly prisma: PrismaService) {}

  async dangTamGiu(userId: string) {
    const ds = await this.prisma.payment.findMany({
      where: { status: 'HELD', booking: { ownerId: userId } },
      orderBy: { createdAt: 'desc' },
      select: {
        amount: true,
        booking: {
          select: {
            ...CHON_DON_VI,
            reports: {
              where: { status: { not: 'RESOLVED' } },
              select: { code: true },
            },
          },
        },
      },
    });
    return {
      tong: ds.reduce((t, p) => t + p.amount, 0),
      khoan: ds.map((p) => ({
        don: raTheDon(p.booking),
        soTien: p.amount,
        dangKhieuNai: p.booking.reports.length > 0,
        maKhieuNai: p.booking.reports[0]?.code ?? null,
      })),
    };
  }

  async lichSu(userId: string, loai?: 'thanhToan' | 'hoanTien') {
    const ds = await this.prisma.payment.findMany({
      where: {
        booking: { ownerId: userId },
        status: { in: this.locTheoLoai(loai) },
      },
      orderBy: { createdAt: 'desc' },
      take: 50,
      select: {
        txnRef: true,
        amount: true,
        status: true,
        bankCode: true,
        paidAt: true,
        createdAt: true,
        booking: { select: CHON_DON_VI },
      },
    });
    return { items: ds.map((p) => this.raDong(p)) };
  }

  async chiTiet(userId: string, txnRef: string) {
    const tt = await this.prisma.payment.findFirst({
      where: { txnRef, booking: { ownerId: userId } },
      select: {
        txnRef: true,
        amount: true,
        status: true,
        bankCode: true,
        paidAt: true,
        createdAt: true,
        booking: {
          select: {
            ...CHON_DON_VI,
            cancelledAt: true,
            cancellationFee: true,
            reports: { select: { code: true }, take: 1 },
          },
        },
      },
    });
    if (!tt) {
      throw new NotFoundException({
        code: 'KHONG_TIM_THAY_GIAO_DICH',
        message: 'Không tìm thấy giao dịch này',
      });
    }
    const laHoan = tt.status === 'REFUNDED' || tt.status === 'REFUNDING';
    return {
      giaoDich: this.raDong(tt),
      maKhieuNai: tt.booking.reports[0]?.code ?? null,
      dienBien: laHoan
        ? [
            moc(
              'Bạn huỷ đơn',
              tt.booking.cancelledAt,
              !!tt.booking.cancelledAt,
            ),
            moc('Hỗ trợ duyệt khoản hoàn', tt.booking.cancelledAt, true),
            moc(
              `Tiền hoàn về ${tt.bankCode ?? 'nguồn bạn đã thanh toán'}`,
              tt.booking.cancelledAt,
              tt.status === 'REFUNDED',
            ),
          ]
        : [
            moc('Bạn đặt đơn và thanh toán', tt.paidAt, !!tt.paidAt),
            moc(
              'Nền tảng giữ tiền, chưa chuyển cho người chăm',
              tt.paidAt,
              tt.status === 'HELD' || tt.status === 'RELEASED',
            ),
            moc(
              'Khoản tiền đã chuyển cho người chăm',
              null,
              tt.status === 'RELEASED',
            ),
          ],
    };
  }

  async chiTieu(userId: string, ky: Ky) {
    const bayGio = new Date();
    const tu = dauKy(ky, bayGio);
    const ds = await this.prisma.payment.findMany({
      where: {
        booking: { ownerId: userId },
        status: { in: ['HELD', 'RELEASED'] },
        paidAt: { gte: luiMotKy(ky, tu) },
      },
      select: {
        amount: true,
        paidAt: true,
        booking: { select: { service: { select: { type: true } } } },
      },
    });
    const trongKy = ds.filter((p) => p.paidAt && p.paidAt >= tu);
    const kyTruoc = ds.filter((p) => p.paidAt && p.paidAt < tu);

    const theoDichVu = new Map<string, { soDon: number; soTien: number }>();
    for (const p of trongKy) {
      const loai = LOAI_RA_APP[p.booking.service.type];
      const cu = theoDichVu.get(loai) ?? { soDon: 0, soTien: 0 };
      theoDichVu.set(loai, {
        soDon: cu.soDon + 1,
        soTien: cu.soTien + p.amount,
      });
    }
    const cot = dungCot(
      ky,
      tu,
      bayGio,
      trongKy.map((p) => ({ amount: p.amount, moc: p.paidAt! })),
    );

    const tong = trongKy.reduce((t, p) => t + p.amount, 0);
    return {
      rangeLabel: nhanKy(ky, tu, bayGio),
      thangHienTai: thangVn(bayGio),
      total: tong,
      changePercent: phanTramDoi(
        tong,
        kyTruoc.reduce((t, p) => t + p.amount, 0),
      ),
      ordersDone: trongKy.length,
      chartTitle: tieuDeBieuDo(ky),
      bars: cot.bars,
      highlightBar: cot.highlightBar,
      theoDichVu: [...theoDichVu].map(([dichVu, so]) => ({ dichVu, ...so })),
    };
  }

  private locTheoLoai(loai?: 'thanhToan' | 'hoanTien'): PaymentStatus[] {
    if (loai === 'hoanTien') return ['REFUNDING', 'REFUNDED'];
    if (loai === 'thanhToan') return ['HELD', 'RELEASED'];
    // Mặc định bỏ các bản ghi chưa từng trừ đồng nào của chủ nuôi
    return ['HELD', 'RELEASED', 'REFUNDING', 'REFUNDED'];
  }

  private raDong(p: {
    txnRef: string;
    amount: number;
    status: string;
    bankCode: string | null;
    paidAt: Date | null;
    createdAt: Date;
    booking: Parameters<typeof raTheDon>[0];
  }) {
    const laHoan = p.status === 'REFUNDED' || p.status === 'REFUNDING';
    return {
      ma: p.txnRef,
      loai: laHoan ? 'hoanTien' : 'thanhToan',
      tieuDe: laHoan ? 'Hoàn tiền đơn huỷ' : 'Thanh toán đơn dịch vụ',
      soTien: laHoan ? p.amount : -p.amount,
      thoiDiem: (p.paidAt ?? p.createdAt).toISOString(),
      trangThai: p.status,
      nganHang: p.bankCode,
      don: raTheDon(p.booking),
    };
  }
}

function moc(viec: string, thoiDiem: Date | null, daXong: boolean) {
  return { viec, thoiDiem: thoiDiem?.toISOString() ?? null, daXong };
}
