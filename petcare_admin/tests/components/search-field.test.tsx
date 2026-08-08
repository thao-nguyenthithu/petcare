import { describe, expect, it, vi } from 'vitest';
import { act, fireEvent, screen } from '@testing-library/react';
import { useState } from 'react';
import { SearchField } from '@/components/ui/search-field';
import { renderVoiKhung } from '@tests/support/render';

// Màn cha render lại vì lý do khác (query trả về, đổi trang) trong lúc người dùng đang gõ
function KhungCoRenderLai({ onChange }: { onChange: (value: string) => void }) {
  const [dem, setDem] = useState(0);
  return (
    <div>
      <button type="button" onClick={() => setDem(dem + 1)}>
        Render lại
      </button>
      <SearchField value="" onChange={(value) => onChange(value)} placeholder="Tìm kiếm" />
    </div>
  );
}

describe('Ô tìm kiếm có debounce', () => {
  it('màn cha render lại không làm đồng hồ debounce chạy lại từ đầu', () => {
    vi.useFakeTimers();
    const onChange = vi.fn();
    renderVoiKhung(<KhungCoRenderLai onChange={onChange} />);

    fireEvent.change(screen.getByPlaceholderText('Tìm kiếm'), { target: { value: 'nam' } });
    act(() => {
      vi.advanceTimersByTime(300);
    });
    // Cha render lại giữa chừng, hàm onChange đổi tham chiếu
    fireEvent.click(screen.getByRole('button', { name: 'Render lại' }));
    act(() => {
      vi.advanceTimersByTime(150);
    });

    expect(onChange).toHaveBeenCalledWith('nam');
    vi.useRealTimers();
  });

  it('gõ liên tiếp chỉ bắn một lượt sau khi ngừng gõ', () => {
    vi.useFakeTimers();
    const onChange = vi.fn();
    renderVoiKhung(<SearchField value="" onChange={onChange} placeholder="Tìm kiếm" />);

    const o = screen.getByPlaceholderText('Tìm kiếm');
    fireEvent.change(o, { target: { value: 'n' } });
    fireEvent.change(o, { target: { value: 'na' } });
    fireEvent.change(o, { target: { value: 'nam' } });
    act(() => {
      vi.advanceTimersByTime(400);
    });

    expect(onChange).toHaveBeenCalledTimes(1);
    expect(onChange).toHaveBeenCalledWith('nam');
    vi.useRealTimers();
  });
});
