import { http, HttpResponse, delay } from 'msw';
import { describe, expect, it, vi } from 'vitest';
import { fireEvent, screen, waitFor } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { LockUserDialog } from '@/features/users/components/lock-user-dialog';
import { renderVoiKhung } from '@tests/support/render';
import { server } from '@tests/support/server';

const NGUOI_DUNG = {
  id: 'u-1',
  fullName: 'Trần Thị Hoa',
  isActive: true,
  role: 'CUSTOMER' as const,
};

function chiTiet(soDonDangChay: number) {
  return {
    id: NGUOI_DUNG.id,
    stats: { runningBookingCount: soDonDangChay },
  };
}

function nutKhoa() {
  return screen.getByRole('button', { name: 'Khoá tài khoản' });
}

// Gõ từng phím mất vài trăm ms, đủ để lượt hỏi API xong trước khi kiểm
function nhapLyDo(noiDung: string) {
  fireEvent.change(screen.getByRole('textbox'), { target: { value: noiDung } });
}

describe('LockUserDialog', () => {
  it('khoá nút xác nhận khi chưa biết số đơn đang chạy', async () => {
    // API cố tình chậm để bắt đúng khoảnh khắc dialog chưa biết số đơn
    server.use(
      http.get('*/admin/users/:id', async () => {
        await delay(200);
        return HttpResponse.json(chiTiet(0));
      }),
    );
    renderVoiKhung(<LockUserDialog target={NGUOI_DUNG} onClose={vi.fn()} />);

    nhapLyDo('Gian lận thanh toán');
    expect(screen.getByText(/Đang kiểm xem người này/)).toBeInTheDocument();
    // Đủ lý do rồi nhưng vẫn phải chờ: đọc thiếu thành 0 là khoá nhầm người đang làm dở
    expect(nutKhoa()).toBeDisabled();

    await waitFor(() => expect(nutKhoa()).toBeEnabled());
  });

  it('mạng lỗi thì báo không kiểm được chứ không im lặng coi như không có đơn', async () => {
    server.use(http.get('*/admin/users/:id', () => HttpResponse.error()));
    renderVoiKhung(<LockUserDialog target={NGUOI_DUNG} onClose={vi.fn()} />);

    nhapLyDo('Gian lận thanh toán');
    expect(
      await screen.findByText(/Không kiểm được số đơn đang chạy/),
    ).toBeInTheDocument();
  });

  it('có đơn đang chạy thì cảnh báo kèm đúng số', async () => {
    server.use(
      http.get('*/admin/users/:id', () => HttpResponse.json(chiTiet(3))),
    );
    renderVoiKhung(<LockUserDialog target={NGUOI_DUNG} onClose={vi.fn()} />);

    expect(await screen.findByText(/còn 3 đơn đang chạy/)).toBeInTheDocument();
  });

  it('không đơn nào thì không hiện cảnh báo', async () => {
    server.use(
      http.get('*/admin/users/:id', () => HttpResponse.json(chiTiet(0))),
    );
    renderVoiKhung(<LockUserDialog target={NGUOI_DUNG} onClose={vi.fn()} />);

    nhapLyDo('Tài khoản trùng lặp');
    await waitFor(() => expect(nutKhoa()).toBeEnabled());
    expect(screen.queryByText(/đơn đang chạy/)).not.toBeInTheDocument();
  });

  it('mở khoá thì không hỏi số đơn vì không làm treo thêm đơn nào', async () => {
    renderVoiKhung(
      <LockUserDialog
        target={{ ...NGUOI_DUNG, isActive: false }}
        onClose={vi.fn()}
      />,
    );

    const nut = screen.getByRole('button', { name: 'Mở khoá' });
    expect(nut).toBeDisabled();
    await userEvent.setup().type(screen.getByRole('textbox'), 'Đã xác minh');
    expect(nut).toBeEnabled();
    expect(screen.queryByText(/Đang kiểm xem người này/)).not.toBeInTheDocument();
  });
});
