import { http, HttpResponse } from 'msw';
import { describe, expect, it } from 'vitest';
import { screen } from '@testing-library/react';
import { MemoryRouter, Route, Routes } from 'react-router-dom';
import { BookingConversationScreen } from '@/features/bookings/screens/booking-conversation-screen';
import { renderVoiKhung } from '@tests/support/render';
import { server } from '@tests/support/server';

function tin(ghiDe: Record<string, unknown> = {}) {
  return {
    id: 'tin-1',
    sender: 'OWNER',
    kind: 'TEXT',
    sentAt: '2026-08-04T09:10:00+07:00',
    content: 'Bé nhà mình hơi nhát người lạ',
    photoCount: 0,
    masked: false,
    ...ghiDe,
  };
}

function dungKho(ghiDe: Record<string, unknown> = {}) {
  server.use(
    http.get('*/admin/bookings/:code/conversation', () =>
      HttpResponse.json({
        code: 'PC6Q5MT3',
        ownerName: 'Trần Minh Anh',
        sitterName: 'Đặng Khắc Duy',
        openedAt: '2026-08-04T08:00:00+07:00',
        closedAt: null,
        entries: [tin()],
        truncated: false,
        ...ghiDe,
      }),
    ),
  );
}

function moMan() {
  renderVoiKhung(
    <MemoryRouter initialEntries={['/bookings/PC6Q5MT3/conversation']}>
      <Routes>
        <Route
          path="/bookings/:code/conversation"
          element={<BookingConversationScreen />}
        />
      </Routes>
    </MemoryRouter>,
  );
}

describe('Nhật ký hội thoại của đơn', () => {
  it('nói rõ quản trị viên chỉ đọc và không dựng lối gửi tin nào', async () => {
    dungKho();
    moMan();

    expect(await screen.findByText(/chỉ đọc lại hội thoại/)).toBeInTheDocument();
    expect(screen.queryByRole('textbox')).not.toBeInTheDocument();
    expect(screen.queryByRole('button', { name: /gửi/i })).not.toBeInTheDocument();
  });

  it('tin của người chăm ghi đúng tên và vai, không đội tên chủ nuôi', async () => {
    dungKho({
      entries: [tin({ id: 'tin-2', sender: 'SITTER', content: 'Mình tới trước 5 phút' })],
    });
    moMan();

    expect(await screen.findByText('Mình tới trước 5 phút')).toBeInTheDocument();
    expect(screen.getByText(/Đặng Khắc Duy · Người chăm/)).toBeInTheDocument();
    expect(screen.queryByText(/Trần Minh Anh · Chủ nuôi/)).not.toBeInTheDocument();
  });

  it('tin gửi vị trí không có chữ thì nói ra, không để dòng trống', async () => {
    dungKho({
      entries: [tin({ id: 'tin-3', sender: 'SITTER', kind: 'LOCATION', content: '' })],
    });
    moMan();

    expect(await screen.findByText('Đã gửi vị trí')).toBeInTheDocument();
  });

  it('tin đã che liên lạc có dòng nhắc, tầng đọc không che thêm lần nữa', async () => {
    dungKho({ entries: [tin({ content: 'Gọi mình số ***', masked: true })] });
    moMan();

    expect(await screen.findByText('Gọi mình số ***')).toBeInTheDocument();
    expect(
      screen.getByText('Tin có số điện thoại hoặc liên kết đã bị che'),
    ).toBeInTheDocument();
  });

  it('hội thoại bị cắt ở trần thì màn phải nói ra', async () => {
    dungKho({ truncated: true });
    moMan();

    expect(await screen.findByText(/chưa phải toàn bộ tin của đơn/)).toBeInTheDocument();
  });

  it('đơn khép rồi thì ghi mốc khoá lấy từ máy chủ', async () => {
    dungKho({ closedAt: '2026-08-04T12:00:00+07:00' });
    moMan();

    expect(await screen.findByText(/Hội thoại đã khoá lúc/)).toBeInTheDocument();
  });
});
