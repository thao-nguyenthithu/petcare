import { describe, expect, it } from 'vitest';
import { screen, within } from '@testing-library/react';
import { MemoryRouter } from 'react-router-dom';
import { NotificationTypesScreen } from '@/features/notifications/screens/notification-types-screen';
import { renderVoiKhung } from '@tests/support/render';

function dungMan() {
  return renderVoiKhung(
    <MemoryRouter>
      <NotificationTypesScreen />
    </MemoryRouter>,
  );
}

describe('Bảng mười hai loại thông báo', () => {
  it('không gọi API nào: server MSW không khai handler mà màn vẫn dựng đủ', () => {
    dungMan();

    expect(screen.getByText('Đơn đặt lịch')).toBeInTheDocument();
    expect(screen.getAllByText('Thông báo hệ thống').length).toBeGreaterThan(0);
  });

  it('cột cuối là tình trạng trigger chỉ đọc, không có công tắc bật tắt', () => {
    dungMan();

    expect(screen.getByText('TÌNH TRẠNG')).toBeInTheDocument();
    expect(screen.queryAllByRole('switch')).toHaveLength(0);
    expect(screen.queryByText('ĐÃ CÀI')).toBeNull();
    expect(screen.getAllByText('Chưa có')).toHaveLength(3);
  });

  it('ba loại backend đã bắn tin thật phải đọc là Đã có, không để Chưa có', () => {
    dungMan();

    const bang = screen.getByRole('table');
    for (const nhan of ['Hồ sơ người chăm', 'Phòng bệnh', 'Khiếu nại']) {
      const dong = within(bang).getByText(nhan).closest('tr');
      expect(within(dong as HTMLElement).getByText('Đã có')).toBeInTheDocument();
    }
  });

  it('không còn nút gửi thử vì quản trị viên không có thiết bị nhận push', () => {
    dungMan();

    expect(screen.queryByRole('button', { name: /gửi thử/i })).toBeNull();
  });

  it('card giữa đếm số loại chưa có trigger từ chính dữ liệu bảng', () => {
    dungMan();

    expect(screen.getByText('3 loại chưa có trigger')).toBeInTheDocument();
  });
});
