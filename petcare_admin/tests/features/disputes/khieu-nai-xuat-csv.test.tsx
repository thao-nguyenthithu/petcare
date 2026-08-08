import { http, HttpResponse } from 'msw';
import { afterEach, describe, expect, it, vi } from 'vitest';
import { screen, waitFor } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { MemoryRouter } from 'react-router-dom';
import { DisputesScreen } from '@/features/disputes/screens/disputes-screen';
import { notify } from '@/lib/toast';
import { renderVoiKhung } from '@tests/support/render';
import { server } from '@tests/support/server';

const DEM_TAB = { waitingSitter: 3, waitingSupport: 5, resolved: 12 };

function hoSo(trang: number, thuTu: number, ghiDe: Record<string, unknown> = {}) {
  return {
    code: `KN-PC${trang}-${thuTu}`,
    bookingCode: `PC${trang}-${thuTu}`,
    serviceType: 'WALKING',
    serviceName: 'Dắt đi dạo',
    reporterName: 'Nguyễn Hải Yến',
    reporterRole: 'OWNER',
    reporterAvatarUrl: null,
    sitterName: 'Trịnh Văn Nam',
    description: 'Người chăm tới muộn 40 phút',
    createdAt: '2026-08-06T02:00:00+07:00',
    replyDeadline: '2026-08-07T02:00:00+07:00',
    sitterReplyAt: null,
    status: 'OPEN',
    refundAmount: null,
    ...ghiDe,
  };
}

function dungKho(tongSo: number, ghiDe: Record<string, unknown> = {}) {
  const duongDan: string[] = [];
  server.use(
    http.get('*/admin/disputes/counts', () => HttpResponse.json(DEM_TAB)),
    http.get('*/admin/disputes', ({ request }) => {
      const url = new URL(request.url);
      duongDan.push(url.search);
      const page = Number(url.searchParams.get('page') ?? 1);
      const limit = Number(url.searchParams.get('limit') ?? 10);
      const soDong = Math.max(0, Math.min(limit, tongSo - (page - 1) * limit));
      return HttpResponse.json({
        total: tongSo,
        page,
        limit,
        items: Array.from({ length: soDong }, (_, i) => hoSo(page, i, ghiDe)),
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
      <DisputesScreen />
    </MemoryRouter>,
  );
}

afterEach(() => {
  phucHoi.splice(0).forEach((ham) => ham());
  vi.restoreAllMocks();
});

describe('Xuất tệp đối soát của danh sách khiếu nại', () => {
  it('lặp gọi chính lối danh sách với limit 50 và giữ nguyên bộ lọc đang chọn', async () => {
    const duongDan = dungKho(60, { refundAmount: 90000, status: 'RESOLVED' });
    let noiDung = '';
    chanTaiVe((text) => {
      noiDung = text;
    });
    moMan();

    await screen.findByText('KN-PC1-0');
    await userEvent.setup().click(screen.getByRole('button', { name: 'Xuất tệp đối soát' }));

    await waitFor(() => expect(noiDung).toContain('TIỀN HOÀN'));
    const luotXuat = duongDan.filter((item) => item.includes('limit=50'));
    expect(luotXuat.length).toBe(2);
    expect(luotXuat[1]).toContain('page=2');
    expect(luotXuat[0]).toContain('tab=waitingSitter');
    expect(noiDung).toContain('"KN-PC2-0"');
    expect(noiDung).toContain('"90000"');
  });

  it('hồ sơ chưa kết luận để trống ô tiền hoàn chứ không ghi 0', async () => {
    dungKho(1);
    let noiDung = '';
    chanTaiVe((text) => {
      noiDung = text;
    });
    moMan();

    await screen.findByText('KN-PC1-0');
    await userEvent.setup().click(screen.getByRole('button', { name: 'Xuất tệp đối soát' }));

    await waitFor(() => expect(noiDung).toContain('KN-PC1-0'));
    expect(noiDung.split('\r\n')[1]).toContain('"OPEN",""');
  });

  it('vượt trần dòng thì không tải tệp mà bảo thu hẹp bộ lọc', async () => {
    dungKho(1500);
    const taoUrl = chanTaiVe();
    const bao = vi.spyOn(notify, 'info');
    moMan();

    await screen.findByText('KN-PC1-0');
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

    await screen.findByText('KN-PC1-0');
    expect(screen.queryByRole('button', { name: /Xuất Excel/ })).toBeNull();
    expect(screen.queryByText(/đang được hoàn thiện/)).toBeNull();

    await userEvent.setup().click(screen.getByRole('button', { name: 'Xuất tệp đối soát' }));
    await waitFor(() => expect(bao).not.toHaveBeenCalled());
  });
});
