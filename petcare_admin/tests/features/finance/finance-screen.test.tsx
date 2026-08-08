import { http, HttpResponse } from 'msw';
import { describe, expect, it } from 'vitest';
import { screen, within } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { FinanceScreen } from '@/features/finance/screens/finance-screen';
import { renderVoiKhung } from '@tests/support/render';
import { server } from '@tests/support/server';

// Ô phần trăm của thẻ số liệu, không khớp câu phụ kiểu "phí nền tảng 15%"
const O_PHAN_TRAM = /^[+-]?[\d.,]+%$/;

function tongHop(deltas: Record<string, number | null>) {
  return {
    totalOrderValue: 428600000,
    commission: 64300000,
    escrowHeld: 23100000,
    releasedToWallet: 341200000,
    paidBookings: 2145,
    escrowBookings: 96,
    commissionRate: 0.15,
    deltas,
    byWeek: [{ label: 'Tuần 34', sitterPayout: 61200000, platformFee: 10800000 }],
    topSitters: [{ sitterId: 's-001', name: 'Đặng Khắc Duy', amount: 38400000 }],
    topPeriodLabel: 'tháng 8/2026',
  };
}

function lenhRut(ghiDe: Record<string, unknown> = {}) {
  return {
    id: 'wd-1',
    sitterId: 's-001',
    sitterName: 'Đặng Khắc Duy',
    bankName: 'Vietcombank',
    accountNumber: '0071000123456',
    accountHolder: 'DANG KHAC DUY',
    amount: 2400000,
    fee: 0,
    status: 'PENDING',
    reference: null,
    rejectReason: null,
    createdAt: '2026-08-05T09:00:00+07:00',
    sentAt: null,
    doneAt: null,
    ...ghiDe,
  };
}

function dungKho(
  deltas: Record<string, number | null>,
  items: Array<Record<string, unknown>> = [lenhRut()],
) {
  server.use(
    http.get('*/admin/finance/summary', () => HttpResponse.json(tongHop(deltas))),
    http.get('*/admin/withdrawals', () =>
      HttpResponse.json({ total: items.length, page: 1, limit: 10, items }),
    ),
  );
}

const KHONG_CO_KY_TRUOC = {
  totalOrderValue: null,
  commission: null,
  escrowHeld: null,
  releasedToWallet: null,
};

describe('Doanh thu và lệnh rút', () => {
  it('kỳ trước bằng 0 thì thẻ số liệu không hiện phần trăm nào', async () => {
    dungKho(KHONG_CO_KY_TRUOC);
    renderVoiKhung(<FinanceScreen />);

    expect(await screen.findByText('TỔNG GIÁ TRỊ ĐƠN')).toBeInTheDocument();
    expect(screen.queryAllByText(O_PHAN_TRAM)).toHaveLength(0);
  });

  it('có số liệu kỳ trước thì đủ bốn ô phần trăm', async () => {
    dungKho({
      totalOrderValue: 9.8,
      commission: 11.2,
      escrowHeld: 8.4,
      releasedToWallet: -4.1,
    });
    renderVoiKhung(<FinanceScreen />);

    expect(await screen.findByText('TỔNG GIÁ TRỊ ĐƠN')).toBeInTheDocument();
    expect(screen.queryAllByText(O_PHAN_TRAM)).toHaveLength(4);
  });

  it('lệnh chờ chuyển chọn được đúng hai lối, phải nhập mã mới gửi được', async () => {
    dungKho(KHONG_CO_KY_TRUOC);
    const nguoiDung = userEvent.setup();
    renderVoiKhung(<FinanceScreen />);

    await nguoiDung.click(await screen.findByText('DANG KHAC DUY'));
    const hop = await screen.findByRole('dialog');
    expect(within(hop).getAllByRole('button', { name: 'Đã chuyển khoản' })).toHaveLength(2);
    expect(within(hop).getByRole('button', { name: 'Từ chối lệnh' })).toBeInTheDocument();
    expect(within(hop).queryByRole('button', { name: 'Đánh dấu xong' })).toBeNull();

    const nutGui = within(hop).getAllByRole('button', { name: 'Đã chuyển khoản' })[1];
    expect(nutGui).toBeDisabled();
    await nguoiDung.type(within(hop).getByPlaceholderText('Ví dụ FT26080512'), 'FT26080512');
    expect(nutGui).toBeEnabled();
  });

  it('lệnh đã chuyển chỉ còn lối đánh dấu xong, không lùi về từ chối', async () => {
    dungKho(KHONG_CO_KY_TRUOC, [
      lenhRut({ status: 'SENT', reference: 'FT26080512', sentAt: '2026-08-05T10:00:00+07:00' }),
    ]);
    renderVoiKhung(<FinanceScreen />);

    await userEvent.setup().click(await screen.findByText('DANG KHAC DUY'));
    const hop = await screen.findByRole('dialog');
    expect(within(hop).getByRole('button', { name: 'Đánh dấu xong' })).toBeInTheDocument();
    expect(within(hop).queryByRole('button', { name: 'Từ chối lệnh' })).toBeNull();
    expect(within(hop).queryByRole('button', { name: 'Đã chuyển khoản' })).toBeNull();
  });

  it('lệnh đã đóng chỉ xem lại, không có nút đổi trạng thái nào', async () => {
    dungKho(KHONG_CO_KY_TRUOC, [
      lenhRut({ status: 'DONE', reference: 'FT26080512', doneAt: '2026-08-06T09:00:00+07:00' }),
    ]);
    renderVoiKhung(<FinanceScreen />);

    await userEvent.setup().click(await screen.findByText('DANG KHAC DUY'));
    const hop = await screen.findByRole('dialog');
    expect(within(hop).getByText(/chỉ xem lại/)).toBeInTheDocument();
    ['Đã chuyển khoản', 'Đánh dấu xong', 'Từ chối lệnh'].forEach((nhan) => {
      expect(within(hop).queryByRole('button', { name: nhan })).toBeNull();
    });
  });
});
