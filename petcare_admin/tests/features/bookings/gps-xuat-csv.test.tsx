import { http, HttpResponse } from 'msw';
import { afterEach, describe, expect, it, vi } from 'vitest';
import { screen, waitFor } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { MemoryRouter } from 'react-router-dom';
import { GpsFlaggedScreen } from '@/features/bookings/screens/gps-flagged-screen';
import { notify } from '@/lib/toast';
import { renderVoiKhung } from '@tests/support/render';
import { server } from '@tests/support/server';

const DEM_TAB = { flagged: 4, reviewed: 9, noClaim: 2, all: 15 };

function dong(trang: number, thuTu: number, ghiDe: Record<string, unknown> = {}) {
  return {
    bookingCode: `PC${trang}-${thuTu}`,
    sitterId: 'ncc-1',
    sitterName: 'Đặng Khắc Duy',
    suspicionScore: 0.42,
    flaggedForReview: true,
    suspicionNote: null,
    totalDistanceM: 3482,
    claimedDistanceKm: 5.1,
    totalWaypoints: 64,
    durationMinutes: 45,
    avgSpeedKmh: 4.6,
    mockedCount: 0,
    speedFlag: false,
    reviewedAt: null,
    createdAt: '2026-08-04T09:00:00+07:00',
    ...ghiDe,
  };
}

function dungKho(tongSo: number, ghiDe: Record<string, unknown> = {}) {
  const duongDan: string[] = [];
  server.use(
    http.get('*/admin/gps-reports/counts', () => HttpResponse.json(DEM_TAB)),
    http.get('*/admin/gps-reports', ({ request }) => {
      const url = new URL(request.url);
      duongDan.push(url.search);
      const page = Number(url.searchParams.get('page') ?? 1);
      const limit = Number(url.searchParams.get('limit') ?? 10);
      const soDong = Math.max(0, Math.min(limit, tongSo - (page - 1) * limit));
      return HttpResponse.json({
        total: tongSo,
        page,
        limit,
        items: Array.from({ length: soDong }, (_, i) => dong(page, i, ghiDe)),
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

function moMan() {
  renderVoiKhung(
    <MemoryRouter>
      <GpsFlaggedScreen />
    </MemoryRouter>,
  );
}

afterEach(() => {
  phucHoi.splice(0).forEach((ham) => ham());
  vi.restoreAllMocks();
});

describe('Xuất tệp đối soát của hàng chờ lộ trình', () => {
  it('lặp gọi chính lối danh sách với limit 50 và có ghi chú soát trong tệp', async () => {
    const duongDan = dungKho(60, {
      suspicionNote: 'Đã gọi hỏi người chăm, giữ cờ',
      reviewedAt: '2026-08-05T10:00:00+07:00',
    });
    let noiDung = '';
    chanTaiVe((text) => {
      noiDung = text;
    });
    moMan();

    await screen.findByText('PC1-0');
    await userEvent.setup().click(screen.getByRole('button', { name: 'Xuất tệp đối soát' }));

    await waitFor(() => expect(noiDung).toContain('GHI CHÚ SOÁT'));
    const luotXuat = duongDan.filter((item) => item.includes('limit=50'));
    expect(luotXuat.length).toBe(2);
    expect(luotXuat[1]).toContain('page=2');
    expect(noiDung).toContain('"PC2-0"');
    expect(noiDung).toContain('"Đã gọi hỏi người chăm, giữ cờ"');
  });

  it('đơn chưa khai số km để ô điểm trống chứ không lấp bằng 0', async () => {
    dungKho(1, { suspicionScore: null, claimedDistanceKm: null });
    let noiDung = '';
    chanTaiVe((text) => {
      noiDung = text;
    });
    moMan();

    await screen.findByText('PC1-0');
    await userEvent.setup().click(screen.getByRole('button', { name: 'Xuất tệp đối soát' }));

    await waitFor(() => expect(noiDung).toContain('PC1-0'));
    const dongDuLieu = noiDung.split('\r\n')[1];
    expect(dongDuLieu).toContain('"PC1-0","Đặng Khắc Duy","","3482",""');
  });

  it('vượt trần dòng thì không tải tệp mà bảo thu hẹp bộ lọc', async () => {
    dungKho(1500);
    const taoUrl = chanTaiVe();
    const bao = vi.spyOn(notify, 'info');
    moMan();

    await screen.findByText('PC1-0');
    await userEvent.setup().click(screen.getByRole('button', { name: 'Xuất tệp đối soát' }));

    await waitFor(() => expect(bao).toHaveBeenCalled());
    expect(bao.mock.calls[0][0]).toContain('thu hẹp bộ lọc');
    expect(taoUrl).not.toHaveBeenCalled();
  });

  it('không còn nút nào bấm vào chỉ báo tính năng đang làm dở', async () => {
    dungKho(1);
    const bao = vi.spyOn(notify, 'info');
    chanTaiVe();
    moMan();

    await screen.findByText('PC1-0');
    expect(screen.queryByRole('button', { name: /Xuất Excel/ })).toBeNull();
    expect(screen.queryByText(/đang được hoàn thiện/)).toBeNull();

    await userEvent.setup().click(screen.getByRole('button', { name: 'Xuất tệp đối soát' }));
    await waitFor(() => expect(bao).not.toHaveBeenCalled());
  });
});
