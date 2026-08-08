import { http, HttpResponse } from 'msw';
import { describe, expect, it } from 'vitest';
import { screen } from '@testing-library/react';
import { PaymentRawDialog } from '@/features/finance/components/payment-raw-dialog';
import { renderVoiKhung } from '@tests/support/render';
import { server } from '@tests/support/server';

const DONG_GIAO_DICH = {
  id: 'pay-1',
  bookingCode: 'PC9C4RN6',
  ownerName: 'Nguyễn Hải Yến',
  ownerPhone: '0901234567',
  txnRef: 'PC9C4RN6-1',
  gateway: 'vnpay' as const,
  gatewayTxnNo: '14512345',
  gatewayPayDate: '20260805143000',
  bankCode: 'NCB',
  cardType: 'ATM',
  amount: 180000,
  status: 'HELD' as const,
  paidAt: '2026-08-05T07:30:00.000Z',
  releasedAt: null,
  expiresAt: '2026-08-05T07:40:00.000Z',
  createdAt: '2026-08-05T07:20:00.000Z',
};

describe('Payload nguyên văn của giao dịch', () => {
  it('gọi hỏng thì báo lỗi kèm nút thử lại, không khai là chưa có payload', async () => {
    server.use(
      http.get('*/admin/payments/:txnRef/raw', () => HttpResponse.error()),
    );
    renderVoiKhung(<PaymentRawDialog row={DONG_GIAO_DICH} onClose={() => {}} />);

    expect(await screen.findByRole('button', { name: 'Thử lại' })).toBeInTheDocument();
    expect(screen.queryByText(/chưa có dữ liệu trả về/)).toBeNull();
  });

  it('cột Json trả về object thì hiện chuỗi đã dựng lại, không vỡ màn', async () => {
    server.use(
      http.get('*/admin/payments/:txnRef/raw', () =>
        HttpResponse.json({
          txnRef: 'PC9C4RN6-1',
          gateway: 'vnpay',
          rawReturn: { vnp_ResponseCode: '00', vnp_Amount: 18000000 },
        }),
      ),
    );
    renderVoiKhung(<PaymentRawDialog row={DONG_GIAO_DICH} onClose={() => {}} />);

    expect(await screen.findByText(/vnp_ResponseCode/)).toBeInTheDocument();
    expect(screen.queryByRole('button', { name: 'Thử lại' })).toBeNull();
  });
});
