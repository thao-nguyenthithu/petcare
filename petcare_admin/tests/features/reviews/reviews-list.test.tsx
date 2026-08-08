import { http, HttpResponse } from 'msw';
import { describe, expect, it } from 'vitest';
import { screen, waitFor } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { ReviewsScreen } from '@/features/reviews/screens/reviews-screen';
import { renderVoiKhung } from '@tests/support/render';
import { server } from '@tests/support/server';

const DEM_TAB = { all: 40, lowRating: 4, hasPhotos: 12, noReply: 7 };

function danhGia(ghiDe: Record<string, unknown> = {}) {
  return {
    id: 'dg-1',
    bookingCode: 'PC6Q5MT3',
    reviewerName: 'Trần Minh Anh',
    reviewerAvatar: null,
    createdAt: '2026-08-05T03:00:00+07:00',
    sitterName: 'Đặng Khắc Duy',
    serviceType: 'WALKING',
    serviceName: 'Dắt đi dạo',
    durationMinutes: 60,
    rating: 5,
    comment: 'Bé về sạch sẽ, người chăm nhắn tin đều',
    photos: [],
    reply: null,
    replyAt: null,
    replyDeadline: '2026-08-12T03:00:00+07:00',
    ...ghiDe,
  };
}

function dungKho(items: Array<Record<string, unknown>>, avgRating = 4.6) {
  const duongDan: string[] = [];
  server.use(
    http.get('*/admin/reviews/counts', () => HttpResponse.json(DEM_TAB)),
    http.get('*/admin/reviews', ({ request }) => {
      duongDan.push(new URL(request.url).search);
      return HttpResponse.json({
        total: items.length,
        avgRating,
        page: 1,
        limit: 10,
        items,
      });
    }),
  );
  return duongDan;
}

function moMan() {
  renderVoiKhung(<ReviewsScreen />);
}

describe('Quản lý đánh giá', () => {
  it('tab 1-2 sao gửi khoảng lên máy chủ, không cắt thêm ở màn', async () => {
    const duongDan = dungKho([danhGia({ rating: 5 })]);
    moMan();

    await screen.findByText('Trần Minh Anh');
    await userEvent.setup().click(screen.getByRole('button', { name: /1-2 sao/ }));

    await waitFor(() => expect(duongDan.length).toBeGreaterThan(1));
    expect(duongDan[duongDan.length - 1]).toContain('ratingTo=2');
  });

  it('màn chỉ đọc: không có nút ẩn hay gỡ đánh giá nào', async () => {
    dungKho([danhGia()]);
    moMan();

    await screen.findByText('Trần Minh Anh');
    expect(screen.queryByRole('button', { name: /ẩn/i })).toBeNull();
    expect(screen.queryByRole('button', { name: /gỡ/i })).toBeNull();
    expect(screen.getByRole('button', { name: 'Xem đánh giá' })).toBeInTheDocument();
  });

  it('điểm trung bình đọc từ chính bảng đánh giá đang lọc', async () => {
    dungKho([danhGia()], 4.6);
    moMan();

    expect(await screen.findByText(/Điểm trung bình của 1 đánh giá/)).toBeInTheDocument();
    expect(screen.getByText(/4,6 trên 5/)).toBeInTheDocument();
  });

  it('đơn trông giữ không có thời lượng cố định thì để trống', async () => {
    dungKho([
      danhGia({
        serviceType: 'BOARDING',
        serviceName: 'Trông giữ',
        durationMinutes: null,
      }),
    ]);
    moMan();

    expect(await screen.findByText('Trông giữ')).toBeInTheDocument();
    expect(screen.queryByText(/^\d+ phút$/)).toBeNull();
  });
});
