import { http, HttpResponse } from 'msw';
import { describe, expect, it } from 'vitest';
import { screen } from '@testing-library/react';
import { MemoryRouter, Route, Routes } from 'react-router-dom';
import { BookingConversationScreen } from '@/features/bookings/screens/booking-conversation-screen';
import { BookingDetailScreen } from '@/features/bookings/screens/booking-detail-screen';
import { renderVoiKhung } from '@tests/support/render';
import { server } from '@tests/support/server';

function chiTiet(don: Record<string, unknown> = {}) {
  return {
    booking: {
      code: 'PC6Q5MT3',
      status: 'CANCELLED_BY_OWNER',
      serviceType: 'WALKING',
      serviceName: 'Dắt đi dạo',
      durationMinutes: 60,
      scheduledAt: '2026-08-04T09:00:00+07:00',
      scheduledEndAt: '2026-08-04T10:00:00+07:00',
      addressText: '12 Lê Lợi, Quận 1',
      totalPrice: 180000,
      platformFee: 27000,
      sitterPayout: 153000,
      cancellationFee: null,
      createdAt: '2026-08-03T09:00:00+07:00',
      paidAt: '2026-08-03T09:05:00+07:00',
      acceptedAt: '2026-08-03T09:30:00+07:00',
      acceptDeadlineAt: '2026-08-03T21:05:00+07:00',
      departedAt: null,
      arrivedAt: null,
      arriveDistanceM: null,
      startedAt: null,
      endedAt: null,
      completedAt: null,
      escrowReleaseAt: null,
      lateMinutes: null,
      lateReportedAt: null,
      gearReportedAt: null,
      ownerArrivedAt: null,
      distanceKm: null,
      noShowProofUrls: [],
      ...don,
    },
    owner: { id: 'user-1', fullName: 'Trần Minh Anh', email: 'anh@example.com', avatarUrl: null },
    sitter: {
      id: 'sitter-1',
      userId: 'user-9',
      fullName: 'Đặng Khắc Duy',
      email: 'duy@example.com',
      ratingAvg: 4.9,
      avatarUrl: null,
    },
    pets: [],
    payment: null,
    gpsReport: null,
    track: [],
    trackTruncated: false,
  };
}

function moManDon(du: ReturnType<typeof chiTiet>) {
  server.use(http.get('*/admin/bookings/:code', () => HttpResponse.json(du)));
  renderVoiKhung(
    <MemoryRouter initialEntries={['/bookings/PC6Q5MT3']}>
      <Routes>
        <Route path="/bookings/:code" element={<BookingDetailScreen />} />
      </Routes>
    </MemoryRouter>,
  );
}

describe('Phí huỷ đơn ở card thông tin', () => {
  it('đơn có phí huỷ thì hiện đúng số máy chủ trả', async () => {
    moManDon(chiTiet({ cancellationFee: 90000 }));

    expect(await screen.findByText('Phí huỷ đơn')).toBeInTheDocument();
    expect(screen.getByText('90.000 đ')).toBeInTheDocument();
  });

  it('đơn không có phí huỷ thì bỏ hẳn dòng, không ghi 0 đ', async () => {
    moManDon(chiTiet());

    await screen.findByText('Trần Minh Anh');
    expect(screen.queryByText('Phí huỷ đơn')).not.toBeInTheDocument();
  });
});

describe('Mốc mở hội thoại của đơn', () => {
  it('hiện mốc mở để neo dòng thời gian bên dưới', async () => {
    server.use(
      http.get('*/admin/bookings/:code/conversation', () =>
        HttpResponse.json({
          code: 'PC6Q5MT3',
          ownerName: 'Trần Minh Anh',
          sitterName: 'Đặng Khắc Duy',
          openedAt: '2026-08-04T08:00:00+07:00',
          closedAt: null,
          entries: [],
          truncated: false,
        }),
      ),
    );
    renderVoiKhung(
      <MemoryRouter initialEntries={['/bookings/PC6Q5MT3/conversation']}>
        <Routes>
          <Route path="/bookings/:code/conversation" element={<BookingConversationScreen />} />
        </Routes>
      </MemoryRouter>,
    );

    expect(await screen.findByText(/Mở lúc 04\/08\/2026/)).toBeInTheDocument();
  });
});
