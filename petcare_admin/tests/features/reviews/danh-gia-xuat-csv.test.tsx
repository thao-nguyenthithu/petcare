import { http, HttpResponse } from 'msw';
import { afterEach, describe, expect, it, vi } from 'vitest';
import { screen, waitFor } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { ReviewsScreen } from '@/features/reviews/screens/reviews-screen';
import { notify } from '@/lib/toast';
import { renderVoiKhung } from '@tests/support/render';
import { server } from '@tests/support/server';

const DEM_TAB = { all: 60, lowRating: 4, hasPhotos: 12, noReply: 9 };

function danhGia(trang: number, thuTu: number, ghiDe: Record<string, unknown> = {}) {
  return {
    id: `r-${trang}-${thuTu}`,
    bookingCode: `PC${trang}-${thuTu}`,
    reviewerName: 'Đỗ Quỳnh Chi',
    reviewerAvatar: null,
    createdAt: '2026-08-01T02:00:00+07:00',
    sitterName: 'Trịnh Văn Nam',
    serviceType: 'WALKING',
    serviceName: 'Dắt đi dạo',
    durationMinutes: 60,
    rating: 5,
    comment: 'Bé về nhà rất vui',
    photos: [],
    reply: null,
    replyAt: null,
    replyDeadline: '2026-08-08T02:00:00+07:00',
    ...ghiDe,
  };
}

function dungKho(tongSo: number, ghiDe: Record<string, unknown> = {}) {
  const duongDan: string[] = [];
  server.use(
    http.get('*/admin/reviews/counts', () => HttpResponse.json(DEM_TAB)),
    http.get('*/admin/reviews', ({ request }) => {
      const url = new URL(request.url);
      duongDan.push(url.search);
      const page = Number(url.searchParams.get('page') ?? 1);
      const limit = Number(url.searchParams.get('limit') ?? 10);
      const soDong = Math.max(0, Math.min(limit, tongSo - (page - 1) * limit));
      return HttpResponse.json({
        total: tongSo,
        avgRating: 4.6,
        page,
        limit,
        items: Array.from({ length: soDong }, (_, i) => danhGia(page, i, ghiDe)),
      });
    }),
  );
  return duongDan;
}

const phucHoi: Array<() => void> = [];

// Không stub cả đối tượng URL: axios và msw còn cần new URL(), thay đúng hai hàm blob
function chanTaiVe(bat?: (noiDung: string) => void) {
  const goc = { tao: URL.createObjectURL, thu: URL.revokeObjectURL };
  phucHoi.push(() => {
    URL.createObjectURL = goc.tao;
    URL.revokeObjectURL = goc.thu;
  });
  const taoUrl = vi.fn((blob: Blob) => {
    if (bat) void blob.text().then(bat);
    return 'blob:test';
  });
  URL.createObjectURL = taoUrl as unknown as typeof URL.createObjectURL;
  URL.revokeObjectURL = vi.fn();
  vi.spyOn(HTMLAnchorElement.prototype, 'click').mockImplementation(() => {});
  return taoUrl;
}

afterEach(() => {
  phucHoi.splice(0).forEach((ham) => ham());
  vi.restoreAllMocks();
});

describe('Xuất tệp đối soát của danh sách đánh giá', () => {
  it('lặp gọi chính lối danh sách với limit 50 và đếm đúng số ảnh kèm', async () => {
    const duongDan = dungKho(60, { photos: ['a.jpg', 'b.jpg'], reply: 'Cảm ơn chị' });
    let noiDung = '';
    chanTaiVe((text) => {
      noiDung = text;
    });
    renderVoiKhung(<ReviewsScreen />);

    await screen.findByText('PC1-0');
    await userEvent.setup().click(screen.getByRole('button', { name: 'Xuất tệp đối soát' }));

    await waitFor(() => expect(noiDung).toContain('SỐ ẢNH'));
    const luotXuat = duongDan.filter((item) => item.includes('limit=50'));
    expect(luotXuat.length).toBe(2);
    expect(luotXuat[1]).toContain('page=2');
    expect(noiDung).toContain('"PC2-0"');
    expect(noiDung.split('\r\n')[1]).toContain('"2","Có"');
  });

  it('đánh giá chưa ai đáp để trống ô đáp lúc chứ không ghi 0', async () => {
    dungKho(1);
    let noiDung = '';
    chanTaiVe((text) => {
      noiDung = text;
    });
    renderVoiKhung(<ReviewsScreen />);

    await screen.findByText('PC1-0');
    await userEvent.setup().click(screen.getByRole('button', { name: 'Xuất tệp đối soát' }));

    await waitFor(() => expect(noiDung).toContain('PC1-0'));
    const dong = noiDung.split('\r\n')[1];
    expect(dong).toContain('"0","Không"');
    expect(dong.endsWith('""')).toBe(true);
  });

  it('vượt trần dòng thì không tải tệp mà bảo thu hẹp bộ lọc', async () => {
    dungKho(1500);
    const taoUrl = chanTaiVe();
    const bao = vi.spyOn(notify, 'info');
    renderVoiKhung(<ReviewsScreen />);

    await screen.findByText('PC1-0');
    await userEvent.setup().click(screen.getByRole('button', { name: 'Xuất tệp đối soát' }));

    await waitFor(() => expect(bao).toHaveBeenCalled());
    expect(bao.mock.calls[0][0]).toContain('thu hẹp bộ lọc');
    expect(taoUrl).not.toHaveBeenCalled();
  });

  it('không còn nút nào bấm vào chỉ báo tính năng đang làm dở', async () => {
    dungKho(1);
    chanTaiVe();
    renderVoiKhung(<ReviewsScreen />);

    await screen.findByText('PC1-0');
    expect(screen.queryByRole('button', { name: /Xuất Excel/i })).toBeNull();
    expect(screen.queryByText(/đang được hoàn thiện/i)).toBeNull();
  });
});
