import { Prisma } from '../../../../generated/prisma/client';
import { PaymentStatus } from '../../../../generated/prisma/enums';

// Ba giá trị suy được chắc chắn từ con số, KHÔNG so chuỗi cancellationReason
export const LY_DO_HOAN = [
  'DISPUTE_RESOLUTION',
  'LATE_CANCEL',
  'FULL_CANCEL',
] as const;
export type LyDoHoan = (typeof LY_DO_HOAN)[number];

// Hai trạng thái duy nhất của màn hoàn tiền
export const TRANG_THAI_HOAN = [
  PaymentStatus.REFUNDING,
  PaymentStatus.REFUNDED,
];

export type KetLuanHoan = { refundAmount: number | null } | null | undefined;

export type NguonSuyHoan = {
  totalPrice: number | null;
  cancellationFee: number | null;
  ketLuan: KetLuanHoan;
};

export function suyLyDoHoan(don: NguonSuyHoan): LyDoHoan {
  if ((don.ketLuan?.refundAmount ?? 0) > 0) return 'DISPUTE_RESOLUTION';
  if ((don.cancellationFee ?? 0) > 0) return 'LATE_CANCEL';
  return 'FULL_CANCEL';
}

// Kẹp theo số đã thu vì hoàn là đảo ngược chính giao dịch đó (bộ luật mục 2)
export function tinhTienHoan(
  don: NguonSuyHoan,
  lyDo: LyDoHoan,
  tienDaTra: number,
): number {
  const tong = don.totalPrice ?? 0;
  const tho =
    lyDo === 'DISPUTE_RESOLUTION'
      ? (don.ketLuan?.refundAmount ?? 0)
      : lyDo === 'LATE_CANCEL'
        ? tong - (don.cancellationFee ?? 0)
        : tong;
  return Math.max(0, Math.min(tho, tienDaTra));
}

const CO_KET_LUAN_HOAN: Prisma.BookingWhereInput = {
  reports: { some: { resolvedAt: { not: null }, refundAmount: { gt: 0 } } },
};

export function dieuKienLyDo(lyDo: LyDoHoan): Prisma.PaymentWhereInput {
  if (lyDo === 'DISPUTE_RESOLUTION') return { booking: CO_KET_LUAN_HOAN };
  if (lyDo === 'LATE_CANCEL') {
    return {
      booking: { NOT: CO_KET_LUAN_HOAN, cancellationFee: { gt: 0 } },
    };
  }
  return {
    booking: {
      NOT: CO_KET_LUAN_HOAN,
      OR: [{ cancellationFee: null }, { cancellationFee: { lte: 0 } }],
    },
  };
}
