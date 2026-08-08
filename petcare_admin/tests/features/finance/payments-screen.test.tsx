import { http, HttpResponse } from 'msw';
import { afterEach, describe, expect, it, vi } from 'vitest';
import { screen, waitFor, within } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { MemoryRouter } from 'react-router-dom';
import { PaymentsScreen } from '@/features/finance/screens/payments-screen';
import { renderVoiKhung } from '@tests/support/render';
import { server } from '@tests/support/server';

// Đúng bốn khoá mà GET /admin/payments/counts trả về
const DEM_TAB = { escrow: 12, released: 40, refunding: 3, failed: 5 };

function dong(ghiDe: Record<string, unknown> = {}) {
  return {
    id: 'pm-1',
    bookingId: 'bk-1',
    bookingCode: 'PC6Q5MT3',
    ownerName: 'Trần Minh Anh',
    ownerPhone: '0912 345 678',
    txnRef: 'PC6Q5MT3-1',
    gateway: 'vnpay',
    gatewayTxnNo: '14892117',
    gatewayPayDate: '20260804084512',
    bankCode: 'NCB',
    cardType: 'ATM',
    responseCode: '00',
    amount: 180000,
    status: 'HELD',
    paidAt: '2026-08-04T08:45:12+07:00',
    releasedAt: null,
    expiresAt: null,
    createdAt: '2026-08-04T08:40:00+07:00',
    ...ghiDe,
  };
}

function dungKho(items: Array<Record<string, unknown>>, total = items.length) {
  const duongDan: string[] = [];
  server.use(
    http.get('*/admin/payments/counts', () => HttpResponse.json(DEM_TAB)),
    http.get('*/admin/payments', ({ request }) => {
      const url = new URL(request.url);
      duongDan.push(url.search);
      const limit = Number(url.searchParams.get('limit') ?? 10);
      return HttpResponse.json({
        total,
        page: Number(url.searchParams.get('page') ?? 1),
        limit,
        items,
      });
    }),
  );
  return duongDan;
}

function moMan() {
  renderVoiKhung(
    <MemoryRouter>
      <PaymentsScreen />
    </MemoryRouter>,
  );
}

// Không stub cả đối tượng URL: axios và msw còn cần new URL(), thay đúng hai hàm blob
function chanTaiVe(bat?: (noiDung: string) => void) {
  const goc = { tao: URL.createObjectURL, thu: URL.revokeObjectURL };
  phucHoi.push(() => {
    URL.createObjectURL = goc.tao;
    URL.revokeObjectURL = goc.thu;
  });
  const taoUrl = vi.fn((blob: Blob) => {
    if (bat) void blob.text().then(bat);
    return 'blob:test';
  });
  URL.createObjectURL = taoUrl as unknown as typeof URL.createObjectURL;
  URL.revokeObjectURL = vi.fn();
  return taoUrl;
}

const phucHoi: Array<() => void> = [];

afterEach(() => {
  phucHoi.splice(0).forEach((ham) => ham());
  vi.restoreAllMocks();
});

describe('Giao dịch thanh toán', () => {
  it('bốn tab phủ hết bảy trạng thái, tab escrow gửi cả PENDING lẫn HELD', async () => {
    const duongDan = dungKho([dong()]);
    moMan();

    await screen.findByText('Trần Minh Anh');
    ['Đang tạm giữ', 'Đã chuyển vào ví', 'Đang hoàn', 'Hỏng và hết hạn'].forEach((nhan) => {
      expect(screen.getByRole('button', { name: new RegExp(`^${nhan}`) })).toBeInTheDocument();
    });
    expect(duongDan[0]).toContain('status=PENDING,HELD');

    await userEvent.setup().click(screen.getByRole('button', { name: /^Hỏng và hết hạn/ }));
    await waitFor(() => expect(duongDan.length).toBeGreaterThan(1));
    expect(duongDan[duongDan.length - 1]).toContain('status=FAILED,EXPIRED');
  });

  it('bộ lọc cổng có cả auto, bỏ sót là bản ghi lúc tắt VNPay rơi khỏi bảng', async () => {
    const duongDan = dungKho([dong({ gateway: 'auto', gatewayTxnNo: null })]);
    moMan();

    await screen.findByText('Trần Minh Anh');
    expect(screen.getByText('Tự chốt, VNPay đang tắt')).toBeInTheDocument();

    const nguoiDung = userEvent.setup();
    await nguoiDung.click(screen.getByRole('button', { name: 'Cổng' }));
    await nguoiDung.click(
      await screen.findByRole('button', { name: 'Tự chốt, VNPay đang tắt' }),
    );

    await waitFor(() =>
      expect(duongDan[duongDan.length - 1]).toContain('gateway=auto'),
    );
  });

  it('mở được hộp thoại payload thô và không có nút nào đổi trạng thái', async () => {
    dungKho([dong()]);
    server.use(
      http.get('*/admin/payments/:txnRef/raw', () =>
        HttpResponse.json({ rawReturn: '{"vnp_ResponseCode":"00"}' }),
      ),
    );
    moMan();

    await screen.findByText('Trần Minh Anh');
    await userEvent.setup().click(screen.getByRole('button', { name: 'Xem dữ liệu cổng trả về' }));

    const hop = await screen.findByRole('dialog');
    expect(await within(hop).findByText(/vnp_ResponseCode/)).toBeInTheDocument();
    expect(within(hop).getByText('Mã kết quả cổng trả')).toBeInTheDocument();
    expect(within(hop).queryByRole('button', { name: /hoàn tiền|đánh dấu/i })).toBeNull();
  });

  it('cột rawReturn là Json nên cổng trả đối tượng, hộp thoại vẫn đọc được', async () => {
    dungKho([dong()]);
    server.use(
      http.get('*/admin/payments/:txnRef/raw', () =>
        HttpResponse.json({
          rawReturn: { vnp_ResponseCode: '00', vnp_Amount: '100000' },
        }),
      ),
    );
    moMan();

    await screen.findByText('Trần Minh Anh');
    await userEvent.setup().click(screen.getByRole('button', { name: 'Xem dữ liệu cổng trả về' }));

    const hop = await screen.findByRole('dialog');
    expect(await within(hop).findByText(/vnp_Amount/)).toBeInTheDocument();
    expect(within(hop).queryByText(/\[object Object\]/)).toBeNull();
  });

  it('vượt trần dòng thì không tải tệp, bảo thu hẹp bộ lọc', async () => {
    const duongDan = dungKho([dong()], 1500);
    const taoUrl = chanTaiVe();
    moMan();

    await screen.findByText('Trần Minh Anh');
    await userEvent.setup().click(screen.getByRole('button', { name: 'Xuất tệp đối soát' }));

    await waitFor(() => expect(duongDan.some((item) => item.includes('limit=50'))).toBe(true));
    expect(taoUrl).not.toHaveBeenCalled();
  });

  it('tệp xuất có đủ txnRef, gatewayTxnNo và gatewayPayDate', async () => {
    dungKho([dong()]);
    let noiDung = '';
    vi.spyOn(HTMLAnchorElement.prototype, 'click').mockImplementation(() => {});
    chanTaiVe((text) => {
      noiDung = text;
    });
    moMan();

    await screen.findByText('Trần Minh Anh');
    await userEvent.setup().click(screen.getByRole('button', { name: 'Xuất tệp đối soát' }));

    await waitFor(() => expect(noiDung).toContain('gatewayPayDate'));
    expect(noiDung).toContain('txnRef');
    expect(noiDung).toContain('gatewayTxnNo');
    expect(noiDung).toContain('"PC6Q5MT3-1"');
    expect(noiDung).toContain('"20260804084512"');
  });
});
