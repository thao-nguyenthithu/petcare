import type {
  PaymentStatus,
  PaymentTabKey,
  RefundReason,
  RefundStatus,
  RefundTabKey,
} from '@/features/finance/types';

export const TRANG_THAI_THEO_TAB_GIAO_DICH: Record<PaymentTabKey, PaymentStatus[]> = {
  escrow: ['PENDING', 'HELD'],
  released: ['RELEASED'],
  refunding: ['REFUNDING', 'REFUNDED'],
  failed: ['FAILED', 'EXPIRED'],
};

export const THU_TU_TAB_GIAO_DICH: PaymentTabKey[] = ['escrow', 'released', 'refunding', 'failed'];

export const TRANG_THAI_THEO_TAB_HOAN: Record<RefundTabKey, RefundStatus> = {
  refunding: 'REFUNDING',
  refunded: 'REFUNDED',
};

export const THU_TU_TAB_HOAN: RefundTabKey[] = ['refunding', 'refunded'];

export const LY_DO_HOAN: RefundReason[] = ['DISPUTE_RESOLUTION', 'LATE_CANCEL', 'FULL_CANCEL'];

export const DO_DAI_MA_HOAN_TOI_THIEU = 3;

export const MA_NGAN_HANG = ['NCB', 'VCB', 'TCB', 'MB', 'VIB', 'ACB'];
