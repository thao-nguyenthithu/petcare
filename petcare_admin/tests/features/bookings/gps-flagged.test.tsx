import { http, HttpResponse } from 'msw';
import { describe, expect, it } from 'vitest';
import { fireEvent, screen, waitFor } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { MemoryRouter } from 'react-router-dom';
import { GpsFlaggedScreen } from '@/features/bookings/screens/gps-flagged-screen';
import { renderVoiKhung } from '@tests/support/render';
import { server } from '@tests/support/server';

const DEM_TAB = { flagged: 2, reviewed: 1, noClaim: 1, all: 3 };

function dong(ghiDe: Record<string, unknown>) {
  return {
    bookingCode: 'PC-001',
    sitterId: 'ncc-1',
    sitterName: 'Trịnh Văn Nam',
    suspicionScore: 0.82,
    flaggedForReview: true,
    suspicionNote: null,
    totalDistanceM: 1200,
    claimedDistanceKm: 3.4,
    totalWaypoints: 38,
    durationMinutes: 60,
    avgSpeedKmh: 1.2,
    mockedCount: 0,
    speedFlag: false,
    reviewedAt: null,
    createdAt: '2026-08-02T17:05:00+07:00',
    ...ghiDe,
  };
}

// Ghi lại từng lượt hỏi danh sách để soi đúng tham số màn gửi lên
function dungKho(items: Array<Record<string, unknown>>) {
  const duongDan: string[] = [];
  server.use(
    http.get('*/admin/gps-reports/counts', () => HttpResponse.json(DEM_TAB)),
    http.get('*/admin/gps-reports', ({ request }) => {
      duongDan.push(new URL(request.url).search);
      return HttpResponse.json({ total: items.length, page: 1, limit: 10, items });
    }),
  );
  return duongDan;
}

function moMan() {
  renderVoiKhung(
    <MemoryRouter>
      <GpsFlaggedScreen />
    </MemoryRouter>,
  );
}

describe('Hàng chờ đơn gắn cờ GPS', () => {
  it('app chưa khai số km thì bỏ trống cả điểm lẫn nhãn, không chấm điểm sạch', async () => {
    dungKho([dong({ claimedDistanceKm: null, suspicionScore: null })]);
    moMan();

    expect(await screen.findByText('ứng dụng chưa khai số km')).toBeInTheDocument();
    expect(screen.getByText('App chưa khai số km')).toBeInTheDocument();
    expect(screen.getByText('không có số app khai để đối chiếu')).toBeInTheDocument();
    // 0,00 là điểm sạch nhất bảng, hiện nó ra là nói dối người soát
    expect(screen.queryByText('0,00')).not.toBeInTheDocument();
    expect(screen.queryByText('Trong sai số')).not.toBeInTheDocument();
  });

  it('đơn không gắn cờ mà chưa ai soát thì nói rõ là chưa ai soát', async () => {
    dungKho([dong({ flaggedForReview: false, reviewedAt: null })]);
    moMan();

    expect(await screen.findByText('Không gắn cờ')).toBeInTheDocument();
    expect(screen.getByText('Chưa ai soát')).toBeInTheDocument();
    // Cờ tắt không phải là bằng chứng có người đã xem đơn này
    expect(screen.queryByText(/Đã soát lúc/)).not.toBeInTheDocument();
  });

  it('hiện hai chỉ số chống gian lận mà không có nút phạt nào', async () => {
    dungKho([dong({ mockedCount: 3, speedFlag: true })]);
    moMan();

    expect(await screen.findByText('3 điểm vị trí giả')).toBeInTheDocument();
    expect(screen.getByText('Tốc độ như đi xe')).toBeInTheDocument();
    expect(screen.getByText(/hệ thống không tự phạt hay trừ tiền/)).toBeInTheDocument();
    expect(screen.queryByRole('button', { name: /phạt/i })).not.toBeInTheDocument();
  });

  it('tab chưa khai chỉ gửi tên tab, điều kiện để máy chủ giữ', async () => {
    const duongDan = dungKho([dong({})]);
    moMan();

    await screen.findByText('Trịnh Văn Nam');
    await userEvent.setup().click(screen.getByRole('button', { name: /Chưa khai số km/ }));

    await waitFor(() => expect(duongDan.length).toBeGreaterThan(1));
    const cuoi = duongDan[duongDan.length - 1];
    expect(cuoi).toContain('tab=noClaim');
    expect(cuoi).not.toContain('minScore');
  });

  it('gỡ cờ bắt nhập ghi chú rồi mới gửi lệnh soát', async () => {
    dungKho([dong({})]);
    let thanGui: unknown = null;
    server.use(
      http.patch('*/admin/gps-reports/:code/review', async ({ request }) => {
        thanGui = await request.json();
        return HttpResponse.json({ bookingCode: 'PC-001', flaggedForReview: false });
      }),
    );
    const nguoiDung = userEvent.setup();
    moMan();

    await nguoiDung.click(await screen.findByRole('button', { name: 'Gỡ cờ phiên này' }));
    const nutXacNhan = screen.getByRole('button', { name: 'Gỡ cờ' });
    expect(nutXacNhan).toBeDisabled();

    fireEvent.change(screen.getByRole('textbox'), { target: { value: 'Đi qua hầm' } });
    await waitFor(() => expect(nutXacNhan).toBeEnabled());
    await nguoiDung.click(nutXacNhan);

    await waitFor(() =>
      expect(thanGui).toEqual({ cleared: true, note: 'Đi qua hầm' }),
    );
  });
});
