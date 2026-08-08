import { http, HttpResponse } from 'msw';
import { describe, expect, it } from 'vitest';
import { screen } from '@testing-library/react';
import { MemoryRouter } from 'react-router-dom';
import { DisputesScreen } from '@/features/disputes/screens/disputes-screen';
import { renderVoiKhung } from '@tests/support/render';
import { server, THAM_SO_VAN_HANH } from '@tests/support/server';

// Mở hồ sơ 4 ngày trước: quá hạn nếu chỉ tiêu là 3 ngày, còn hạn nếu chỉ tiêu là 7
const MO_LUC = new Date(Date.now() - 4 * 24 * 3600_000).toISOString();

function dong() {
  return {
    code: 'KN-PC9C4RN6',
    bookingCode: 'PC9C4RN6',
    serviceType: 'WALKING',
    serviceName: 'Dắt đi dạo',
    reporterName: 'Nguyễn Hải Yến',
    reporterRole: 'OWNER',
    reporterAvatarUrl: null,
    sitterName: 'Trịnh Văn Nam',
    description: 'Người chăm tới muộn',
    createdAt: MO_LUC,
    replyDeadline: null,
    sitterReplyAt: null,
    status: 'REVIEWING',
    refundAmount: null,
  };
}

function dungKho(hanNgay: number | null) {
  server.use(
    http.get('*/admin/settings', () =>
      HttpResponse.json({
        ...THAM_SO_VAN_HANH,
        items: THAM_SO_VAN_HANH.items.map((item) =>
          item.key === 'dispute.support_days' ? { ...item, giaTri: hanNgay } : item,
        ),
      }),
    ),
    http.get('*/admin/disputes/counts', () =>
      HttpResponse.json({ waitingSitter: 1, waitingSupport: 0, resolved: 0 }),
    ),
    http.get('*/admin/disputes', () =>
      HttpResponse.json({ total: 1, page: 1, limit: 10, items: [dong()] }),
    ),
  );
}

function moMan() {
  renderVoiKhung(
    <MemoryRouter>
      <DisputesScreen />
    </MemoryRouter>,
  );
}

describe('Hạn kết luận khiếu nại đọc từ tham số vận hành', () => {
  it('quản trị viên vặn chỉ tiêu xuống 3 ngày thì badge đọc theo 3 ngày', async () => {
    dungKho(3);
    moMan();

    expect(await screen.findByText(/trễ [0-9]+ ngày/)).toBeInTheDocument();
    expect(screen.getByText(/Hạn 3 ngày là chỉ tiêu xử lý/)).toBeInTheDocument();
    expect(screen.queryByText(/Hạn 7 ngày/)).toBeNull();
  });

  it('giữ chỉ tiêu 7 ngày thì cùng hồ sơ đó vẫn còn hạn', async () => {
    dungKho(7);
    moMan();

    expect(await screen.findByText(/còn 3 ngày/)).toBeInTheDocument();
    expect(screen.queryByText(/trễ/)).toBeNull();
  });

  it('chưa đọc được chỉ tiêu thì để trống chứ không đếm theo số cũ', async () => {
    dungKho(null);
    moMan();

    expect(await screen.findByText('KN-PC9C4RN6')).toBeInTheDocument();
    expect(screen.queryByText(/còn 3 ngày/)).toBeNull();
    expect(screen.queryByText(/trễ/)).toBeNull();
    expect(screen.queryByText(/là chỉ tiêu xử lý/)).toBeNull();
  });
});
