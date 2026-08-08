import { http, HttpResponse } from 'msw';
import { describe, expect, it } from 'vitest';
import { screen, waitFor } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { MemoryRouter } from 'react-router-dom';
import i18n from '@/core/i18n';
import { EvidenceScreen } from '@/features/evidence/screens/evidence-screen';
import { renderVoiKhung } from '@tests/support/render';
import { server } from '@tests/support/server';

const DEM_NGUON = { session: 12, boarding: 30, noShow: 4, gpsFlagged: 7 };

// Nhãn của mọi nút chỉ hiện toast "chưa có" trước đây, không được mọc lại
const NUT_CHET = /Gắn cờ bằng chứng|Đính vào khiếu nại|Tải xuống lô ảnh|Chọn nhiều|Tải toàn bộ/;

function anh(ghiDe: Record<string, unknown> = {}) {
  return {
    id: 'sp-1',
    source: 'session',
    bookingCode: 'PC3H7WK5',
    serviceType: 'WALKING',
    serviceName: 'Dắt đi dạo',
    url: 'https://kho/anh-1.jpg',
    phase: 'CHECK_IN',
    takenAt: '2026-08-04T09:01:00+07:00',
    photoLat: 21.0245,
    photoLng: 105.8032,
    conditions: [],
    anhDoDung: false,
    anhVanXa: false,
    aiConfidenceScore: null,
    aiPassed: null,
    reportKind: null,
    ...ghiDe,
  };
}

// Ghi lại tham số từng lượt hỏi để soi đúng thứ màn gửi lên
function dungKho(items: Array<Record<string, unknown>>) {
  const duongDan: string[] = [];
  server.use(
    http.get('*/admin/evidence/counts', () => HttpResponse.json(DEM_NGUON)),
    http.get('*/admin/evidence', ({ request }) => {
      duongDan.push(new URL(request.url).search);
      return HttpResponse.json({ total: items.length, page: 1, limit: 9, items });
    }),
  );
  return duongDan;
}

function moMan() {
  renderVoiKhung(
    <MemoryRouter>
      <EvidenceScreen />
    </MemoryRouter>,
  );
}

describe('Thư viện ảnh bằng chứng', () => {
  it('ảnh chưa qua AI hiện chữ chưa chấm, tuyệt đối không hiện 0%', async () => {
    dungKho([anh()]);
    moMan();

    expect(await screen.findByText('Chưa chấm điểm tự động')).toBeInTheDocument();
    expect(
      screen.getByText(/không đi qua bước soi tự động/),
    ).toBeInTheDocument();
    // 0% đọc ra là máy đã soi và không thấy gì, khác hẳn chưa soi lần nào
    expect(screen.queryByText(/0%/)).not.toBeInTheDocument();
    expect(screen.queryByText(/Máy soi đạt độ tin cậy/)).not.toBeInTheDocument();
  });

  it('ảnh đã chấm hiện đúng điểm và kết luận của lượt soi', async () => {
    dungKho([anh({ aiConfidenceScore: 0.62, aiPassed: false, anhVanXa: true })]);
    moMan();

    expect(await screen.findByText('Máy soi đạt độ tin cậy 62%')).toBeInTheDocument();
    expect(screen.getByText(/người chăm đã tự xác nhận/)).toBeInTheDocument();
    expect(screen.queryByText('Chưa chấm điểm tự động')).not.toBeInTheDocument();
  });

  it('không còn nút nào chỉ hiện toast báo chưa có API', async () => {
    dungKho([anh()]);
    moMan();

    await screen.findByText('PC3H7WK5');
    expect(screen.queryByRole('button', { name: NUT_CHET })).not.toBeInTheDocument();
    // Khoá của mấy nút đó phải bị xoá luôn, còn khoá là còn chỗ gọi lại
    expect(i18n.exists('anh.chuaCoApi')).toBe(false);
    expect(i18n.exists('anh.taiLoChuaCo')).toBe(false);
    expect(i18n.exists('anh.ganCo')).toBe(false);
    expect(i18n.exists('anh.dinhVaoKhieuNai')).toBe(false);
  });

  it('thẻ ảnh nói việc chứ không đọc tên cột trong cơ sở dữ liệu ra màn', async () => {
    dungKho([
      anh({
        id: 'bk-1-1',
        source: 'noShow',
        phase: null,
        reportKind: 'NO_SHOW',
        takenAt: '2026-08-02T07:48:00+07:00',
      }),
    ]);
    moMan();

    expect(
      await screen.findByText('Báo chủ nuôi vắng mặt · 07:48'),
    ).toBeInTheDocument();
    expect(screen.queryByText(/noShowProofUrls/)).not.toBeInTheDocument();
  });

  it('đổi tab là hỏi đúng nguồn đó và quay về trang một', async () => {
    const duongDan = dungKho([anh()]);
    moMan();

    await screen.findByText('PC3H7WK5');
    expect(duongDan[0]).toContain('source=session');

    await userEvent.setup().click(
      screen.getByRole('button', { name: /Nhật ký kỳ trông giữ/ }),
    );

    await waitFor(() => expect(duongDan.length).toBeGreaterThan(1));
    const cuoi = duongDan[duongDan.length - 1];
    expect(cuoi).toContain('source=boarding');
    expect(cuoi).toContain('page=1');
  });

  it('ảnh thiếu toạ độ thì ghi rõ chứ không đoán vị trí từ điểm hẹn', async () => {
    dungKho([anh({ photoLat: null, photoLng: null })]);
    moMan();

    expect(await screen.findByText('không có toạ độ')).toBeInTheDocument();
  });
});
