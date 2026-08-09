import { http, HttpResponse } from 'msw';
import { describe, expect, it } from 'vitest';
import { screen, within } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { MemoryRouter, Route, Routes } from 'react-router-dom';
import { SitterDetailScreen } from '@/features/sitters/screens/sitter-detail-screen';
import { renderVoiKhung } from '@tests/support/render';
import { server } from '@tests/support/server';

const DIA_CHI_DAI =
  'Số 12 Giải Phóng, Phường Phương Mai, Quận Đống Đa, Thành phố Hà Nội, Việt Nam';

function hoSo(ghiDe: Record<string, unknown> = {}) {
  return {
    sitter: {
      id: 'ncc-1',
      userId: 'user-9',
      legalName: 'Trịnh Văn Nam',
      gender: 'MALE',
      dateOfBirth: '1998-04-02',
      nationalId: '001098000123',
      idIssuedPlace: 'Cục Cảnh sát',
      idIssuedDate: '2021-06-10',
      province: 'Hà Nội',
      addressDetail: DIA_CHI_DAI,
      submittedAt: '2026-07-20T02:00:00+07:00',
      approvedAt: '2026-07-21T02:00:00+07:00',
      onboardedAt: '2026-07-22T02:00:00+07:00',
      serviceAddress: DIA_CHI_DAI,
      serviceAddressNote: null,
      serviceRadiusKm: 8,
      lat: 21.0025,
      lng: 105.8412,
      status: 'APPROVED',
      hiddenUntil: null,
      hiddenCount: 0,
      hiddenTimesInWindow: 0,
      bannedAt: null,
      ...ghiDe,
    },
    user: {
      fullName: 'Nam Trịnh',
      email: 'nam@example.com',
      phone: '0901234567',
      createdAt: '2026-05-01T02:00:00+07:00',
      avatarUrl: null,
    },
    documents: { frontUrl: null, backUrl: null },
    services: [],
    penalties: [],
    stats: {
      bookingCount: 12,
      cancelRate: 0.05,
      runningBookingCount: 0,
      ratingAvg: 4.8,
      totalReviews: 20,
    },
  };
}

function moMan(du = hoSo()) {
  server.use(
    http.get('*/admin/settings', () =>
      HttpResponse.json({ capNhatLuc: null, items: [] }),
    ),
    http.get('*/admin/sitters/:id', () => HttpResponse.json(du)),
  );
  return renderVoiKhung(
    <MemoryRouter initialEntries={['/sitter-approvals/ncc-1']}>
      <Routes>
        <Route path="/sitter-approvals/:id" element={<SitterDetailScreen />} />
      </Routes>
    </MemoryRouter>,
  );
}

describe('Hồ sơ người chăm: ô trống và dòng thông tin', () => {
  it('ô không có dữ liệu hiện chữ chưa có, không còn dấu gạch', async () => {
    const { container } = moMan(hoSo({ legalName: null, nationalId: null }));

    await screen.findAllByText('Nam Trịnh');
    expect(screen.getAllByText('Chưa có').length).toBeGreaterThan(0);
    expect(container.textContent).not.toContain('—');
  });

  it('địa chỉ dài hiện đủ, không bị cắt giữa chừng', async () => {
    moMan();

    const o = await screen.findAllByText(DIA_CHI_DAI);
    expect(o.length).toBeGreaterThan(0);
    // truncate cắt bằng CSS nên phải soi đúng lớp, không soi được bằng chữ hiện ra
    expect(o[0].className).not.toContain('truncate');
    expect(o[0].className).toContain('break-words');
  });
});

describe('Bản đồ vùng phục vụ', () => {
  it('có toạ độ thì vẽ bản đồ thật, không còn câu đang hoàn thiện', async () => {
    const { container } = moMan();

    await screen.findAllByText('Nam Trịnh');
    expect(container.textContent).not.toContain('đang được hoàn thiện');
    expect(container.querySelector('.leaflet-container')).not.toBeNull();
    // Nền chuẩn của OpenStreetMap, nền nhạt hơn thì tên đường đọc không ra
    const nen = Array.from(container.querySelectorAll('img.leaflet-tile')).map(
      (anh) => anh.getAttribute('src'),
    );
    expect(nen.some((src) => src?.includes('tile.openstreetmap.org'))).toBe(true);
    // Điều kiện dùng tile bắt ghi nguồn ngay trên bản đồ
    expect(screen.getByText(/OpenStreetMap contributors/)).toBeInTheDocument();
  });

  it('vẽ vòng bán kính chứ không chỉ chấm một điểm', async () => {
    const { container } = moMan();

    await screen.findAllByText('Nam Trịnh');
    const vong = container.querySelector('.leaflet-overlay-pane path');
    expect(vong?.getAttribute('class')).toContain('stroke-primary');
    // Ghim phải là SVG dựng tại chỗ, icon mặc định của Leaflet là ảnh và vỡ sau khi đóng gói
    const ghim = container.querySelector('.leaflet-marker-pane svg');
    expect(ghim).not.toBeNull();
  });

  it('thiếu toạ độ thì nói thẳng là chưa có, không hứa hẹn', async () => {
    const { container } = moMan(hoSo({ lat: null, lng: null }));

    expect(
      await screen.findByText('Hồ sơ này chưa có toạ độ điểm làm việc'),
    ).toBeInTheDocument();
    expect(container.querySelector('.leaflet-container')).toBeNull();
  });

  it('bấm bản đồ mở lớp xem lớn kèm địa chỉ và toạ độ chính xác', async () => {
    const nguoiDung = userEvent.setup();
    moMan();

    await screen.findAllByText('Nam Trịnh');
    await nguoiDung.click(
      screen.getByRole('button', { name: 'Mở bản đồ vùng phục vụ' }),
    );

    const hop = await screen.findByRole('dialog');
    expect(within(hop).getByText('21.0025, 105.8412')).toBeInTheDocument();
    expect(within(hop).getAllByText(DIA_CHI_DAI).length).toBeGreaterThan(0);
    expect(within(hop).getByText('8 km')).toBeInTheDocument();
  });

  it('lớp xem lớn phóng to thu nhỏ được, kèm lối chỉ đường ra ngoài', async () => {
    const nguoiDung = userEvent.setup();
    const { container } = moMan();

    await screen.findAllByText('Nam Trịnh');
    // Thẻ trong trang chỉ để xem lướt, bật cuộn chuột ở đó là cướp mất cuộn trang
    expect(container.querySelector('.leaflet-control-zoom')).toBeNull();

    await nguoiDung.click(
      screen.getByRole('button', { name: 'Mở bản đồ vùng phục vụ' }),
    );

    const hop = await screen.findByRole('dialog');
    expect(within(hop).getByRole('button', { name: 'Zoom in' })).toBeInTheDocument();

    const chiDuong = within(hop).getByRole('link', { name: 'Chỉ đường' });
    expect(chiDuong).toHaveAttribute(
      'href',
      'https://www.google.com/maps/dir/?api=1&destination=21.0025,105.8412',
    );
    expect(chiDuong).toHaveAttribute('target', '_blank');
  });

  it('bản đồ trong card kẹp chiều cao, không dựng khung to hơn thẻ', async () => {
    const { container } = moMan();

    await screen.findAllByText('Nam Trịnh');
    const khung = container.querySelector<HTMLElement>('.leaflet-container');
    expect(Number.parseInt(khung?.style.height ?? '0', 10)).toBeLessThanOrEqual(260);
  });
});
