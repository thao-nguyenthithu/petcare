import { http, HttpResponse } from 'msw';
import { describe, expect, it } from 'vitest';
import { screen } from '@testing-library/react';
import { MemoryRouter, Route, Routes } from 'react-router-dom';
import { BookingsScreen } from '@/features/bookings/screens/bookings-screen';
import { BookingDetailScreen } from '@/features/bookings/screens/booking-detail-screen';
import { renderVoiKhung } from '@tests/support/render';
import { server } from '@tests/support/server';

// Prisma khai totalPrice và scheduledEndAt nullable, đơn chưa chốt giá trả về null
function dongDon(ghiDe: Record<string, unknown> = {}) {
  return {
    code: 'PC9C4RN6',
    ownerName: 'Nguyễn Hải Yến',
    petNames: ['Miu'],
    sitterName: 'Trịnh Văn Nam',
    sitterRating: 4.8,
    serviceType: 'WALKING',
    serviceName: 'Dắt đi dạo',
    durationMinutes: 60,
    scheduledAt: '2026-08-10T02:00:00.000Z',
    scheduledEndAt: null,
    totalPrice: null,
    createdAt: '2026-08-07T02:00:00.000Z',
    status: 'AWAITING_PAYMENT',
    ...ghiDe,
  };
}

function chiTietDon(ghiDe: Record<string, unknown> = {}) {
  return {
    booking: {
      code: 'PC9C4RN6',
      status: 'AWAITING_PAYMENT',
      serviceType: 'WALKING',
      serviceName: 'Dắt đi dạo',
      durationMinutes: 60,
      scheduledAt: '2026-08-10T02:00:00.000Z',
      scheduledEndAt: null,
      addressText: null,
      totalPrice: null,
      platformFee: null,
      sitterPayout: null,
      createdAt: '2026-08-07T02:00:00.000Z',
      paidAt: null,
      acceptedAt: null,
      acceptDeadlineAt: null,
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
      ...ghiDe,
    },
    owner: { id: 'u1', fullName: 'Nguyễn Hải Yến', email: 'yen@example.com', avatarUrl: null },
    sitter: {
      id: 'ncc-1',
      userId: 'u9',
      fullName: 'Trịnh Văn Nam',
      email: 'nam@example.com',
      ratingAvg: 4.8,
      avatarUrl: null,
    },
    pets: [],
    payment: null,
    gpsReport: null,
    track: [],
    trackTruncated: false,
  };
}

describe('Đơn thiếu số liệu thì để trống', () => {
  it('bảng đơn không hiện 0 đ khi máy chủ trả totalPrice null', async () => {
    server.use(
      http.get('*/admin/bookings/counts', () =>
        HttpResponse.json({
          all: 1,
          awaitingPayment: 1,
          pending: 0,
          confirmed: 0,
          running: 0,
          awaitingConfirm: 0,
          completed: 0,
          cancelled: 0,
          disputed: 0,
        }),
      ),
      http.get('*/admin/bookings', () =>
        HttpResponse.json({ total: 1, page: 1, limit: 10, items: [dongDon()] }),
      ),
    );
    renderVoiKhung(
      <MemoryRouter>
        <BookingsScreen />
      </MemoryRouter>,
    );

    expect(await screen.findByText('PC9C4RN6')).toBeInTheDocument();
    expect(screen.queryByText('0 đ')).toBeNull();
    // new Date(null) đọc ra 01/01/1970 nên mốc kết thúc thiếu phải biến mất hẳn
    expect(screen.queryByText(/01\/01\/1970/)).toBeNull();
    expect(screen.queryByText(/07:00/)).toBeNull();
  });

  it('màn chi tiết không hiện 0 đ và không hiện hoa hồng 0%', async () => {
    server.use(http.get('*/admin/bookings/:code', () => HttpResponse.json(chiTietDon())));
    renderVoiKhung(
      <MemoryRouter initialEntries={['/bookings/PC9C4RN6']}>
        <Routes>
          <Route path="/bookings/:code" element={<BookingDetailScreen />} />
        </Routes>
      </MemoryRouter>,
    );

    expect(await screen.findByText('Nguyễn Hải Yến')).toBeInTheDocument();
    expect(screen.queryByText('0 đ')).toBeNull();
    expect(screen.queryByText(/\(0%\)/)).toBeNull();
  });

  it('báo trễ mà chưa biết số phút thì không nói trễ 0 phút', async () => {
    server.use(
      http.get('*/admin/bookings/:code', () =>
        HttpResponse.json(
          chiTietDon({
            status: 'IN_PROGRESS',
            lateReportedAt: '2026-08-10T02:30:00.000Z',
            lateMinutes: null,
          }),
        ),
      ),
    );
    renderVoiKhung(
      <MemoryRouter initialEntries={['/bookings/PC9C4RN6']}>
        <Routes>
          <Route path="/bookings/:code" element={<BookingDetailScreen />} />
        </Routes>
      </MemoryRouter>,
    );

    expect(await screen.findByText('Nguyễn Hải Yến')).toBeInTheDocument();
    expect(screen.queryByText(/trễ 0 phút/)).toBeNull();
  });
});
