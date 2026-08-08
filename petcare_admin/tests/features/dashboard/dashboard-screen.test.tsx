import { http, HttpResponse } from 'msw';
import { describe, expect, it } from 'vitest';
import { screen } from '@testing-library/react';
import { MemoryRouter } from 'react-router-dom';
import { DashboardScreen } from '@/features/dashboard/screens/dashboard-screen';
import { QueueBell } from '@/features/dashboard/components/queue-bell';
import { renderVoiKhung } from '@tests/support/render';
import { server } from '@tests/support/server';

// Ô phần trăm của thẻ số liệu, không khớp câu phụ kiểu "hoa hồng 64,3 triệu"
const O_PHAN_TRAM = /^[+-]?[\d.,]+%$/;

// Mười hai cột trượt, cột cuối là tháng đang chạy nên số tháng vòng qua năm cũ
const MUOI_HAI_THANG = Array.from({ length: 12 }, (_, i) => ({
  month: ((i + 8) % 12) + 1,
  sitterPayout: 236_000_000 + i * 1_000_000,
  platformFee: 36_000_000,
}));

function don(ghiDe: Record<string, unknown> = {}) {
  return {
    code: 'PC6Q5MT3',
    ownerName: 'Trần Minh Anh',
    ownerPhone: '0912345678',
    serviceName: 'Dắt đi dạo',
    durationMinutes: 60,
    status: 'IN_PROGRESS',
    totalPrice: 180000,
    ...ghiDe,
  };
}

function tongQuan(ghiDe: Record<string, unknown> = {}) {
  return {
    users: { total: 12480, delta: null },
    sitters: { active: 386, pending: 8, delta: null },
    bookings: { thisMonth: 2145, ongoing: 96, delta: null },
    revenue: {
      total: 428_600_000,
      commission: 64_300_000,
      escrowHeld: 23_100_000,
      delta: null,
    },
    revenueByMonth: MUOI_HAI_THANG,
    serviceMix: [
      { type: 'WALKING', count: 986, percent: 46 },
      { type: 'BOARDING', count: 688, percent: 32 },
      { type: 'GROOMING', count: 471, percent: 22 },
    ],
    recentBookings: [don()],
    ...ghiDe,
  };
}

const HANG_CHO = {
  total: 14,
  items: [
    {
      key: 'sitterPending',
      label: 'Hồ sơ người chăm chờ duyệt',
      count: 8,
      hint: 'Hồ sơ cũ nhất đã chờ 2 ngày',
    },
    {
      key: 'disputeReview',
      label: 'Khiếu nại chờ kết luận',
      count: 5,
      hint: 'Chưa kết luận thì tiền của đơn vẫn bị giữ',
    },
    {
      key: 'withdrawalPending',
      label: 'Người chăm chờ nhận tiền rút',
      count: 0,
      hint: 'Không còn lệnh rút nào chờ chuyển',
    },
    {
      key: 'penaltyReview',
      label: 'Người chăm xin miễn phạt',
      count: 1,
      hint: 'Chưa soát thì án phạt vẫn còn hiệu lực',
    },
  ],
};

function dungKho(soLieu: Record<string, unknown>, hangCho: unknown = HANG_CHO) {
  server.use(
    http.get('*/admin/dashboard', () => HttpResponse.json(soLieu)),
    http.get('*/admin/queue', () => HttpResponse.json(hangCho)),
  );
}

function moMan() {
  renderVoiKhung(
    <MemoryRouter>
      <DashboardScreen />
    </MemoryRouter>,
  );
}

describe('Bốn chỉ số của màn tổng quan', () => {
  it('kỳ trước rỗng thì không thẻ nào hiện phần trăm', async () => {
    dungKho(tongQuan());
    moMan();

    expect(await screen.findByText('TỔNG NGƯỜI DÙNG')).toBeInTheDocument();
    expect(screen.getByText('12.480')).toBeInTheDocument();
    expect(screen.queryAllByText(O_PHAN_TRAM)).toHaveLength(0);
  });

  it('thẻ người chăm không bao giờ có phần trăm vì thiếu mốc duyệt hồ sơ', async () => {
    dungKho(
      tongQuan({
        users: { total: 12480, delta: 12.5 },
        sitters: { active: 386, pending: 8, delta: null },
        bookings: { thisMonth: 2145, ongoing: 96, delta: 18.3 },
        revenue: {
          total: 428_600_000,
          commission: 64_300_000,
          escrowHeld: 23_100_000,
          delta: -9.8,
        },
      }),
    );
    moMan();

    expect(await screen.findByText('TỔNG NGƯỜI DÙNG')).toBeInTheDocument();
    expect(screen.queryAllByText(O_PHAN_TRAM)).toHaveLength(3);
    expect(screen.getByText('8 hồ sơ chờ duyệt')).toBeInTheDocument();
  });
});

describe('Bảng đơn gần đây', () => {
  it('hiện đúng trạng thái thật của đơn chứ không gộp về sáu nhãn', async () => {
    dungKho(
      tongQuan({
        recentBookings: [
          don({ status: 'CANCELLED_BY_OWNER' }),
          don({ code: 'PC8B2FD7', status: 'AWAITING_OWNER_CONFIRM' }),
        ],
      }),
    );
    moMan();

    expect(await screen.findByText('Chủ nuôi huỷ')).toBeInTheDocument();
    expect(screen.getByText('Chờ xác nhận')).toBeInTheDocument();
  });

  it('thiếu số điện thoại hay chưa chốt giá thì để trống, không lấp bằng 0', async () => {
    dungKho(
      tongQuan({
        recentBookings: [don({ ownerPhone: null, totalPrice: null, durationMinutes: null })],
      }),
    );
    moMan();

    expect(await screen.findByText('PC6Q5MT3')).toBeInTheDocument();
    expect(screen.getAllByText('Chưa có')).toHaveLength(2);
    expect(screen.queryByText('0 đ')).toBeNull();
  });

  it('chưa có đơn nào qua cổng thanh toán thì bảng nói rõ, không dựng dòng giả', async () => {
    dungKho(tongQuan({ recentBookings: [] }));
    moMan();

    expect(await screen.findByText('Chưa có đơn nào đã qua cổng thanh toán')).toBeInTheDocument();
  });
});

describe('Hai biểu đồ', () => {
  it('kỳ chưa có số liệu thì giữ trục và nói rõ, không vẽ cột giả', async () => {
    dungKho(
      tongQuan({
        revenueByMonth: MUOI_HAI_THANG.map((m) => ({
          ...m,
          sitterPayout: 0,
          platformFee: 0,
        })),
        serviceMix: [
          { type: 'WALKING', count: 0, percent: 0 },
          { type: 'BOARDING', count: 0, percent: 0 },
          { type: 'GROOMING', count: 0, percent: 0 },
        ],
      }),
    );
    moMan();

    expect(await screen.findAllByText('Chưa có dữ liệu trong kỳ')).toHaveLength(2);
  });

  it('vành khuyên giữ thứ tự lát theo enum chứ không sắp theo số lượng', async () => {
    dungKho(
      tongQuan({
        serviceMix: [
          { type: 'WALKING', count: 100, percent: 20 },
          { type: 'BOARDING', count: 250, percent: 50 },
          { type: 'GROOMING', count: 150, percent: 30 },
        ],
      }),
    );
    moMan();

    const lat = await screen.findAllByText(/đơn · \d+%$/);
    expect(lat.map((n) => n.textContent)).toEqual([
      '100 đơn · 20%',
      '250 đơn · 50%',
      '150 đơn · 30%',
    ]);
  });
});

describe('Hàng chờ việc', () => {
  it('dòng đếm 0 vẫn giữ chỗ, mỗi dòng trỏ đúng màn xử lý', async () => {
    dungKho(tongQuan());
    moMan();

    const rut = await screen.findByRole('link', { name: /Người chăm chờ nhận tiền rút/ });
    expect(rut).toHaveAttribute('href', '/finance');
    expect(screen.getByText('Không còn lệnh rút nào chờ chuyển')).toBeInTheDocument();
    expect(screen.getByRole('link', { name: /Hồ sơ người chăm chờ duyệt/ })).toHaveAttribute(
      'href',
      '/sitter-approvals',
    );
    expect(screen.getByRole('link', { name: /Người chăm xin miễn phạt/ })).toHaveAttribute(
      'href',
      '/penalties',
    );
  });

  it('chuông đếm tổng bốn dòng lấy nguyên từ máy chủ', async () => {
    dungKho(tongQuan());
    renderVoiKhung(
      <MemoryRouter>
        <QueueBell />
      </MemoryRouter>,
    );

    expect(await screen.findByText('14')).toBeInTheDocument();
  });

  it('hết việc thì chuông không hiện chấm đếm', async () => {
    dungKho(tongQuan(), {
      total: 0,
      items: HANG_CHO.items.map((m) => ({ ...m, count: 0 })),
    });
    renderVoiKhung(
      <MemoryRouter>
        <QueueBell />
      </MemoryRouter>,
    );

    expect(await screen.findByLabelText('Việc cần làm')).toBeInTheDocument();
    expect(screen.queryByText('0')).toBeNull();
  });
});
