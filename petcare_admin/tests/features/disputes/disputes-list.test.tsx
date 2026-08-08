import { http, HttpResponse } from 'msw';
import { describe, expect, it } from 'vitest';
import { screen, waitFor } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { MemoryRouter, Route, Routes } from 'react-router-dom';
import { DisputesScreen } from '@/features/disputes/screens/disputes-screen';
import { renderVoiKhung } from '@tests/support/render';
import { server } from '@tests/support/server';

const DEM_TAB = { waitingSitter: 3, waitingSupport: 5, resolved: 12 };

function hoSo(ghiDe: Record<string, unknown> = {}) {
  return {
    code: 'KN-PC9C4RN6',
    bookingCode: 'PC9C4RN6',
    serviceType: 'WALKING',
    serviceName: 'Dắt đi dạo',
    reporterName: 'Nguyễn Hải Yến',
    reporterRole: 'OWNER',
    reporterAvatarUrl: null,
    sitterName: 'Trịnh Văn Nam',
    description: 'Người chăm tới muộn 40 phút',
    createdAt: '2026-08-06T02:00:00+07:00',
    replyDeadline: '2026-08-07T02:00:00+07:00',
    sitterReplyAt: null,
    status: 'OPEN',
    refundAmount: null,
    ...ghiDe,
  };
}

function dungKho(items: Array<Record<string, unknown>>) {
  const duongDan: string[] = [];
  server.use(
    http.get('*/admin/disputes/counts', () => HttpResponse.json(DEM_TAB)),
    http.get('*/admin/disputes', ({ request }) => {
      duongDan.push(new URL(request.url).search);
      return HttpResponse.json({ total: items.length, page: 1, limit: 10, items });
    }),
  );
  return duongDan;
}

function moMan() {
  renderVoiKhung(
    <MemoryRouter initialEntries={['/disputes']}>
      <Routes>
        <Route path="/disputes" element={<DisputesScreen />} />
        <Route
          path="/bookings/:code/conversation"
          element={<p>Man hoi thoai cua don</p>}
        />
      </Routes>
    </MemoryRouter>,
  );
}

describe('Danh sách khiếu nại', () => {
  it('hồ sơ do người chăm mở không có hạn đáp thì để trống, không đọc là hết hạn', async () => {
    dungKho([
      hoSo({
        reporterRole: 'PROVIDER',
        reporterName: 'Trịnh Văn Nam',
        replyDeadline: null,
      }),
    ]);
    moMan();

    expect(await screen.findByText('không có lượt đáp')).toBeInTheDocument();
    // new Date(null) ra năm 1970 nên nhánh hết hạn là chỗ dễ lọt nhất
    expect(screen.queryByText('hết hạn')).not.toBeInTheDocument();
    expect(screen.queryByText(/trễ .* ngày/)).not.toBeInTheDocument();
  });

  it('gửi tên tab lên máy chủ để số đếm khớp danh sách', async () => {
    const duongDan = dungKho([hoSo()]);
    moMan();

    await screen.findByText('Nguyễn Hải Yến');
    await userEvent.setup().click(screen.getByRole('button', { name: /Đã kết luận/ }));

    await waitFor(() => expect(duongDan.length).toBeGreaterThan(1));
    const cuoi = duongDan[duongDan.length - 1];
    expect(cuoi).toContain('tab=resolved');
    expect(cuoi).toContain('sort=hanKetLuan');
  });

  it('ba tab đều đọc được số đếm của máy chủ', async () => {
    dungKho([hoSo()]);
    moMan();
    await screen.findByText('Nguyễn Hải Yến');

    const canDem: Array<[string, number]> = [
      ['Chờ người chăm đáp', DEM_TAB.waitingSitter],
      ['Chờ quản trị viên xử lý', DEM_TAB.waitingSupport],
      ['Đã kết luận', DEM_TAB.resolved],
    ];
    for (const [nhan, so] of canDem) {
      const nut = screen.getByRole('button', { name: new RegExp(`^${nhan}`) });
      expect(nut.textContent).toContain(String(so));
    }
  });

  it('nút xem hội thoại dẫn sang màn hội thoại của đơn, không báo đang làm', async () => {
    dungKho([hoSo()]);
    moMan();

    await screen.findByText('Nguyễn Hải Yến');
    await userEvent
      .setup()
      .click(screen.getByRole('button', { name: 'Xem hội thoại của đơn' }));

    expect(await screen.findByText('Man hoi thoai cua don')).toBeInTheDocument();
  });
});
