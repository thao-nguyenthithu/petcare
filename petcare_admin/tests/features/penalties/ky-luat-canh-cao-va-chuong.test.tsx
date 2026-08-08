import { http, HttpResponse } from 'msw';
import { describe, expect, it } from 'vitest';
import { fireEvent, screen, waitFor, within } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { MemoryRouter } from 'react-router-dom';
import { QueueBell } from '@/features/dashboard/components/queue-bell';
import { PenaltiesScreen } from '@/features/penalties/screens/penalties-screen';
import { renderVoiKhung } from '@tests/support/render';
import { server } from '@tests/support/server';

function dongPhat(ghiDe: Record<string, unknown> = {}) {
  return {
    id: 'p-1',
    sitterId: 'ncc-1',
    sitterName: 'Trịnh Văn Nam',
    kind: 'CANCEL_RATE',
    status: 'PENDING_REVIEW',
    reason: 'Xe hỏng giữa đường',
    createdAt: '2026-08-07T02:00:00.000Z',
    reviewDeadline: '2026-08-08T02:00:00.000Z',
    bookingCode: 'PC9C4RN6',
    serviceName: 'Dắt đi dạo',
    profile: {
      cancelRate: 0.25,
      warningCount: 3,
      hiddenCount: 1,
      hiddenTimesInWindow: 1,
      hiddenUntil: null,
      bannedAt: null,
      ...(ghiDe.profile as Record<string, unknown> | undefined),
    },
    ...ghiDe,
  };
}

function dungKho() {
  server.use(
    http.get('*/admin/penalties/counts', () =>
      HttpResponse.json({ pendingReview: 1, active: 0, waived: 0, hidden: 0 }),
    ),
    http.get('*/admin/penalties', () =>
      HttpResponse.json({ total: 1, page: 1, limit: 10, items: [dongPhat()] }),
    ),
  );
}

describe('Cột người chăm của màn kỷ luật', () => {
  it('hiện cả tỷ lệ huỷ lẫn số cảnh cáo của cùng cửa sổ', async () => {
    dungKho();
    renderVoiKhung(
      <MemoryRouter>
        <PenaltiesScreen />
      </MemoryRouter>,
    );

    expect(await screen.findByText('Tỷ lệ huỷ hiện tại 25% · 3 cảnh cáo')).toBeInTheDocument();
  });
});

describe('Chuông việc cần làm sau khi soát xong một đơn xin miễn', () => {
  it('đếm lại ngay chứ không đợi hết nhịp 60 giây', async () => {
    dungKho();
    let soLuotDemChuong = 0;
    server.use(
      http.get('*/admin/queue', () => {
        soLuotDemChuong += 1;
        return HttpResponse.json({
          total: 1,
          items: [
            {
              key: 'penaltyReview',
              label: 'Người chăm xin miễn phạt',
              count: 1,
              hint: 'Chưa soát thì án phạt vẫn còn hiệu lực',
            },
          ],
        });
      }),
      http.patch('*/admin/penalties/:id/review', () =>
        HttpResponse.json({ id: 'p-1', status: 'WAIVED' }),
      ),
    );

    const nguoiDung = userEvent.setup();
    renderVoiKhung(
      <MemoryRouter>
        <QueueBell />
        <PenaltiesScreen />
      </MemoryRouter>,
    );

    await waitFor(() => expect(soLuotDemChuong).toBe(1));
    await nguoiDung.click(await screen.findByRole('button', { name: 'Soát đơn' }));

    const hop = await screen.findByRole('dialog');
    fireEvent.change(within(hop).getByPlaceholderText(/Ghi rõ căn cứ/), {
      target: { value: 'Có ảnh xe hỏng, chấp nhận miễn' },
    });
    await nguoiDung.click(within(hop).getByRole('button', { name: 'Ghi kết luận' }));

    await waitFor(() => expect(soLuotDemChuong).toBe(2));
  });
});
