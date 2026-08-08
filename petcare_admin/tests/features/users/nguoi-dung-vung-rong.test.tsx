import { http, HttpResponse } from 'msw';
import { describe, expect, it } from 'vitest';
import { screen } from '@testing-library/react';
import { MemoryRouter, Route, Routes } from 'react-router-dom';
import { UserDetailScreen } from '@/features/users/screens/user-detail-screen';
import { renderVoiKhung } from '@tests/support/render';
import { server } from '@tests/support/server';

function chiTiet(ghiDe: Record<string, unknown> = {}) {
  return {
    user: {
      id: 'u-1',
      fullName: 'Trần Thị Hoa',
      email: 'hoa@example.com',
      phone: '0901234567',
      role: 'OWNER',
      avatarUrl: null,
      isActive: true,
      isVerified: true,
      createdAt: '2026-05-01T02:00:00+07:00',
      defaultAddress: null,
    },
    stats: {
      bookingCount: 0,
      openBookingCount: 0,
      runningBookingCount: 0,
      totalSpent: 0,
      avgPerBooking: null,
      reviewCount: 0,
      avgRating: null,
      disputeCount: 0,
      resolvedDisputeCount: 0,
    },
    pets: [],
    addresses: [],
    recentBookings: [],
    activities: [],
    ...ghiDe,
  };
}

function moMan(du = chiTiet()) {
  server.use(http.get('*/admin/users/:id', () => HttpResponse.json(du)));
  return renderVoiKhung(
    <MemoryRouter initialEntries={['/users/u-1']}>
      <Routes>
        <Route path="/users/:id" element={<UserDetailScreen />} />
      </Routes>
    </MemoryRouter>,
  );
}

describe('Bốn trạng thái của mọi vùng dữ liệu, màn chi tiết người dùng', () => {
  it('chưa có bé và chưa có địa chỉ thì hai card nói rõ vì sao rỗng', async () => {
    moMan();

    expect(
      await screen.findByText('Người dùng này chưa lập hồ sơ thú cưng nào'),
    ).toBeInTheDocument();
    expect(screen.getByText('Người dùng này chưa lưu địa chỉ nào')).toBeInTheDocument();
  });

  it('bé đã có ảnh đại diện thì hiện ảnh đó chứ không dán cứng dấu chân', async () => {
    moMan(
      chiTiet({
        pets: [
          {
            id: 'pet-1',
            name: 'Mochi',
            species: 'DOG',
            breed: 'Corgi',
            ageLabel: '2 tuổi',
            avatarUrl: 'https://kho.example/mochi.jpg',
            isActive: true,
          },
        ],
      }),
    );

    const anh = await screen.findByAltText('Mochi');
    expect(anh).toHaveAttribute('src', 'https://kho.example/mochi.jpg');
  });
});
