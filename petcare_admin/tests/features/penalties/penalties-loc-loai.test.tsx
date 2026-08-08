import { http, HttpResponse } from 'msw';
import { describe, expect, it } from 'vitest';
import { screen } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { MemoryRouter } from 'react-router-dom';
import { PenaltiesScreen } from '@/features/penalties/screens/penalties-screen';
import { renderVoiKhung } from '@tests/support/render';
import { server } from '@tests/support/server';

function dongPhat(ghiDe: Record<string, unknown> = {}) {
  return {
    id: 'p-1',
    sitterId: 'ncc-1',
    sitterName: 'Trịnh Văn Nam',
    kind: 'HIDE',
    status: 'ACTIVE',
    reason: 'Bỏ đơn sau khi xuất phát',
    createdAt: '2026-08-01T02:00:00.000Z',
    reviewDeadline: null,
    bookingCode: 'PC9C4RN6',
    serviceName: 'Dắt đi dạo',
    profile: {
      cancelRate: 0.1,
      hiddenCount: 1,
      hiddenTimesInWindow: 1,
      hiddenUntil: null,
      bannedAt: null,
    },
    ...ghiDe,
  };
}

function dungKho() {
  server.use(
    http.get('*/admin/penalties/counts', () =>
      HttpResponse.json({ pendingReview: 0, active: 1, waived: 0, hidden: 1 }),
    ),
    http.get('*/admin/penalties', () =>
      HttpResponse.json({ total: 1, page: 1, limit: 10, items: [dongPhat()] }),
    ),
  );
}

function moMan() {
  renderVoiKhung(
    <MemoryRouter>
      <PenaltiesScreen />
    </MemoryRouter>,
  );
}

describe('Bảng kỷ luật người chăm', () => {
  it('bản ghi tạm ẩn có nhãn tiếng Việt, không in khoá dịch ra bảng', async () => {
    dungKho();
    moMan();

    expect(await screen.findAllByText('Tạm ẩn hồ sơ')).not.toHaveLength(0);
    expect(screen.queryByText('kyLuat.loai.HIDE')).toBeNull();
  });

  it('bộ lọc loại ghi phủ đủ ba giá trị enum của máy chủ', async () => {
    dungKho();
    const nguoiDung = userEvent.setup();
    moMan();

    await screen.findAllByText('Tạm ẩn hồ sơ');
    await nguoiDung.click(screen.getByRole('button', { name: /Loại ghi/ }));

    expect(await screen.findByRole('button', { name: 'Vượt tỷ lệ huỷ' })).toBeInTheDocument();
    expect(screen.getByRole('button', { name: 'Cảnh cáo' })).toBeInTheDocument();
    expect(screen.getByRole('button', { name: 'Tạm ẩn hồ sơ' })).toBeInTheDocument();
  });
});
