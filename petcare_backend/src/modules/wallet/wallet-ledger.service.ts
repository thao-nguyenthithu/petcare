import { ConflictException, Injectable, Logger } from '@nestjs/common';
import { Prisma } from 'generated/prisma/client';
import type { WalletTxKind } from 'generated/prisma/enums';
import { PrismaService } from '../../prisma/prisma.service';
import { maGiaoDichVi } from './wallet.constants';

type DbClient = Prisma.TransactionClient;

type TinGhiSo = {
  loai: WalletTxKind;
  tieuDe: string;
  soTien: number;
  bookingId?: string;
  withdrawalId?: string;
  disputeCode?: string;
  reference?: string;
};

function laClientGoc(db: DbClient | PrismaService): db is PrismaService {
  return typeof (db as PrismaService).$transaction === 'function';
}

function coPhanHoan(don: {
  totalPrice: number | null;
  cancellationFee: number | null;
}): boolean {
  return (
    don.cancellationFee !== null && don.cancellationFee < (don.totalPrice ?? 0)
  );
}

@Injectable()
export class WalletLedgerService {
  private readonly logger = new Logger(WalletLedgerService.name);

  constructor(private readonly prisma: PrismaService) {}

  async layVi(sitterId: string, db: DbClient | PrismaService = this.prisma) {
    return db.wallet.upsert({
      where: { sitterId },
      create: { sitterId },
      update: {},
    });
  }

  async ghi(
    sitterId: string,
    tin: TinGhiSo,
    db: DbClient | PrismaService = this.prisma,
  ) {
    if (laClientGoc(db)) {
      return db.$transaction((tx) => this.ghiTrongTran(sitterId, tin, tx));
    }
    return this.ghiTrongTran(sitterId, tin, db);
  }

  private async ghiTrongTran(sitterId: string, tin: TinGhiSo, db: DbClient) {
    const soTien = tin.soTien;
    if (!Number.isInteger(soTien)) {
      throw new ConflictException({
        code: 'SO_TIEN_KHONG_NGUYEN',
        message: 'Số tiền ghi sổ ví phải là số nguyên đồng',
      });
    }
    const vi = await db.wallet.upsert({
      where: { sitterId },
      create: { sitterId, balance: soTien },
      update: { balance: { increment: soTien } },
    });
    if (vi.balance < 0) {
      throw new ConflictException({
        code: 'VUOT_SO_DU',
        message: 'Số dư khả dụng không đủ cho khoản trừ này',
      });
    }
    return db.walletTransaction.create({
      data: {
        walletId: vi.id,
        code: maGiaoDichVi(tin.loai),
        kind: tin.loai,
        title: tin.tieuDe,
        amount: soTien,
        balanceAfter: vi.balance,
        bookingId: tin.bookingId ?? null,
        withdrawalId: tin.withdrawalId ?? null,
        disputeCode: tin.disputeCode ?? null,
        reference: tin.reference ?? null,
      },
    });
  }

  async nhaEscrow(bookingId: string): Promise<boolean> {
    const don = await this.prisma.booking.findUnique({
      where: { id: bookingId },
      select: {
        id: true,
        code: true,
        sitterId: true,
        sitterPayout: true,
        totalPrice: true,
        platformFee: true,
        cancellationFee: true,
        owner: { select: { fullName: true } },
        reports: {
          where: { status: { not: 'RESOLVED' } },
          select: { id: true },
        },
      },
    });
    if (!don) return false;
    if (don.reports.length > 0) {
      this.logger.log(`Đơn ${don.code} đang khiếu nại, chưa nhả tiền vào ví`);
      return false;
    }
    const khoan = await this.prisma.payment.findFirst({
      where: { bookingId, status: 'HELD' },
      orderBy: { createdAt: 'desc' },
      select: { id: true, amount: true },
    });
    if (!khoan) return false;

    const nccNhan =
      don.sitterPayout ??
      Math.max(0, (don.totalPrice ?? khoan.amount) - (don.platformFee ?? 0));
    const conHoan = coPhanHoan(don);
    if (nccNhan <= 0 && !conHoan) return false;

    return this.prisma.$transaction(async (tx) => {
      const doi = await tx.payment.updateMany({
        where: { id: khoan.id, status: 'HELD' },
        data: conHoan
          ? { status: 'REFUNDING' }
          : { status: 'RELEASED', releasedAt: new Date() },
      });
      if (doi.count === 0) return false;
      if (nccNhan > 0) {
        await this.ghi(
          don.sitterId,
          {
            loai: 'TIEN_VAO',
            tieuDe: don.owner.fullName ?? 'Đơn đã hoàn thành',
            soTien: nccNhan,
            bookingId: don.id,
          },
          tx,
        );
      }
      return true;
    });
  }
}
