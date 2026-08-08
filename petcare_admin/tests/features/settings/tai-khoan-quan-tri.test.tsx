import { http, HttpResponse } from 'msw';
import { describe, expect, it } from 'vitest';
import { screen } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { MemoryRouter, Route, Routes } from 'react-router-dom';
import { AdminAccountCard } from '@/features/settings/components/admin-account-card';
import { renderVoiKhung } from '@tests/support/render';
import { server } from '@tests/support/server';

function taiKhoan(ghiDe: Record<string, unknown> = {}) {
  return {
    id: 'admin-1',
    hoTen: 'Kendra Nguyễn',
    email: 'kendra@petcare.vn',
    avatarUrl: null,
    taoLuc: '2026-05-12T10:00:00+07:00',
    doiMatKhauLuc: '2026-07-12T10:35:00+07:00',
    soThaoTacDaGhi: 7,
    thaoTacGanNhatLuc: '2026-08-06T17:00:00+07:00',
    ...ghiDe,
  };
}

function dungKho(ghiDe: Record<string, unknown> = {}) {
  const duongDan: string[] = [];
  server.use(
    http.get('*/admin/account', ({ request }) => {
      duongDan.push(new URL(request.url).search);
      return HttpResponse.json(taiKhoan(ghiDe));
    }),
  );
  return duongDan;
}

function moMan() {
  renderVoiKhung(
    <MemoryRouter initialEntries={['/settings']}>
      <Routes>
        <Route path="/settings" element={<AdminAccountCard />} />
        <Route path="/forgot-password" element={<p>Man gui ma xac minh</p>} />
      </Routes>
    </MemoryRouter>,
  );
}

describe('Card tài khoản quản trị viên', () => {
  it('đọc hồ sơ của chính người đang đăng nhập, không gửi id lên máy chủ', async () => {
    const duongDan = dungKho();
    moMan();

    await screen.findByText('Kendra Nguyễn');
    expect(duongDan).toEqual(['']);
    expect(screen.getByText(/kendra@petcare\.vn · Quản trị viên/)).toBeInTheDocument();
    expect(screen.getByText(/Đổi lần gần nhất/)).toBeInTheDocument();
    expect(screen.getByText(/7 thao tác đã ghi lại/)).toBeInTheDocument();
  });

  it('không hiện tên enum vai và không còn nút nào chỉ báo đang hoàn thiện', async () => {
    dungKho();
    moMan();

    await screen.findByText('Kendra Nguyễn');
    expect(screen.queryByText(/UserRole/)).toBeNull();
    ['Sửa thông tin', 'Đổi email', 'Đăng xuất hết'].forEach((nhan) => {
      expect(screen.queryByRole('button', { name: nhan })).toBeNull();
    });
    expect(screen.queryByText(/đang được hoàn thiện/)).toBeNull();
  });

  it('nút đổi mật khẩu dẫn sang luồng gửi mã xác minh, không báo đang làm', async () => {
    dungKho();
    moMan();

    await screen.findByText('Kendra Nguyễn');
    await userEvent.setup().click(screen.getByRole('button', { name: 'Đổi mật khẩu' }));

    expect(await screen.findByText('Man gui ma xac minh')).toBeInTheDocument();
  });

  it('chưa đổi mật khẩu lần nào thì nói rõ, không hiện ngày rỗng', async () => {
    dungKho({ doiMatKhauLuc: null, soThaoTacDaGhi: 0, thaoTacGanNhatLuc: null });
    moMan();

    await screen.findByText('Kendra Nguyễn');
    expect(screen.getByText(/Chưa đổi lần nào kể từ khi lập tài khoản/)).toBeInTheDocument();
    expect(screen.getByText('Chưa làm thao tác nào được ghi lại')).toBeInTheDocument();
    expect(screen.queryByText(/Đổi lần gần nhất/)).toBeNull();
  });
});
