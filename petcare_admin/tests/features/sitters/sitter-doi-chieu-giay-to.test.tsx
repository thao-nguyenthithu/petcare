import { describe, expect, it } from 'vitest';
import { screen } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { MemoryRouter } from 'react-router-dom';
import { GiayToCard } from '@/features/sitters/components/sitter-identity-cards';
import type { SitterDetail } from '@/features/sitters/types';
import { renderVoiKhung } from '@tests/support/render';

function hoSo(documents: SitterDetail['documents']): SitterDetail {
  return {
    documents,
  } as SitterDetail;
}

function moCard(documents: SitterDetail['documents']) {
  renderVoiKhung(
    <MemoryRouter>
      <GiayToCard data={hoSo(documents)} />
    </MemoryRouter>,
  );
}

describe('Card giấy tờ của hồ sơ người chăm', () => {
  it('mỗi mặt có ô đánh dấu đã đối chiếu, tích được từng mặt một', async () => {
    const nguoiDung = userEvent.setup();
    moCard({ frontUrl: 'https://kho.example/truoc.jpg', backUrl: 'https://kho.example/sau.jpg' });

    const o = screen.getAllByRole('checkbox', { name: 'Đã đối chiếu' });
    expect(o).toHaveLength(2);

    await nguoiDung.click(o[0]);
    expect(o[0]).toBeChecked();
    // Tích mặt trước không được kéo theo mặt sau, hai mặt soát riêng
    expect(o[1]).not.toBeChecked();
  });

  it('mặt chưa nộp ảnh thì khoá ô đánh dấu, không có gì để đối chiếu', () => {
    moCard({ frontUrl: 'https://kho.example/truoc.jpg', backUrl: null });

    const o = screen.getAllByRole('checkbox', { name: 'Đã đối chiếu' });
    expect(o[0]).toBeEnabled();
    expect(o[1]).toBeDisabled();
  });
});
