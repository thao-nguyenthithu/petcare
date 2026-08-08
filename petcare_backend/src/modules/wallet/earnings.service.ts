import { Injectable } from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';
import { layNccCuaToi } from '../sitter/orders/sitter-guard';
import {
  dauKy,
  dungCot,
  luiMotKy,
  nhanKy,
  phanTramDoi,
  tieuDeBieuDo,
  type Ky,
} from './ky-thong-ke';
import { CHON_DON_VI, raTheDon } from './wallet-booking.mapper';
import { WalletLedgerService } from './wallet-ledger.service';

export type KyThuNhap = Ky;

const SO_GIAO_DICH_GAN_DAY = 5;

@Injectable()
export class EarningsService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly ledger: WalletLedgerService,
  ) {}

  async theoKy(userId: string, ky: KyThuNhap) {
    const ncc = await layNccCuaToi(this.prisma, userId);
    const vi = await this.ledger.layVi(ncc.id);
    const bayGio = new Date();
    const tu = dauKy(ky, bayGio);

    const giaoDich = await this.prisma.walletTransaction.findMany({
      where: {
        walletId: vi.id,
        amount: { gt: 0 },
        createdAt: { gte: luiMotKy(ky, tu) },
      },
      orderBy: { createdAt: 'desc' },
      select: {
        code: true,
        title: true,
        amount: true,
        bookingId: true,
        createdAt: true,
      },
    });
    const trongKy = giaoDich.filter((g) => g.createdAt >= tu);
    const kyTruoc = giaoDich.filter((g) => g.createdAt < tu);

    const tong = trongKy.reduce((t, g) => t + g.amount, 0);
    const cot = dungCot(
      ky,
      tu,
      bayGio,
      trongKy.map((g) => ({ amount: g.amount, moc: g.createdAt })),
    );

    const ganDay = trongKy.slice(0, SO_GIAO_DICH_GAN_DAY);
    const donTheoId = await this.donKemTheo(ganDay.map((g) => g.bookingId));
    const soGio = await this.gioLamViec(ncc.id, tu, bayGio);

    return {
      rangeLabel: nhanKy(ky, tu, bayGio),
      total: tong,
      changePercent: phanTramDoi(
        tong,
        kyTruoc.reduce((t, g) => t + g.amount, 0),
      ),
      ordersDone: trongKy.filter((g) => g.bookingId).length,
      hoursWorked: soGio,
      chartTitle: tieuDeBieuDo(ky),
      bars: cot.bars,
      highlightBar: cot.highlightBar,
      transactions: ganDay.map((g) => ({
        ma: g.code,
        tieuDe: g.title,
        soTien: g.amount,
        thoiDiem: g.createdAt.toISOString(),
        don: g.bookingId ? (donTheoId.get(g.bookingId) ?? null) : null,
      })),
    };
  }

  // Đọc một lượt rồi tra theo id, gọi trong vòng lặp là n lượt đi về database
  private async donKemTheo(ids: (string | null)[]) {
    const canLay = [...new Set(ids.filter((x): x is string => !!x))];
    if (!canLay.length) return new Map<string, ReturnType<typeof raTheDon>>();
    const dons = await this.prisma.booking.findMany({
      where: { id: { in: canLay } },
      select: CHON_DON_VI,
    });
    return new Map(dons.map((d) => [d.id, raTheDon(d)]));
  }

  // Giờ làm việc thực tế, mô hình đặt lịch không có khái niệm chạy rong chờ đơn
  private async gioLamViec(sitterId: string, tu: Date, den: Date) {
    const dons = await this.prisma.booking.findMany({
      where: {
        sitterId,
        status: 'COMPLETED',
        endedAt: { gte: tu, lte: den },
      },
      select: { startedAt: true, endedAt: true, durationMinutes: true },
    });
    const phut = dons.reduce((tong, d) => {
      if (d.startedAt && d.endedAt) {
        return tong + (d.endedAt.getTime() - d.startedAt.getTime()) / 60_000;
      }
      return tong + (d.durationMinutes ?? 0);
    }, 0);
    return Math.round(phut / 60);
  }
}
