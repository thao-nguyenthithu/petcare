import { Injectable } from '@nestjs/common';
import { LECH_VN_MS, MOT_NGAY_MS } from '../../common/thoi-gian-vn';
import { PrismaService } from '../../prisma/prisma.service';
import { layNccCuaToi } from '../sitter/orders/sitter-guard';
import { CHON_DON_VI, khoanNccNhan, raTheDon } from './wallet-booking.mapper';
import { WalletLedgerService } from './wallet-ledger.service';

@Injectable()
export class WalletService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly ledger: WalletLedgerService,
  ) {}

  async cuaToi(userId: string) {
    const ncc = await layNccCuaToi(this.prisma, userId);
    const vi = await this.ledger.layVi(ncc.id);
    const bayGio = new Date();
    const [nganHang, giaoDichThang, khoanGiuTam] = await Promise.all([
      this.prisma.bankAccount.findUnique({ where: { sitterId: ncc.id } }),
      this.prisma.walletTransaction.findMany({
        where: {
          walletId: vi.id,
          amount: { gt: 0 },
          createdAt: { gte: dauThangVn(bayGio) },
        },
        select: { amount: true, createdAt: true },
      }),
      this.khoanGiuTam(ncc.id),
    ]);

    const dauTuan = dauTuanVn(bayGio);
    const cotTuanNay = Array.from({ length: 7 }, () => 0);
    let thuNhapTuanNay = 0;
    for (const gd of giaoDichThang) {
      if (gd.createdAt < dauTuan) continue;
      const chiSo = Math.floor(
        (gd.createdAt.getTime() - dauTuan.getTime()) / MOT_NGAY_MS,
      );
      if (chiSo < 0 || chiSo > 6) continue;
      cotTuanNay[chiSo] += gd.amount;
      thuNhapTuanNay += gd.amount;
    }

    return {
      soDuKhaDung: vi.balance,
      daNhanTrongThang: giaoDichThang.reduce((t, g) => t + g.amount, 0),
      thangHienTai: thangVn(bayGio),
      thuNhapTuanNay,
      cotTuanNay,
      chiSoHomNay: thuTrongTuan(bayGio),
      nganHang: nganHang && {
        tenNganHang: nganHang.bankName,
        bonSoCuoi: nganHang.accountNumber.slice(-4),
        tenChuTaiKhoan: nganHang.accountHolder,
        daXacThuc: nganHang.verified,
      },
      khoanGiuTam,
    };
  }

  async khoanGiuTam(sitterId: string) {
    const dsThanhToan = await this.prisma.payment.findMany({
      where: { status: 'HELD', booking: { sitterId } },
      orderBy: { createdAt: 'desc' },
      select: {
        amount: true,
        createdAt: true,
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
    return dsThanhToan.map((tt) => ({
      don: raTheDon(tt.booking),
      soTien: khoanNccNhan(tt.booking),
      dangKhieuNai: tt.booking.reports.length > 0,
      maKhieuNai: tt.booking.reports[0]?.code ?? null,
      moc: (tt.booking.endedAt ?? tt.booking.scheduledAt).toISOString(),
    }));
  }
}

function vn(d: Date): Date {
  return new Date(d.getTime() + LECH_VN_MS);
}

export function thangVn(d: Date): number {
  return vn(d).getUTCMonth() + 1;
}

export function thuTrongTuan(d: Date): number {
  return (vn(d).getUTCDay() + 6) % 7;
}

export function dauNgay(d: Date): Date {
  const t = vn(d);
  return new Date(
    Date.UTC(t.getUTCFullYear(), t.getUTCMonth(), t.getUTCDate()) - LECH_VN_MS,
  );
}

export function dauTuanVn(d: Date): Date {
  return new Date(dauNgay(d).getTime() - thuTrongTuan(d) * MOT_NGAY_MS);
}

export function dauThangVn(d: Date): Date {
  const t = vn(d);
  return new Date(
    Date.UTC(t.getUTCFullYear(), t.getUTCMonth(), 1) - LECH_VN_MS,
  );
}

export function dauNamVn(d: Date): Date {
  const t = vn(d);
  return new Date(Date.UTC(t.getUTCFullYear(), 0, 1) - LECH_VN_MS);
}
