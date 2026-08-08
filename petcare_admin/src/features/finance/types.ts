export const PAYMENT_STATUSES = [
  'PENDING',
  'HELD',
  'RELEASED',
  'REFUNDING',
  'REFUNDED',
  'FAILED',
  'EXPIRED',
] as const;
export type PaymentStatus = (typeof PAYMENT_STATUSES)[number];

export const WITHDRAWAL_STATUSES = ['PENDING', 'SENT', 'DONE', 'REJECTED'] as const;
export type WithdrawalStatus = (typeof WITHDRAWAL_STATUSES)[number];

export const PAYMENT_GATEWAYS = ['vnpay', 'mock', 'auto'] as const;
export type PaymentGateway = (typeof PAYMENT_GATEWAYS)[number];

export type RefundReason = 'DISPUTE_RESOLUTION' | 'LATE_CANCEL' | 'FULL_CANCEL';

export type RefundStatus = 'REFUNDING' | 'REFUNDED';

export type PaymentTabKey = 'escrow' | 'released' | 'refunding' | 'failed';
export type RefundTabKey = 'refunding' | 'refunded';

export type FinanceSummary = {
  totalOrderValue: number;
  commission: number;
  escrowHeld: number;
  releasedToWallet: number;
  paidBookings: number;
  escrowBookings: number;
  commissionRate: number;
  deltas: {
    totalOrderValue: number | null;
    commission: number | null;
    escrowHeld: number | null;
    releasedToWallet: number | null;
  };
  byWeek: Array<{ label: string; sitterPayout: number; platformFee: number }>;
  topSitters: Array<{ sitterId: string; name: string; amount: number }>;
  topPeriodLabel: string;
};

export type WithdrawalRow = {
  id: string;
  sitterName: string;
  bankName: string;
  accountNumber: string;
  accountHolder: string;
  amount: number;
  fee: number;
  status: WithdrawalStatus;
  reference: string | null;
  rejectReason: string | null;
  createdAt: string;
  sentAt: string | null;
  doneAt: string | null;
};

export type WithdrawalListQuery = {
  status?: WithdrawalStatus;
  q?: string;
  from?: string;
  to?: string;
  page?: number;
  limit?: number;
};

export type WithdrawalListResponse = {
  total: number;
  page: number;
  limit: number;
  items: WithdrawalRow[];
};

export type UpdateWithdrawalInput = {
  id: string;
  status: Extract<WithdrawalStatus, 'SENT' | 'DONE' | 'REJECTED'>;
  reference?: string;
  rejectReason?: string;
};

export type PaymentRow = {
  id: string;
  bookingCode: string;
  ownerName: string;
  ownerPhone: string;
  txnRef: string;
  gateway: PaymentGateway;
  gatewayTxnNo: string | null;
  gatewayPayDate: string | null;
  bankCode: string | null;
  cardType: string | null;
  responseCode: string | null;
  amount: number;
  status: PaymentStatus;
  paidAt: string | null;
  releasedAt: string | null;
  expiresAt: string | null;
  createdAt: string;
};

export type PaymentListQuery = {
  status?: PaymentStatus[];
  gateway?: PaymentGateway;
  bankCode?: string;
  q?: string;
  from?: string;
  to?: string;
  page?: number;
  limit?: number;
};

export type PaymentListResponse = {
  total: number;
  page: number;
  limit: number;
  items: PaymentRow[];
};

export type RefundRow = {
  bookingCode: string;
  ownerName: string;
  ownerPhone: string;
  txnRef: string;
  gatewayTxnNo: string | null;
  gatewayPayDate: string | null;
  bankCode: string | null;
  cardType: string | null;
  amount: number;
  paymentAmount: number;
  reason: RefundReason;
  cancelReasonText: string | null;
  requestedAt: string;
  status: RefundStatus;
  refundReference: string | null;
  refundNote: string | null;
  refundedAt: string | null;
};

export type RefundListQuery = {
  status?: RefundStatus;
  reason?: RefundReason;
  bankCode?: string;
  q?: string;
  from?: string;
  to?: string;
  page?: number;
  limit?: number;
};

export type RefundListResponse = {
  total: number;
  page: number;
  limit: number;
  items: RefundRow[];
};

export type MarkRefundManualInput = {
  txnRef: string;
  reference: string;
  note?: string;
};

export type MarkRefundManualResult = {
  txnRef: string;
  status: RefundStatus;
  refundedAt: string;
};
