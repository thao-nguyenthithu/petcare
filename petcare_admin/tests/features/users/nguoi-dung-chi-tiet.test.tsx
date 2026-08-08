import { http, HttpResponse } from 'msw';
import { describe, expect, it, vi } from 'vitest';
import { fireEvent, screen, waitFor, within } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { MemoryRouter, Route, Routes } from 'react-router-dom';
import { UserDetailScreen } from '@/features/users/screens/user-detail-screen';
import { notify } from '@/lib/toast';
import { renderVoiKhung } from '@tests/support/render';
import { server } from '@tests/support/server';

type GhiDe = {
  user?: Record<string, unknown>;
  stats?: Record<string, unknown>;
};

// Đủ đúng shape GET /admin/users/:id, thiếu một trường là màn ném lỗi lúc vẽ
function chiTiet(ghiDe: GhiDe = {}) {
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
      defaultAddress: 'Số 5 Trần Duy Hưng, Cầu Giấy, Hà Nội',
      ...ghiDe.user,
    },
    stats: {
      bookingCount: 4,
      openBookingCount: 1,
      runningBookingCount: 0,
      totalSpent: 1_200_000,
      avgPerBooking: 300_000,
      reviewCount: 2,
      avgRating: 4.5,
      disputeCount: 0,
      resolvedDisputeCount: 0,
      ...ghiDe.stats,
    },
    pets: [],
    addresses: [],
    recentBookings: [],
    activities: [],
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

describe('Gửi thông báo riêng cho một người dùng', () => {
  it('gửi đúng nhóm nhận một tài khoản kèm id người đó', async () => {
    const nguoiDung = userEvent.setup();
    const daGui: unknown[] = [];
    moMan();
    server.use(
      http.post('*/admin/notifications/broadcast', async ({ request }) => {
        daGui.push(await request.json());
        return HttpResponse.json({ id: 'luot-1', queued: 1, scheduledAt: null });
      }),
    );

    await screen.findByText('hoa@example.com');
    await nguoiDung.click(screen.getByRole('button', { name: 'Gửi thông báo' }));

    const hop = await screen.findByRole('dialog');
    fireEvent.change(within(hop).getByPlaceholderText(/Ví dụ/), {
      target: { value: 'Nhắc cập nhật số điện thoại' },
    });
    fireEvent.change(within(hop).getByPlaceholderText(/Viết bằng lời/), {
      target: { value: 'Số điện thoại của bạn đã cũ, vào mục Tài khoản để sửa lại.' },
    });
    await nguoiDung.click(within(hop).getByRole('button', { name: 'Gửi thông báo' }));

    await waitFor(() => expect(daGui).toHaveLength(1));
    expect(daGui[0]).toEqual({
      title: 'Nhắc cập nhật số điện thoại',
      body: 'Số điện thoại của bạn đã cũ, vào mục Tài khoản để sửa lại.',
      audienceKind: 'SINGLE_USER',
      audienceValue: 'u-1',
      urgent: false,
    });
  });

  it('tiêu đề hoặc nội dung quá ngắn thì chưa cho gửi', async () => {
    const nguoiDung = userEvent.setup();
    moMan();

    await screen.findByText('hoa@example.com');
    await nguoiDung.click(screen.getByRole('button', { name: 'Gửi thông báo' }));

    const hop = await screen.findByRole('dialog');
    expect(within(hop).getByRole('button', { name: 'Gửi thông báo' })).toBeDisabled();
    fireEvent.change(within(hop).getByPlaceholderText(/Ví dụ/), {
      target: { value: 'Nhắc cập nhật số điện thoại' },
    });
    // Có tiêu đề mà nội dung còn trống thì máy chủ vẫn trả 400, khoá nút từ đây
    expect(within(hop).getByRole('button', { name: 'Gửi thông báo' })).toBeDisabled();
  });

  it('tài khoản đã khoá thì khoá luôn nút vì máy chủ không gửi cho họ', async () => {
    moMan(chiTiet({ user: { isActive: false } }));

    await screen.findByText('hoa@example.com');
    expect(screen.getByRole('button', { name: 'Gửi thông báo' })).toBeDisabled();
  });
});

describe('Chỉ số của người dùng không lấp bằng 0', () => {
  it('chưa có đánh giá và chưa có đơn trả tiền thì bỏ trống dòng phụ', async () => {
    const { container } = moMan(
      chiTiet({
        stats: { reviewCount: 0, avgRating: null, totalSpent: 0, avgPerBooking: null },
      }),
    );

    await screen.findByText('hoa@example.com');
    expect(container.textContent).not.toContain('điểm trung bình');
    expect(container.textContent).not.toContain('trung bình');
  });

  it('có dữ liệu thì vẫn hiện đủ hai dòng phụ', async () => {
    moMan();

    expect(await screen.findByText('điểm trung bình 4.5')).toBeInTheDocument();
    expect(screen.getByText('trung bình 300.000 đ mỗi đơn')).toBeInTheDocument();
  });
});

describe('Màn chi tiết người dùng không còn nút chết', () => {
  it('bỏ hẳn nút đặt lại mật khẩu, hai nút còn lại đều mở hộp thoại thật', async () => {
    const nguoiDung = userEvent.setup();
    const tin = vi.spyOn(notify, 'info');
    moMan();

    await screen.findByText('hoa@example.com');
    expect(
      screen.queryByRole('button', { name: /đặt lại mật khẩu/i }),
    ).not.toBeInTheDocument();

    for (const nhan of ['Gửi thông báo', 'Khoá tài khoản']) {
      await nguoiDung.click(screen.getByRole('button', { name: nhan }));
      expect(await screen.findByRole('dialog')).toBeInTheDocument();
      await nguoiDung.keyboard('{Escape}');
      await waitFor(() => expect(screen.queryByRole('dialog')).toBeNull());
    }
    expect(tin).not.toHaveBeenCalled();
    tin.mockRestore();
  });
});
