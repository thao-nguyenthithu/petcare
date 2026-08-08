import { Injectable, NotFoundException } from '@nestjs/common';
import type { WalletTxKind } from 'generated/prisma/enums';
import { PrismaService } from '../../prisma/prisma.service';
import { layNccCuaToi } from '../sitter/orders/sitter-guard';
import { CHON_DON_VI, raTheDon } from './wallet-booking.mapper';
import { WalletLedgerService } from './wallet-ledger.service';

const MOI_TRANG = 20;

@Injectable()
export class WalletTransactionsService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly ledger: WalletLedgerService,
  ) {}

  async danhSach(
    userId: string,
    tuyChon: { loai?: WalletTxKind; truoc?: string },
  ) {
    const ncc = await layNccCuaToi(this.prisma, userId);
    const vi = await this.ledger.layVi(ncc.id);
    const ds = await this.prisma.walletTransaction.findMany({
      where: {
        walletId: vi.id,
        ...(tuyChon.loai ? { kind: tuyChon.loai } : {}),
        ...(tuyChon.truoc
          ? { createdAt: { lt: new Date(tuyChon.truoc) } }
          : {}),
      },
      orderBy: { createdAt: 'desc' },
      take: MOI_TRANG,
    });
    const donTheoId = await this.donKemTheo(ds.map((g) => g.bookingId));
    return {
      items: ds.map((g) => this.raDong(g, donTheoId)),
      truocTiep:
        ds.length === MOI_TRANG
          ? ds[ds.length - 1].createdAt.toISOString()
          : null,
    };
  }

  async chiTiet(userId: string, code: string) {
    const ncc = await layNccCuaToi(this.prisma, userId);
    const vi = await this.ledger.layVi(ncc.id);
    const gd = await this.prisma.walletTransaction.findFirst({
      where: { code, walletId: vi.id },
    });
    if (!gd) {
      throw new NotFoundException({
        code: 'KHONG_TIM_THAY_GIAO_DICH',
        message: 'Không tìm thấy giao dịch này',
      });
    }
    const donTheoId = await this.donKemTheo([gd.bookingId]);
    const giaoDich = this.raDong(gd, donTheoId);
    const [dongMot, dongHai] = this.haiDongTien(
      gd.kind,
      gd.amount,
      giaoDich.don,
    );
    return {
      giaoDich,
      dongMot,
      dongHai,
      tong: gd.amount,
      moc: gd.createdAt.toISOString(),
      dienBien: await this.dienBien(gd.kind, gd.bookingId, gd.withdrawalId),
      khieuNai: gd.disputeCode
        ? await this.tomTatKhieuNai(gd.disputeCode)
        : null,
    };
  }

  private async donKemTheo(ids: (string | null)[]) {
    const canLay = [...new Set(ids.filter((x): x is string => !!x))];
    if (!canLay.length) return new Map<string, ReturnType<typeof raTheDon>>();
    const dons = await this.prisma.booking.findMany({
      where: { id: { in: canLay } },
      select: CHON_DON_VI,
    });
    return new Map(dons.map((d) => [d.id, raTheDon(d)]));
  }

  private raDong(
    g: {
      code: string;
      kind: WalletTxKind;
      title: string;
      amount: number;
      balanceAfter: number;
      bookingId: string | null;
      disputeCode: string | null;
      reference: string | null;
      createdAt: Date;
    },
    donTheoId: Map<string, ReturnType<typeof raTheDon>>,
  ) {
    return {
      ma: g.code,
      loai: g.kind,
      tieuDe: g.title,
      soTien: g.amount,
      soDuSau: g.balanceAfter,
      thoiDiem: g.createdAt.toISOString(),
      don: g.bookingId ? (donTheoId.get(g.bookingId) ?? null) : null,
      maKhieuNai: g.disputeCode,
      maThamChieu: g.reference,
    };
  }

  private haiDongTien(
    loai: WalletTxKind,
    soTien: number,
    don: { totalPrice: number } | null,
  ): [number, number] {
    if (loai === 'TIEN_VAO') {
      const goc = don?.totalPrice ?? soTien;
      return [goc, soTien - goc];
    }
    if (loai === 'RUT_RA') return [soTien, 0];
    return [0, soTien];
  }

  private async dienBien(
    loai: WalletTxKind,
    bookingId: string | null,
    withdrawalId: string | null,
  ) {
    if (loai === 'RUT_RA' && withdrawalId) {
      const lenh = await this.prisma.withdrawal.findUnique({
        where: { id: withdrawalId },
        select: { createdAt: true, sentAt: true, doneAt: true },
      });
      if (!lenh) return [];
      return [
        moc('Bạn tạo lệnh rút', lenh.createdAt, true),
        moc(
          'Hệ thống trừ số dư ví, gửi lệnh sang ngân hàng',
          lenh.sentAt,
          !!lenh.sentAt,
        ),
        moc('Ngân hàng báo đã nhận', lenh.doneAt, !!lenh.doneAt),
      ];
    }
    if (loai === 'TIEN_VAO' && bookingId) {
      const don = await this.prisma.booking.findUnique({
        where: { id: bookingId },
        select: {
          endedAt: true,
          payments: {
            where: { status: 'RELEASED' },
            orderBy: { releasedAt: 'desc' },
            take: 1,
            select: { releasedAt: true },
          },
        },
      });
      if (!don) return [];
      return [
        moc('Hoàn tất dịch vụ', don.endedAt, !!don.endedAt),
        moc(
          'Hết hạn xác nhận, khoản tiền được chốt',
          don.payments[0]?.releasedAt ?? null,
          true,
        ),
        moc('Tiền vào ví', don.payments[0]?.releasedAt ?? null, true),
      ];
    }
    return [];
  }

  private async tomTatKhieuNai(code: string) {
    const hs = await this.prisma.violationReport.findUnique({
      where: { code },
      select: {
        code: true,
        description: true,
        resolution: true,
        resolutionReason: true,
        resolvedAt: true,
      },
    });
    if (!hs) return null;
    return {
      ma: hs.code,
      chuNuoiPhanAnh: hs.description,
      ketLuan: hs.resolution,
      lyDo: hs.resolutionReason,
      thoiDiem: hs.resolvedAt?.toISOString() ?? null,
    };
  }
}

function moc(viec: string, thoiDiem: Date | null, daXong: boolean) {
  return { viec, thoiDiem: thoiDiem?.toISOString() ?? null, daXong };
}
