import { describe, expect, it } from 'vitest';
import { screen } from '@testing-library/react';
import { MemoryRouter } from 'react-router-dom';
import { QueueList } from '@/features/dashboard/components/queue-list';
import type { QueueItem } from '@/features/dashboard/types';
import { renderVoiKhung } from '@tests/support/render';

// Máy chủ thêm khoá việc mới trước khi web build lại là chuyện bình thường
const KHOA_LA = { key: 'somethingNew', label: 'Việc mới', count: 3, hint: 'Chưa có màn' };

function moKhoiViec(items: unknown[]) {
  renderVoiKhung(
    <MemoryRouter>
      <QueueList items={items as QueueItem[]} />
    </MemoryRouter>,
  );
}

describe('Chương việc cần làm', () => {
  it('khoá lạ bị bỏ qua chứ không hạ cả khối', () => {
    moKhoiViec([
      { key: 'sitterPending', label: 'Hồ sơ chờ duyệt', count: 2, hint: 'Chờ soát' },
      KHOA_LA,
    ]);

    expect(screen.getByText('Hồ sơ chờ duyệt')).toBeInTheDocument();
    expect(screen.queryByText('Việc mới')).toBeNull();
  });

  it('bốn khoá máy chủ đang dùng đều dẫn được sang màn tương ứng', () => {
    moKhoiViec([
      { key: 'sitterPending', label: 'Hồ sơ chờ duyệt', count: 1, hint: 'a' },
      { key: 'disputeReview', label: 'Khiếu nại chờ xử lý', count: 2, hint: 'b' },
      { key: 'withdrawalPending', label: 'Lệnh rút chờ chuyển', count: 3, hint: 'c' },
      { key: 'penaltyReview', label: 'Ghi kỷ luật chờ soát', count: 4, hint: 'd' },
    ]);

    expect(screen.getAllByRole('link')).toHaveLength(4);
  });
});
