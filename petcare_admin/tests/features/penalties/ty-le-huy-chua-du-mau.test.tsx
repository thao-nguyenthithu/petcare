import { http, HttpResponse } from 'msw';
import { describe, expect, it } from 'vitest';
import { screen } from '@testing-library/react';
import { MemoryRouter } from 'react-router-dom';
import { PenaltiesScreen } from '@/features/penalties/screens/penalties-screen';
import { renderVoiKhung } from '@tests/support/render';
import { server } from '@tests/support/server';

function dungKho(cancelRate: number | null) {
  server.use(
    http.get('*/admin/penalties/counts', () =>
      HttpResponse.json({ pendingReview: 1, active: 0, waived: 0, hidden: 0 }),
    ),
    http.get('*/admin/penalties', () =>
      HttpResponse.json({
        total: 1,
        page: 1,
        limit: 10,
        items: [
          {
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
              cancelRate,
              warningCount: 2,
              hiddenCount: 0,
              hiddenTimesInWindow: 0,
              hiddenUntil: null,
              bannedAt: null,
            },
          },
        ],
      }),
    ),
  );
}

function ve() {
  renderVoiKhung(
    <MemoryRouter>
      <PenaltiesScreen />
    </MemoryRouter>,
  );
}

describe('Người chăm chưa đủ đơn thì tỷ lệ huỷ để trống, không đọc thành hồ sơ sạch', () => {
  it('máy chủ trả rỗng thì màn nói chưa đủ đơn chứ không hiện 0%', async () => {
    dungKho(null);
    ve();

    expect(
      await screen.findByText('Tỷ lệ huỷ chưa đủ đơn để tính · 2 cảnh cáo'),
    ).toBeInTheDocument();
    expect(screen.queryByText(/0%/)).toBeNull();
  });

  it('đủ mẫu mà tỷ lệ đúng bằng 0 thì vẫn hiện 0%, khác hẳn ca rỗng', async () => {
    dungKho(0);
    ve();

    expect(
      await screen.findByText('Tỷ lệ huỷ hiện tại 0% · 2 cảnh cáo'),
    ).toBeInTheDocument();
  });
});
