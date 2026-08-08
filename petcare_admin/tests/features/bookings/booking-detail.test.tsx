import { http, HttpResponse } from 'msw';
import { describe, expect, it } from 'vitest';
import { fireEvent, screen, waitFor } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { MemoryRouter, Route, Routes } from 'react-router-dom';
import { BookingDetailScreen } from '@/features/bookings/screens/booking-detail-screen';
import { renderVoiKhung } from '@tests/support/render';
import { server } from '@tests/support/server';

function chiTiet(don: Record<string, unknown> = {}, ghiDe: Record<string, unknown> = {}) {
  return {
    booking: {
      code: 'PC6Q5MT3',
      status: 'CONFIRMED',
      serviceType: 'WALKING',
      serviceName: 'Dắt đi dạo',
      durationMinutes: 60,
      scheduledAt: '2026-08-04T09:00:00+07:00',
      scheduledEndAt: '2026-08-04T10:00:00+07:00',
      addressText: '12 Lê Lợi, Quận 1',
      addressLat: 10.77,
      addressLng: 106.7,
      totalPrice: 180000,
      platformFee: 27000,
      sitterPayout: 153000,
      cancellationFee: null,
      cancellationReason: null,
      cancellationNote: null,
      cancelledAt: null,
      createdAt: '2026-08-03T09:00:00+07:00',
      paidAt: '2026-08-03T09:05:00+07:00',
      acceptedAt: '2026-08-03T09:30:00+07:00',
      acceptDeadlineAt: '2026-08-03T21:05:00+07:00',
      departedAt: null,
      ownerDepartedAt: null,
      arrivedAt: null,
      arriveDistanceM: null,
      startedAt: null,
      endedAt: null,
      completedAt: null,
      escrowReleaseAt: null,
      lateMinutes: null,
      etaAt: null,
      lateReportedAt: null,
      gearReportedAt: null,
      ownerArrivedAt: null,
      distanceKm: null,
      pickupDistanceKm: null,
      noShowProofUrls: [],
      ...don,
    },
    owner: {
      id: 'user-1',
      fullName: 'Trần Minh Anh',
      email: 'anh@example.com',
      avatarUrl: null,
    },
    sitter: {
      id: 'sitter-1',
      userId: 'user-9',
      fullName: 'Đặng Khắc Duy',
      email: 'duy@example.com',
      ratingAvg: 4.9,
      avatarUrl: null,
    },
    pets: [
      {
        id: 'pet-1',
        name: 'Mochi',
        breed: 'Corgi',
        birthDate: null,
        weightKg: 9.5,
        packageCode: null,
        durationMinutes: 60,
        price: 180000,
      },
    ],
    payment: {
      status: 'HELD',
      txnRef: 'TXN-001',
      gatewayTxnNo: null,
      bankCode: null,
      cardType: null,
      paidAt: '2026-08-03T09:05:00+07:00',
      releasedAt: null,
      expiresAt: null,
    },
    gpsReport: null,
    track: [],
    trackTruncated: false,
    ...ghiDe,
  };
}

function dungKho(du: ReturnType<typeof chiTiet>) {
  const thanGui: unknown[] = [];
  server.use(
    http.get('*/admin/bookings/:code', () => HttpResponse.json(du)),
    http.post('*/admin/bookings/:code/cancel', async ({ request }) => {
      thanGui.push(await request.json());
      return HttpResponse.json({ code: 'PC6Q5MT3', status: 'CANCELLED_BY_ADMIN' });
    }),
  );
  return thanGui;
}

function moMan() {
  renderVoiKhung(
    <MemoryRouter initialEntries={['/bookings/PC6Q5MT3']}>
      <Routes>
        <Route path="/bookings/:code" element={<BookingDetailScreen />} />
      </Routes>
    </MemoryRouter>,
  );
}

describe('Chi tiết một đơn', () => {
  it('đơn đang chạy thì khoá nút can thiệp huỷ vì máy chủ cũng chặn', async () => {
    dungKho(chiTiet({ status: 'IN_PROGRESS', startedAt: '2026-08-04T09:05:00+07:00' }));
    moMan();

    await screen.findByText('Trần Minh Anh');
    expect(screen.getByRole('button', { name: 'Can thiệp huỷ đơn' })).toBeDisabled();
  });

  it('đơn chưa chạy thì mở nút và gửi lý do lên máy chủ', async () => {
    const thanGui = dungKho(chiTiet());
    const nguoiDung = userEvent.setup();
    moMan();

    await screen.findByText('Trần Minh Anh');
    await nguoiDung.click(screen.getByRole('button', { name: 'Can thiệp huỷ đơn' }));

    const nutXacNhan = screen.getByRole('button', { name: 'Huỷ đơn này' });
    expect(nutXacNhan).toBeDisabled();

    fireEvent.change(screen.getByRole('textbox'), {
      target: { value: 'Người chăm bị khoá tài khoản' },
    });
    await waitFor(() => expect(nutXacNhan).toBeEnabled());
    await nguoiDung.click(nutXacNhan);

    await waitFor(() =>
      expect(thanGui).toEqual([{ reason: 'Người chăm bị khoá tài khoản' }]),
    );
  });

  it('mốc nhả tiền lấy từ cột của đơn, không cộng tay từ lúc trả tiền', async () => {
    dungKho(
      chiTiet({
        status: 'AWAITING_OWNER_CONFIRM',
        endedAt: '2026-08-04T10:00:00+07:00',
        escrowReleaseAt: '2026-08-07T03:00:00+07:00',
      }),
    );
    moMan();

    expect(await screen.findByText(/dự kiến chuyển vào ví 07\/08\/2026/)).toBeInTheDocument();
    // 48 giờ sau mốc trả tiền là 05/08, hiện số đó nghĩa là màn đang tự tính lại
    expect(screen.queryByText(/05\/08\/2026/)).not.toBeInTheDocument();
  });

  it('đơn trông giữ không có lộ trình thì khoá nút tải log', async () => {
    dungKho(
      chiTiet({ serviceType: 'BOARDING', serviceName: 'Trông giữ', durationMinutes: null }),
    );
    moMan();

    await screen.findByText('Trần Minh Anh');
    expect(screen.getByRole('button', { name: 'Tải log GPS' })).toBeDisabled();
  });
});
