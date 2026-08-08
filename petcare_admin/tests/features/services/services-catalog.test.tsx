import { http, HttpResponse } from 'msw';
import { describe, expect, it } from 'vitest';
import { screen, waitFor, within } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { ServicesScreen } from '@/features/services/screens/services-screen';
import { renderVoiKhung } from '@tests/support/render';
import { server } from '@tests/support/server';

// Đúng hình dạng GET /admin/services trả về, loại chưa có đơn thì ba trường đầu rỗng
const DANH_MUC = [
  {
    id: 'sv-walking',
    type: 'WALKING',
    name: 'Dắt đi dạo',
    description: 'Người chăm tới đón bé, có GPS suốt buổi',
    enabledSitterCount: 12,
  },
  {
    id: 'sv-boarding',
    type: 'BOARDING',
    name: 'Trông giữ',
    description: null,
    enabledSitterCount: 5,
  },
  {
    id: null,
    type: 'GROOMING',
    name: null,
    description: null,
    enabledSitterCount: 0,
  },
];

const RANG_BUOC = [
  { code: 'MUC_THOI_LUONG_DAT', numbers: [30, 60], keys: [] },
  { code: 'GOI_GROOMING', numbers: [], keys: ['bath', 'bathAndTrim'] },
  {
    code: 'BAC_CAN',
    numbers: [],
    keys: ['duoi5', 'tu5den10', 'tu10den20', 'tren20'],
  },
  { code: 'THOI_LUONG_GROOMING', numbers: [30, 240, 15], keys: [] },
];

function dungKho() {
  server.use(
    http.get('*/admin/services', () => HttpResponse.json({ items: DANH_MUC })),
    http.get('*/admin/service-constraints', () => HttpResponse.json({ items: RANG_BUOC })),
    http.get('*/admin/sitter-services', () =>
      HttpResponse.json({ total: 0, page: 1, limit: 8, items: [] }),
    ),
  );
}

describe('Tab danh mục dịch vụ', () => {
  it('hiện đủ ba loại, loại chưa có dòng danh mục vẫn có tên chuẩn', async () => {
    dungKho();
    renderVoiKhung(<ServicesScreen />);

    await screen.findByText('Dắt đi dạo');
    expect(screen.getByText('Trông giữ')).toBeInTheDocument();
    expect(screen.getByText('Tắm và cắt tỉa')).toBeInTheDocument();
    expect(screen.getByText('12')).toBeInTheDocument();
  });

  it('không còn cột giá tham khảo và cột thời lượng trên bảng danh mục', async () => {
    dungKho();
    renderVoiKhung(<ServicesScreen />);

    await screen.findByText('Dắt đi dạo');
    expect(screen.queryByText('GIÁ THAM KHẢO')).toBeNull();
    expect(screen.queryByText('THỜI LƯỢNG')).toBeNull();
    expect(screen.queryByText(/ENUM/i)).toBeNull();
  });

  it('mô tả rỗng hiện chữ xám Chưa có chứ không để trống hay dấu gạch', async () => {
    dungKho();
    const { container } = renderVoiKhung(<ServicesScreen />);

    await screen.findByText('Dắt đi dạo');
    expect(screen.getAllByText('Chưa có').length).toBeGreaterThan(0);
    expect(container.textContent).not.toContain('—');
  });

  it('hộp thoại sửa chỉ có tên và mô tả, gửi đúng hai trường đó', async () => {
    dungKho();
    let than: Record<string, unknown> | null = null;
    let duongDan = '';
    server.use(
      http.put('*/admin/services/:type', async ({ request, params }) => {
        duongDan = String(params.type);
        than = (await request.json()) as Record<string, unknown>;
        return HttpResponse.json({
          id: 'sv-walking',
          type: duongDan,
          name: 'Dắt chó đi dạo',
          description: 'Có GPS suốt buổi',
          enabledSitterCount: 12,
        });
      }),
    );

    const nguoiDung = userEvent.setup();
    renderVoiKhung(<ServicesScreen />);
    await screen.findByText('Dắt đi dạo');
    await nguoiDung.click(screen.getAllByRole('button', { name: 'Sửa loại dịch vụ' })[0]);

    const hop = await screen.findByRole('dialog');
    expect(within(hop).queryByText(/giá/i)).not.toBeNull();
    expect(within(hop).queryByRole('textbox', { name: /basePricePerHour/i })).toBeNull();
    expect(within(hop).queryByPlaceholderText(/tính theo đêm/i)).toBeNull();
    expect(within(hop).getAllByRole('textbox')).toHaveLength(2);

    const oTen = within(hop).getAllByRole('textbox')[0];
    await nguoiDung.clear(oTen);
    await nguoiDung.type(oTen, 'Dắt chó đi dạo');
    await nguoiDung.click(within(hop).getByRole('button', { name: 'Lưu thay đổi' }));

    await waitFor(() => expect(than).not.toBeNull());
    expect(duongDan).toBe('WALKING');
    expect(than).toEqual({
      name: 'Dắt chó đi dạo',
      description: 'Người chăm tới đón bé, có GPS suốt buổi',
    });
  });

  it('tên ngắn dưới hai ký tự thì khoá nút lưu', async () => {
    dungKho();
    const nguoiDung = userEvent.setup();
    renderVoiKhung(<ServicesScreen />);

    await screen.findByText('Dắt đi dạo');
    await nguoiDung.click(screen.getAllByRole('button', { name: 'Sửa loại dịch vụ' })[0]);

    const hop = await screen.findByRole('dialog');
    const oTen = within(hop).getAllByRole('textbox')[0];
    await nguoiDung.clear(oTen);
    await nguoiDung.type(oTen, 'D');
    expect(within(hop).getByRole('button', { name: 'Lưu thay đổi' })).toBeDisabled();
  });
});

describe('Tab ràng buộc trong code', () => {
  it('hiện nhãn tiếng Việt và số lấy từ máy chủ, không hiện tên hằng số hay tên file', async () => {
    dungKho();
    const nguoiDung = userEvent.setup();
    renderVoiKhung(<ServicesScreen />);

    await screen.findByText('Dắt đi dạo');
    await nguoiDung.click(screen.getByRole('button', { name: /^Ràng buộc trong code/ }));

    expect(await screen.findByText('Mức thời lượng một lượt dắt')).toBeInTheDocument();
    expect(screen.getByText('30 · 60 phút')).toBeInTheDocument();
    expect(screen.getByText('Tắm · Tắm và cắt tỉa')).toBeInTheDocument();
    expect(screen.getByText('30 đến 240 phút, bước 15 phút')).toBeInTheDocument();
    expect(screen.queryByText(/WALKING_DURATIONS|GROOMING_PHUT|sitter-services/)).toBeNull();
    expect(screen.queryByText('NƠI KHAI BÁO')).toBeNull();
  });
});
