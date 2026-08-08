import { http, HttpResponse } from 'msw';
import { describe, expect, it } from 'vitest';
import { screen, waitFor } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { MemoryRouter } from 'react-router-dom';
import { BookingsScreen } from '@/features/bookings/screens/bookings-screen';
import { renderVoiKhung } from '@tests/support/render';
import { server } from '@tests/support/server';

// Đúng chín khoá mà GET /admin/bookings/counts trả về
const DEM_TAB = {
  all: 24,
  awaitingPayment: 2,
  pending: 3,
  confirmed: 4,
  running: 5,
  awaitingConfirm: 1,
  completed: 6,
  cancelled: 2,
  disputed: 1,
};

function dong(ghiDe: Record<string, unknown> = {}) {
  return {
    code: 'PC6Q5MT3',
    ownerName: 'Trần Minh Anh',
    petNames: ['Mochi', 'Bơ'],
    sitterName: 'Đặng Khắc Duy',
    sitterRating: 4.9,
    serviceType: 'WALKING',
    serviceName: 'Dắt đi dạo',
    durationMinutes: 60,
    scheduledAt: '2026-08-04T09:00:00+07:00',
    scheduledEndAt: '2026-08-04T10:00:00+07:00',
    totalPrice: 180000,
    createdAt: '2026-08-03T09:00:00+07:00',
    status: 'IN_PROGRESS',
    hasOpenReport: false,
    ...ghiDe,
  };
}

function dungKho(items: Array<Record<string, unknown>>) {
  const duongDan: string[] = [];
  server.use(
    http.get('*/admin/bookings/counts', () => HttpResponse.json(DEM_TAB)),
    http.get('*/admin/bookings', ({ request }) => {
      duongDan.push(new URL(request.url).search);
      return HttpResponse.json({ total: items.length, page: 1, limit: 10, items });
    }),
  );
  return duongDan;
}

function moMan() {
  renderVoiKhung(
    <MemoryRouter>
      <BookingsScreen />
    </MemoryRouter>,
  );
}

describe('Bảng đơn đặt lịch', () => {
  it('cả chín tab đều đọc được số đếm của máy chủ, không tab nào trống', async () => {
    dungKho([dong()]);
    moMan();
    await screen.findByText('Trần Minh Anh');

    const canDem: Array<[string, number]> = [
      ['Tất cả', DEM_TAB.all],
      ['Chờ trả tiền', DEM_TAB.awaitingPayment],
      ['Chờ nhận', DEM_TAB.pending],
      ['Đã nhận', DEM_TAB.confirmed],
      ['Đang chạy', DEM_TAB.running],
      ['Chờ xác nhận', DEM_TAB.awaitingConfirm],
      ['Hoàn thành', DEM_TAB.completed],
      ['Đã huỷ', DEM_TAB.cancelled],
      ['Khiếu nại', DEM_TAB.disputed],
    ];
    for (const [nhan, so] of canDem) {
      const nut = screen.getByRole('button', { name: new RegExp(`^${nhan}`) });
      expect(nut.textContent).toContain(String(so));
    }
  });

  it('gửi tên tab lên máy chủ chứ không gửi danh sách trạng thái', async () => {
    const duongDan = dungKho([dong()]);
    moMan();

    await screen.findByText('Trần Minh Anh');
    await userEvent.setup().click(screen.getByRole('button', { name: /Đang chạy/ }));

    await waitFor(() => expect(duongDan.length).toBeGreaterThan(1));
    const cuoi = duongDan[duongDan.length - 1];
    expect(cuoi).toContain('tab=running');
    expect(cuoi).not.toContain('status');
    expect(cuoi).not.toContain('openReport');
  });

  it('người chăm chưa có lượt đánh giá nào thì nói rõ, không hiện 0 sao', async () => {
    dungKho([dong({ sitterRating: 0, sitterName: 'Người chăm mới' })]);
    moMan();

    expect(await screen.findByText('chưa có đánh giá')).toBeInTheDocument();
    expect(screen.queryByText('0.0 sao')).not.toBeInTheDocument();
  });

  it('đơn trông giữ không có thời lượng cố định thì để trống chứ không bịa', async () => {
    dungKho([
      dong({
        serviceType: 'BOARDING',
        serviceName: 'Trông giữ',
        durationMinutes: null,
        scheduledEndAt: '2026-08-06T09:00:00+07:00',
      }),
    ]);
    moMan();

    expect(await screen.findByText('Trông giữ')).toBeInTheDocument();
    expect(screen.queryByText(/phút/)).not.toBeInTheDocument();
    expect(screen.queryByText(/giờ/)).not.toBeInTheDocument();
  });
});
