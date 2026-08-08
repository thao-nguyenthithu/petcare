import { http, HttpResponse } from 'msw';
import { describe, expect, it } from 'vitest';
import { screen } from '@testing-library/react';
import { MemoryRouter, Route, Routes } from 'react-router-dom';
import { BookingAlbumScreen } from '@/features/evidence/screens/booking-album-screen';
import { renderVoiKhung } from '@tests/support/render';
import { server } from '@tests/support/server';

const NUT_CHET = /Gắn cờ bằng chứng|Đính vào khiếu nại|Chọn nhiều|Tải toàn bộ|Tải xuống lô ảnh/;

function anhAlbum(id: string, ghiDe: Record<string, unknown> = {}) {
  return {
    id,
    url: `https://kho/${id}.jpg`,
    takenAt: '2026-08-02T08:12:00+07:00',
    photoLat: 21.0285,
    photoLng: 105.8048,
    distanceFromMeetingM: 12,
    anhDoDung: false,
    anhVanXa: false,
    aiConfidenceScore: null,
    aiPassed: null,
    ...ghiDe,
  };
}

function nhom(key: string, photos: Array<Record<string, unknown>>, ghiDe = {}) {
  return {
    key,
    dayIndex: null,
    date: photos[0]?.takenAt ?? null,
    photoCount: photos.length,
    conditions: [],
    message: null,
    photos,
    ...ghiDe,
  };
}

function dungKho(than: Record<string, unknown>) {
  server.use(
    http.get('*/admin/bookings/:code/evidence', () => HttpResponse.json(than)),
  );
}

function moMan(code = 'PC8B2FD7') {
  renderVoiKhung(
    <MemoryRouter initialEntries={[`/evidence/${code}`]}>
      <Routes>
        <Route path="/evidence/:code" element={<BookingAlbumScreen />} />
      </Routes>
    </MemoryRouter>,
  );
}

const DON_DAT = {
  booking: {
    code: 'PC6Q5MT3',
    serviceType: 'WALKING',
    serviceName: 'Dắt đi dạo',
    scheduledAt: '2026-08-04T09:00:00+07:00',
    scheduledEndAt: '2026-08-04T10:00:00+07:00',
    nights: null,
    reportKind: null,
  },
  groups: [
    nhom('CHECK_IN', [anhAlbum('a1')]),
    nhom('IN_PROGRESS', []),
    nhom('CHECK_OUT', []),
  ],
  stats: {
    total: 1,
    dayCount: null,
    conditionCount: null,
    missingDayCount: null,
    messageCount: null,
  },
};

describe('Album ảnh của một đơn', () => {
  it('đơn dắt bỏ hẳn bốn ô của kỳ giữ chứ không hiện 0 ngày', async () => {
    dungKho(DON_DAT);
    moMan('PC6Q5MT3');

    expect(await screen.findByText('TỔNG SỐ ẢNH')).toBeInTheDocument();
    expect(screen.queryByText('SỐ NGÀY CÓ BẢN')).not.toBeInTheDocument();
    expect(screen.queryByText('NGÀY THIẾU ẢNH')).not.toBeInTheDocument();
    expect(screen.queryByText('0 ngày')).not.toBeInTheDocument();
  });

  it('pha chưa có ảnh vẫn hiện nhóm rỗng để thấy ngay chỗ thiếu', async () => {
    dungKho(DON_DAT);
    moMan('PC6Q5MT3');

    expect(await screen.findByText('Check-out')).toBeInTheDocument();
    expect(screen.getAllByText('Nhóm này chưa có ảnh nào')).toHaveLength(2);
  });

  it('kỳ giữ tách nhóm đồ dùng ra khỏi nhóm ảnh các bé', async () => {
    dungKho({
      booking: {
        code: 'PC8B2FD7',
        serviceType: 'BOARDING',
        serviceName: 'Trông giữ',
        scheduledAt: '2026-08-01T08:00:00+07:00',
        scheduledEndAt: '2026-08-04T08:00:00+07:00',
        nights: 3,
        reportKind: null,
      },
      groups: [
        nhom('nhanBe', [anhAlbum('b1')]),
        nhom('supplyIn', [anhAlbum('d1', { anhDoDung: true })]),
        nhom('ngay-1', [anhAlbum('n1')], {
          dayIndex: 1,
          conditions: ['Ăn ngon miệng'],
          message: 'Bé ngủ ngoan',
        }),
        nhom('traBe', []),
        nhom('supplyOut', []),
      ],
      stats: {
        total: 3,
        dayCount: 1,
        conditionCount: 1,
        missingDayCount: 2,
        messageCount: 1,
      },
    });
    moMan();

    expect(await screen.findByText('Ảnh lúc nhận bé')).toBeInTheDocument();
    expect(screen.getByText('Đồ dùng chủ nuôi gửi kèm')).toBeInTheDocument();
    expect(screen.getByText(/Ngày 1 ·/)).toBeInTheDocument();
    expect(screen.getByText('Bé ngủ ngoan')).toBeInTheDocument();
    expect(screen.getByText('NGÀY THIẾU ẢNH')).toBeInTheDocument();
    expect(screen.getByText('2 ngày')).toBeInTheDocument();
  });

  it('nhóm sự cố nói rõ nhánh nào, ba nhánh cùng ghi vào một cột ảnh', async () => {
    dungKho({
      ...DON_DAT,
      booking: { ...DON_DAT.booking, reportKind: 'SITTER_ABANDON' },
      groups: [...DON_DAT.groups, nhom('suCo', [anhAlbum('s1')])],
    });
    moMan('PC6Q5MT3');

    expect(
      await screen.findByText(/Ảnh người chăm báo sự cố · Người chăm bỏ đơn giữa chừng/),
    ).toBeInTheDocument();
  });

  it('không còn nút nào chỉ hiện toast báo chưa có API', async () => {
    dungKho(DON_DAT);
    moMan('PC6Q5MT3');

    await screen.findByText('TỔNG SỐ ẢNH');
    expect(screen.queryByRole('button', { name: NUT_CHET })).not.toBeInTheDocument();
    expect(screen.queryByText('Kích thước')).not.toBeInTheDocument();
  });

  it('panel hiện độ lệch so với điểm hẹn và chỗ chưa chấm điểm', async () => {
    dungKho(DON_DAT);
    moMan('PC6Q5MT3');

    expect(await screen.findByText(/21.0285, 105.8048 · lệch 12 m/)).toBeInTheDocument();
    expect(screen.getByText('Chưa chấm điểm tự động')).toBeInTheDocument();
    expect(screen.queryByText(/0%/)).not.toBeInTheDocument();
  });
});
