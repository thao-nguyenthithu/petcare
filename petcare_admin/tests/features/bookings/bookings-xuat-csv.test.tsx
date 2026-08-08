import { http, HttpResponse } from 'msw';
import { afterEach, describe, expect, it, vi } from 'vitest';
import { screen, waitFor } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { MemoryRouter } from 'react-router-dom';
import { BookingsScreen } from '@/features/bookings/screens/bookings-screen';
import { notify } from '@/lib/toast';
import { renderVoiKhung } from '@tests/support/render';
import { server } from '@tests/support/server';

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

function dong(trang: number, thuTu: number) {
  return {
    code: `PC${trang}-${thuTu}`,
    ownerName: 'Trần Minh Anh',
    petNames: ['Mochi'],
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
  };
}

// Máy chủ cắt trang thật để đo được vòng lặp, không trả một trang cố định
function dungKho(tongSo: number) {
  const duongDan: string[] = [];
  server.use(
    http.get('*/admin/bookings/counts', () => HttpResponse.json(DEM_TAB)),
    http.get('*/admin/bookings', ({ request }) => {
      const url = new URL(request.url);
      duongDan.push(url.search);
      const page = Number(url.searchParams.get('page') ?? 1);
      const limit = Number(url.searchParams.get('limit') ?? 10);
      const soDong = Math.max(0, Math.min(limit, tongSo - (page - 1) * limit));
      return HttpResponse.json({
        total: tongSo,
        page,
        limit,
        items: Array.from({ length: soDong }, (_, i) => dong(page, i)),
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
      <BookingsScreen />
    </MemoryRouter>,
  );
}

afterEach(() => {
  phucHoi.splice(0).forEach((ham) => ham());
  vi.restoreAllMocks();
});

describe('Xuất tệp đối soát của bảng đơn', () => {
  it('lặp gọi chính lối danh sách với limit 50 cho tới hết', async () => {
    const duongDan = dungKho(60);
    let noiDung = '';
    chanTaiVe((text) => {
      noiDung = text;
    });
    moMan();

    await screen.findByText('PC1-0');
    await userEvent.setup().click(screen.getByRole('button', { name: 'Xuất tệp đối soát' }));

    await waitFor(() => expect(noiDung).toContain('MÃ ĐƠN'));
    const luotXuat = duongDan.filter((item) => item.includes('limit=50'));
    expect(luotXuat.length).toBe(2);
    expect(luotXuat[1]).toContain('page=2');
    // Trang hai phải nằm trong tệp, cắt ở trang một là thiếu dữ liệu mà không ai biết
    expect(noiDung).toContain('"PC2-0"');
    expect(noiDung).toContain('"180000"');
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
