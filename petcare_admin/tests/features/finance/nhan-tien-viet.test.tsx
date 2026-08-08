import { describe, expect, it } from 'vitest';
import { screen } from '@testing-library/react';
import { RefundDialog } from '@/features/finance/components/refund-dialog';
import { renderVoiKhung } from '@tests/support/render';

const DONG_HOAN = {
  bookingCode: 'PC9C4RN6',
  ownerName: 'Nguyễn Hải Yến',
  ownerPhone: '0901234567',
  txnRef: 'PC9C4RN6-1',
  gatewayTxnNo: '14512345',
  gatewayPayDate: '20260805143000',
  bankCode: 'NCB',
  cardType: 'ATM',
  amount: 90000,
  paymentAmount: 180000,
  reason: 'LATE_CANCEL' as const,
  cancelReasonText: null,
  requestedAt: '2026-08-05T07:30:00.000Z',
  status: 'REFUNDING' as const,
  refundReference: null,
  refundNote: null,
  refundedAt: null,
};

describe('Hộp thoại đối soát hoàn tiền', () => {
  it('nhãn từng dòng là lời người dùng, không phải tên cột trong bảng', () => {
    renderVoiKhung(<RefundDialog row={DONG_HOAN} onClose={() => {}} />);

    expect(screen.getByText('Mã giao dịch')).toBeInTheDocument();
    expect(screen.getByText('Mã cổng trả về')).toBeInTheDocument();
    expect(screen.getByText('Thời điểm cổng ghi nhận')).toBeInTheDocument();
    expect(screen.queryByText('txnRef')).toBeNull();
    expect(screen.queryByText('gatewayTxnNo')).toBeNull();
    expect(screen.queryByText('gatewayPayDate')).toBeNull();
  });
});
