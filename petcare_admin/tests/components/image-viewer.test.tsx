import { describe, expect, it } from 'vitest';
import { fireEvent, screen, waitFor, within } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { ImageViewer } from '@/components/ui/image-viewer';
import { useImageViewer, type AnhXem } from '@/components/ui/use-image-viewer';
import { renderVoiKhung } from '@tests/support/render';

const BA_ANH: AnhXem[] = [
  { url: 'https://kho.test/a.jpg', nhan: 'Ảnh một' },
  { url: 'https://kho.test/b.jpg', nhan: 'Ảnh hai' },
  { url: 'https://kho.test/c.jpg', nhan: 'Ảnh ba' },
];

// Màn giả tối thiểu: vài ô ảnh bấm được, đúng cách mọi màn thật đang dùng
function ManGia({ anh = BA_ANH }: { anh?: AnhXem[] }) {
  const xem = useImageViewer();
  return (
    <div>
      {anh.map((item, viTri) => (
        <button key={item.url} type="button" onClick={() => xem.mo(viTri)}>
          {item.nhan}
        </button>
      ))}
      <ImageViewer anh={anh} moTai={xem.moTai} onDong={xem.dong} />
    </div>
  );
}

async function moAnhDau() {
  const nguoiDung = userEvent.setup();
  renderVoiKhung(<ManGia />);
  await nguoiDung.click(screen.getByRole('button', { name: 'Ảnh một' }));
  const hop = await screen.findByRole('dialog');
  return { nguoiDung, hop };
}

describe('Trình xem ảnh dùng chung', () => {
  it('chưa bấm thì không có lớp xem ảnh nào che màn', () => {
    renderVoiKhung(<ManGia />);

    expect(screen.queryByRole('dialog')).toBeNull();
  });

  it('bấm vào ảnh thì mở đúng ảnh đó kèm vị trí trong bộ', async () => {
    const nguoiDung = userEvent.setup();
    renderVoiKhung(<ManGia />);

    await nguoiDung.click(screen.getByRole('button', { name: 'Ảnh hai' }));

    const hop = await screen.findByRole('dialog');
    expect(within(hop).getByText('Ảnh 2 trên 3')).toBeInTheDocument();
    expect(within(hop).getByRole('img')).toHaveAttribute('src', BA_ANH[1].url);
  });

  it('phóng to thu nhỏ bằng nút và kẹp lại ở hai đầu', async () => {
    const { nguoiDung, hop } = await moAnhDau();
    const trong = within(hop);

    expect(trong.getByText('100%')).toBeInTheDocument();
    // Đang ở cỡ gốc thì không thu nhỏ thêm được nữa
    expect(trong.getByRole('button', { name: 'Thu nhỏ' })).toBeDisabled();

    await nguoiDung.click(trong.getByRole('button', { name: 'Phóng to' }));
    expect(trong.getByText('150%')).toBeInTheDocument();

    // Từ 150% cần năm bước nữa mới chạm trần 400%
    const nutPhong = trong.getByRole('button', { name: 'Phóng to' });
    for (let lan = 0; lan < 5; lan += 1) await nguoiDung.click(nutPhong);

    expect(trong.getByText('400%')).toBeInTheDocument();
    expect(nutPhong).toBeDisabled();
  });

  it('cuộn chuột cũng đổi được cỡ ảnh', async () => {
    const { hop } = await moAnhDau();
    const trong = within(hop);

    fireEvent.wheel(trong.getByRole('img'), { deltaY: -100 });

    await waitFor(() => expect(trong.getByText('125%')).toBeInTheDocument());
  });

  it('phím cộng trừ đổi cỡ, phím số không đưa về cỡ gốc', async () => {
    const { hop } = await moAnhDau();
    const trong = within(hop);

    fireEvent.keyDown(hop, { key: '+' });
    expect(trong.getByText('150%')).toBeInTheDocument();

    fireEvent.keyDown(hop, { key: '-' });
    expect(trong.getByText('100%')).toBeInTheDocument();

    fireEvent.keyDown(hop, { key: '+' });
    fireEvent.keyDown(hop, { key: '0' });
    expect(trong.getByText('100%')).toBeInTheDocument();
  });

  it('lướt bằng nút và bằng phím mũi tên, hết bộ thì quay vòng', async () => {
    const { nguoiDung, hop } = await moAnhDau();
    const trong = within(hop);

    await nguoiDung.click(trong.getByRole('button', { name: 'Ảnh sau' }));
    expect(trong.getByRole('img')).toHaveAttribute('src', BA_ANH[1].url);

    fireEvent.keyDown(hop, { key: 'ArrowRight' });
    expect(trong.getByRole('img')).toHaveAttribute('src', BA_ANH[2].url);

    fireEvent.keyDown(hop, { key: 'ArrowRight' });
    expect(trong.getByRole('img')).toHaveAttribute('src', BA_ANH[0].url);

    fireEvent.keyDown(hop, { key: 'ArrowLeft' });
    expect(trong.getByRole('img')).toHaveAttribute('src', BA_ANH[2].url);
  });

  it('đổi ảnh thì cỡ zoom về gốc, không để ảnh sau mở ra đã phóng lệch', async () => {
    const { hop } = await moAnhDau();
    const trong = within(hop);

    fireEvent.keyDown(hop, { key: '+' });
    expect(trong.getByText('150%')).toBeInTheDocument();

    fireEvent.keyDown(hop, { key: 'ArrowRight' });

    expect(trong.getByText('100%')).toBeInTheDocument();
    expect(trong.getByRole('img').getAttribute('style')).toContain('scale(1)');
  });

  it('chỉ một ảnh thì ẩn hẳn hai nút lướt chứ không để nút bấm không ăn', async () => {
    const nguoiDung = userEvent.setup();
    renderVoiKhung(<ManGia anh={[BA_ANH[0]]} />);

    await nguoiDung.click(screen.getByRole('button', { name: 'Ảnh một' }));
    const hop = await screen.findByRole('dialog');

    expect(within(hop).queryByRole('button', { name: 'Ảnh sau' })).toBeNull();
    expect(within(hop).queryByRole('button', { name: 'Ảnh trước' })).toBeNull();
  });

  it('đóng được bằng nút X', async () => {
    const { nguoiDung, hop } = await moAnhDau();

    await nguoiDung.click(
      within(hop).getByRole('button', { name: 'Đóng chế độ xem ảnh' }),
    );

    await waitFor(() => expect(screen.queryByRole('dialog')).toBeNull());
  });

  it('đóng được bằng phím Esc', async () => {
    const { hop } = await moAnhDau();

    fireEvent.keyDown(hop, { key: 'Escape' });

    await waitFor(() => expect(screen.queryByRole('dialog')).toBeNull());
  });

  it('mở lại sau khi đóng thì bắt đầu từ cỡ gốc', async () => {
    const { nguoiDung, hop } = await moAnhDau();
    fireEvent.keyDown(hop, { key: '+' });
    await nguoiDung.click(
      within(hop).getByRole('button', { name: 'Đóng chế độ xem ảnh' }),
    );
    await waitFor(() => expect(screen.queryByRole('dialog')).toBeNull());

    await nguoiDung.click(screen.getByRole('button', { name: 'Ảnh một' }));

    const lanHai = await screen.findByRole('dialog');
    expect(within(lanHai).getByText('100%')).toBeInTheDocument();
  });
});
