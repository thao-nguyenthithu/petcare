import { http, HttpResponse } from 'msw';
import { describe, expect, it } from 'vitest';
import { screen, waitFor, within } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { RefundsScreen } from '@/features/finance/screens/refunds-screen';
import { renderVoiKhung } from '@tests/support/render';
import { server } from '@tests/support/server';

// Đúng hai khoá mà GET /admin/refunds/counts trả về
const DEM_TAB = { refunding: 3, refunded: 8 };

function dong(ghiDe: Record<string, unknown> = {}) {
  return {
    bookingId: 'bk-1',
    bookingCode: 'PC6Q5MT3',
    ownerName: 'Trần Minh Anh',
    ownerPhone: '0912 345 678',
    txnRef: 'PC6Q5MT3-1',
    gatewayTxnNo: '14892117',
    gatewayPayDate: '20260804084512',
    bankCode: 'NCB',
    cardType: 'ATM',
    amount: 180000,
    paymentAmount: 180000,
    reason: 'FULL_CANCEL',
    cancelReasonText: 'Chủ nuôi bận đột xuất',
    requestedAt: '2026-08-05T19:10:00+07:00',
    status: 'REFUNDING',
    refundReference: null,
    refundNote: null,
    refundedAt: null,
    ...ghiDe,
  };
}

function dungKho(items: Array<Record<string, unknown>>) {
  const duongDan: string[] = [];
  server.use(
    http.get('*/admin/refunds/counts', () => HttpResponse.json(DEM_TAB)),
    http.get('*/admin/refunds', ({ request }) => {
      duongDan.push(new URL(request.url).search);
      return HttpResponse.json({ total: items.length, page: 1, limit: 10, items });
    }),
  );
  return duongDan;
}

describe('Đóng lệnh hoàn tiền', () => {
  it('chỉ có hai tab và không còn nút duyệt nào trong màn', async () => {
    dungKho([dong()]);
    renderVoiKhung(<RefundsScreen />);

    await screen.findByText('Trần Minh Anh');
    expect(screen.getByRole('button', { name: /^Đang hoàn/ })).toBeInTheDocument();
    expect(screen.getByRole('button', { name: /^Đã hoàn/ })).toBeInTheDocument();
    expect(screen.queryByRole('button', { name: /duyệt/i })).toBeNull();
    expect(screen.queryByRole('button', { name: /chờ duyệt/i })).toBeNull();
    expect(screen.queryByRole('button', { name: /cổng từ chối/i })).toBeNull();
  });

  it('màn không có nút xuất file, đối soát là việc của màn giao dịch', async () => {
    dungKho([dong()]);
    renderVoiKhung(<RefundsScreen />);

    await screen.findByText('Trần Minh Anh');
    expect(screen.queryByRole('button', { name: /xuất/i })).toBeNull();
  });

  it('đổi tab thì gửi đúng trạng thái lên máy chủ', async () => {
    const duongDan = dungKho([dong()]);
    renderVoiKhung(<RefundsScreen />);

    await screen.findByText('Trần Minh Anh');
    expect(duongDan[0]).toContain('status=REFUNDING');

    await userEvent.setup().click(screen.getByRole('button', { name: /^Đã hoàn/ }));
    await waitFor(() => expect(duongDan.length).toBeGreaterThan(1));
    expect(duongDan[duongDan.length - 1]).toContain('status=REFUNDED');
  });

  it('lý do huỷ rỗng thì hiện chữ xám Chưa có chứ không dùng dấu gạch', async () => {
    dungKho([dong({ cancelReasonText: null })]);
    const { container } = renderVoiKhung(<RefundsScreen />);

    await screen.findByText('Trần Minh Anh');
    expect(screen.getByText('Chưa có')).toBeInTheDocument();
    expect(container.textContent).not.toContain('—');
  });

  it('dòng đã hoàn chỉ xem lại, hộp thoại hiện đủ mã tham chiếu, ghi chú và mốc chốt', async () => {
    dungKho([
      dong({
        status: 'REFUNDED',
        refundReference: 'MERCHANT-26080201',
        refundNote: 'Cổng khoá lệnh hoàn tự động',
        refundedAt: '2026-08-06T10:15:00+07:00',
      }),
    ]);
    renderVoiKhung(<RefundsScreen />);

    await screen.findByText('Trần Minh Anh');
    expect(screen.queryByRole('button', { name: 'Đánh dấu đã hoàn tay' })).toBeNull();

    await userEvent.setup().click(screen.getByRole('button', { name: 'Xem giao dịch gốc' }));
    const hop = await screen.findByRole('dialog');
    expect(within(hop).getByText('MERCHANT-26080201')).toBeInTheDocument();
    expect(within(hop).getByText('Cổng khoá lệnh hoàn tự động')).toBeInTheDocument();
    expect(within(hop).getByText(/06\/08\/2026/)).toBeInTheDocument();
  });

  it('mã tham chiếu ngắn thì khoá nút gửi, đủ mã thì gọi đúng mark-manual', async () => {
    dungKho([dong()]);
    let than: Record<string, unknown> | null = null;
    let duongDan = '';
    server.use(
      http.post('*/admin/refunds/:txnRef/mark-manual', async ({ request, params }) => {
        duongDan = String(params.txnRef);
        than = (await request.json()) as Record<string, unknown>;
        return HttpResponse.json({
          txnRef: duongDan,
          status: 'REFUNDED',
          refundedAt: '2026-08-06T10:15:00+07:00',
        });
      }),
    );

    const nguoiDung = userEvent.setup();
    renderVoiKhung(<RefundsScreen />);
    await screen.findByText('Trần Minh Anh');
    await nguoiDung.click(screen.getByRole('button', { name: 'Đánh dấu đã hoàn tay' }));

    const hop = await screen.findByRole('dialog');
    const nutGui = within(hop).getByRole('button', { name: 'Đánh dấu đã hoàn' });
    expect(nutGui).toBeDisabled();

    const oMa = within(hop).getByPlaceholderText('Ví dụ HOAN-26080201');
    await nguoiDung.type(oMa, 'AB');
    expect(nutGui).toBeDisabled();
    expect(within(hop).getByText(/ít nhất 3 ký tự/)).toBeInTheDocument();

    await nguoiDung.type(oMa, 'C-01');
    expect(nutGui).toBeEnabled();

    await nguoiDung.type(
      within(hop).getByPlaceholderText(/Ví dụ cổng khoá/),
      'Chuyển tay trên cổng',
    );
    await nguoiDung.click(nutGui);

    await waitFor(() => expect(than).not.toBeNull());
    expect(duongDan).toBe('PC6Q5MT3-1');
    expect(than).toEqual({ reference: 'ABC-01', note: 'Chuyển tay trên cổng' });
  });
});
