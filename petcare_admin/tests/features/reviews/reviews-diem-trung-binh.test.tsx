import { http, HttpResponse } from 'msw';
import { describe, expect, it } from 'vitest';
import { screen } from '@testing-library/react';
import { MemoryRouter } from 'react-router-dom';
import { ReviewsScreen } from '@/features/reviews/screens/reviews-screen';
import { renderVoiKhung } from '@tests/support/render';
import { server } from '@tests/support/server';

// Prisma _avg.rating là null khi tập lọc rỗng và máy chủ trả nguyên null, không lấp 0
function dungKho(total: number, avgRating: number | null, items: unknown[] = []) {
  server.use(
    http.get('*/admin/reviews/counts', () =>
      HttpResponse.json({ all: total, lowRating: 0, hasPhotos: 0, noReply: 0 }),
    ),
    http.get('*/admin/reviews', () =>
      HttpResponse.json({ total, avgRating, page: 1, limit: 8, items }),
    ),
  );
}

function dongDanhGia() {
  return {
    id: 'dg-1',
    bookingCode: 'PC9C4RN6',
    reviewerName: 'Nguyễn Hải Yến',
    reviewerAvatar: null,
    createdAt: '2026-08-05T02:00:00.000Z',
    sitterName: 'Trịnh Văn Nam',
    serviceType: 'WALKING',
    serviceName: 'Dắt đi dạo',
    durationMinutes: 60,
    rating: 5,
    comment: 'Rất chu đáo',
    photos: [],
    reply: null,
    replyAt: null,
    replyDeadline: '2026-08-12T02:00:00.000Z',
  };
}

function moMan() {
  renderVoiKhung(
    <MemoryRouter>
      <ReviewsScreen />
    </MemoryRouter>,
  );
}

describe('Điểm trung bình đánh giá', () => {
  it('chưa có đánh giá nào thì máy chủ trả rỗng, màn không nói điểm 0 trên 5', async () => {
    dungKho(0, null);
    moMan();

    expect(await screen.findByText(/Mỗi đánh giá gồm số sao/)).toBeInTheDocument();
    expect(screen.queryByText(/0,0 trên 5/)).toBeNull();
    expect(screen.queryByText(/Điểm trung bình của/)).toBeNull();
  });

  it('điểm rỗng mà tổng khác 0 vẫn không bịa ra số, phòng khi bộ lọc lệch', async () => {
    dungKho(3, null, [dongDanhGia()]);
    moMan();

    expect(await screen.findByText('PC9C4RN6')).toBeInTheDocument();
    expect(screen.queryByText(/trên 5/)).toBeNull();
  });

  it('có đánh giá thì vẫn nói đủ điểm trung bình', async () => {
    dungKho(1, 5, [dongDanhGia()]);
    moMan();

    expect(await screen.findByText(/5,0 trên 5/)).toBeInTheDocument();
  });
});
