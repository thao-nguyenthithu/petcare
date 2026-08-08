import { http, HttpResponse } from 'msw';
import { afterEach, describe, expect, it, vi } from 'vitest';
import { screen, waitFor } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { MemoryRouter } from 'react-router-dom';
import { UsersScreen } from '@/features/users/screens/users-screen';
import { notify } from '@/lib/toast';
import { renderVoiKhung } from '@tests/support/render';
import { server } from '@tests/support/server';

const DEM_TAB = { all: 40, owners: 30, sitters: 8, locked: 2 };

function nguoiDung(trang: number, thuTu: number, ghiDe: Record<string, unknown> = {}) {
  return {
    id: `u-${trang}-${thuTu}`,
    fullName: `Lê Thu Hà ${trang}-${thuTu}`,
    email: `ha${trang}${thuTu}@petcare.vn`,
    phone: '0901234567',
    role: 'OWNER',
    avatarUrl: null,
    isActive: true,
    isVerified: true,
    createdAt: '2026-07-01T02:00:00+07:00',
    petCount: 2,
    bookingCount: 5,
    province: 'Hà Nội',
    ...ghiDe,
  };
}

function dungKho(tongSo: number, ghiDe: Record<string, unknown> = {}) {
  const duongDan: string[] = [];
  server.use(
    http.get('*/admin/users/counts', () => HttpResponse.json(DEM_TAB)),
    http.get('*/admin/provinces', () => HttpResponse.json(['Hà Nội'])),
    http.get('*/admin/users', ({ request }) => {
      const url = new URL(request.url);
      duongDan.push(url.search);
      const page = Number(url.searchParams.get('page') ?? 1);
      const limit = Number(url.searchParams.get('limit') ?? 8);
      const soDong = Math.max(0, Math.min(limit, tongSo - (page - 1) * limit));
      return HttpResponse.json({
        total: tongSo,
        page,
        limit,
        items: Array.from({ length: soDong }, (_, i) => nguoiDung(page, i, ghiDe)),
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
      <UsersScreen />
    </MemoryRouter>,
  );
}

afterEach(() => {
  phucHoi.splice(0).forEach((ham) => ham());
  vi.restoreAllMocks();
});

describe('Xuất tệp đối soát của danh sách người dùng', () => {
  it('lặp gọi chính lối danh sách với limit 50 và giữ nguyên bộ lọc đang chọn', async () => {
    const duongDan = dungKho(60);
    let noiDung = '';
    chanTaiVe((text) => {
      noiDung = text;
    });
    moMan();

    await screen.findByText('Lê Thu Hà 1-0');
    await userEvent.setup().click(screen.getByRole('button', { name: 'Xuất tệp đối soát' }));

    await waitFor(() => expect(noiDung).toContain('SỐ THÚ CƯNG'));
    const luotXuat = duongDan.filter((item) => item.includes('limit=50'));
    expect(luotXuat.length).toBe(2);
    expect(luotXuat[1]).toContain('page=2');
    expect(noiDung).toContain('"Lê Thu Hà 2-0"');
  });

  it('tài khoản chưa khai số điện thoại để trống ô đó chứ không bịa', async () => {
    dungKho(1, { phone: null, province: null, isVerified: false });
    let noiDung = '';
    chanTaiVe((text) => {
      noiDung = text;
    });
    moMan();

    await screen.findByText('Lê Thu Hà 1-0');
    await userEvent.setup().click(screen.getByRole('button', { name: 'Xuất tệp đối soát' }));

    await waitFor(() => expect(noiDung).toContain('Lê Thu Hà 1-0'));
    const dong = noiDung.split('\r\n')[1];
    expect(dong).toContain('"","OWNER",""');
    expect(dong).toContain('"Không"');
  });

  it('vượt trần dòng thì không tải tệp mà bảo thu hẹp bộ lọc', async () => {
    dungKho(1500);
    const taoUrl = chanTaiVe();
    const bao = vi.spyOn(notify, 'info');
    moMan();

    await screen.findByText('Lê Thu Hà 1-0');
    await userEvent.setup().click(screen.getByRole('button', { name: 'Xuất tệp đối soát' }));

    await waitFor(() => expect(bao).toHaveBeenCalled());
    expect(bao.mock.calls[0][0]).toContain('thu hẹp bộ lọc');
    expect(taoUrl).not.toHaveBeenCalled();
  });

  it('không còn nút nào bấm vào chỉ báo tính năng đang làm dở', async () => {
    dungKho(1);
    chanTaiVe();
    moMan();

    await screen.findByText('Lê Thu Hà 1-0');
    expect(screen.queryByRole('button', { name: /Xuất Excel/i })).toBeNull();
    expect(screen.queryByText(/đang được hoàn thiện/i)).toBeNull();
  });
});
