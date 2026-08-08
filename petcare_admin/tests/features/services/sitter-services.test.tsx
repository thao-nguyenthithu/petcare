import { http, HttpResponse } from 'msw';
import { describe, expect, it, vi } from 'vitest';
import { screen, waitFor, within } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { ServicesScreen } from '@/features/services/screens/services-screen';
import { notify } from '@/lib/toast';
import { renderVoiKhung } from '@tests/support/render';
import { server } from '@tests/support/server';

// Ba hình dạng pricing đúng như GET /admin/sitter-services trả về
const DONG_DAT = {
  id: 'ss-1',
  sitterId: 'ncc-1',
  sitterName: 'Đặng Khắc Duy',
  type: 'WALKING',
  enabled: true,
  petKind: 'DOG',
  pricing: {
    type: 'WALKING',
    priceByDuration: { '30': 100000, '60': 160000 },
    additionalPetFee: 40000,
    maxPets: 3,
  },
  updatedAt: '2026-08-02T09:00:00+07:00',
};

const DONG_TRONG_GIU = {
  id: 'ss-2',
  sitterId: 'ncc-2',
  sitterName: 'Lý Mai Phương',
  type: 'BOARDING',
  enabled: false,
  petKind: 'CAT',
  pricing: {
    type: 'BOARDING',
    pricePerDay: 280000,
    capacity: 6,
    additionalPetFee: null,
    maxPets: null,
  },
  updatedAt: '2026-07-28T09:00:00+07:00',
};

const DONG_GROOMING = {
  id: 'ss-3',
  sitterId: 'ncc-3',
  sitterName: 'Hoàng Thị Nga',
  type: 'GROOMING',
  enabled: true,
  petKind: 'BOTH',
  pricing: {
    type: 'GROOMING',
    priceByPackage: { bath: { duoi5: 180000, tu5den10: 240000 } },
    durationByPackage: { bath: { duoi5: 60, tu5den10: 75 } },
    maxPets: 2,
  },
  updatedAt: '2026-08-01T09:00:00+07:00',
};

function dungKho(items: Array<Record<string, unknown>>) {
  const duongDan: string[] = [];
  server.use(
    http.get('*/admin/services', () => HttpResponse.json({ items: [] })),
    http.get('*/admin/service-constraints', () => HttpResponse.json({ items: [] })),
    http.get('*/admin/sitter-services', ({ request }) => {
      duongDan.push(new URL(request.url).search);
      return HttpResponse.json({ total: items.length, page: 1, limit: 8, items });
    }),
  );
  return duongDan;
}

async function moTabCauHinh() {
  const nguoiDung = userEvent.setup();
  renderVoiKhung(<ServicesScreen />);
  await nguoiDung.click(screen.getByRole('button', { name: /^Cấu hình của người chăm/ }));
  return nguoiDung;
}

describe('Bảng cấu hình giá của người chăm', () => {
  it('bảng giá ba dịch vụ đọc ra tiếng Việt kèm tiền có dấu chấm', async () => {
    dungKho([DONG_DAT, DONG_TRONG_GIU, DONG_GROOMING]);
    await moTabCauHinh();

    await screen.findByText('Đặng Khắc Duy');
    expect(
      screen.getByText('30 phút 100.000 đ · 60 phút 160.000 đ · thêm bé 40.000 đ'),
    ).toBeInTheDocument();
    expect(
      screen.getByText('280.000 đ mỗi đêm · nhận tối đa 6 bé mỗi ngày'),
    ).toBeInTheDocument();
    expect(
      screen.getByText('Tắm: dưới 5 kg 180.000 đ, 5 đến 10 kg 240.000 đ'),
    ).toBeInTheDocument();
  });

  it('chưa khai số bé tối đa thì hiện Chưa có chứ không hiện số 0', async () => {
    dungKho([DONG_TRONG_GIU]);
    await moTabCauHinh();

    await screen.findByText('Lý Mai Phương');
    expect(screen.getByText('Chưa có')).toBeInTheDocument();
  });

  it('không có nút xuất tệp giả trên thanh lọc', async () => {
    dungKho([DONG_DAT]);
    await moTabCauHinh();

    await screen.findByText('Đặng Khắc Duy');
    expect(screen.queryByRole('button', { name: /xuất/i })).toBeNull();
  });

  it('lọc theo loại dịch vụ và trạng thái thì gửi đúng tham số lên máy chủ', async () => {
    const duongDan = dungKho([DONG_DAT]);
    const nguoiDung = await moTabCauHinh();

    await screen.findByText('Đặng Khắc Duy');
    await nguoiDung.click(screen.getByRole('button', { name: 'Trạng thái bật' }));
    await nguoiDung.click(await screen.findByRole('button', { name: 'Đang tắt' }));

    await waitFor(() => expect(duongDan[duongDan.length - 1]).toContain('enabled=false'));
    expect(duongDan[duongDan.length - 1]).toContain('page=1');
  });

  it('khoá một cấu hình bắt nhập lý do rồi gửi đúng thân yêu cầu', async () => {
    dungKho([DONG_DAT]);
    let than: Record<string, unknown> | null = null;
    let duongDan = '';
    server.use(
      http.patch('*/admin/sitter-services/:id/enabled', async ({ request, params }) => {
        duongDan = String(params.id);
        than = (await request.json()) as Record<string, unknown>;
        return HttpResponse.json({ id: duongDan, enabled: false });
      }),
    );

    const nguoiDung = await moTabCauHinh();
    await screen.findByText('Đặng Khắc Duy');
    await nguoiDung.click(screen.getByRole('button', { name: 'Khoá cấu hình này' }));

    const hop = await screen.findByRole('dialog');
    const nutKhoa = within(hop).getByRole('button', { name: 'Khoá cấu hình' });
    expect(nutKhoa).toBeDisabled();

    await nguoiDung.type(within(hop).getByRole('textbox'), 'Bảng giá sai mức 60 phút');
    expect(nutKhoa).toBeEnabled();
    await nguoiDung.click(nutKhoa);

    await waitFor(() => expect(than).not.toBeNull());
    expect(duongDan).toBe('ss-1');
    expect(than).toEqual({ enabled: false, reason: 'Bảng giá sai mức 60 phút' });
  });

  it('máy chủ chặn mở lại vì bảng giá thiếu thì hiện đúng câu báo của máy chủ', async () => {
    dungKho([DONG_TRONG_GIU]);
    server.use(
      http.patch('*/admin/sitter-services/:id/enabled', () =>
        HttpResponse.json(
          {
            code: 'BANG_GIA_CHUA_DU',
            message: 'Bảng giá chưa khai số bé tối đa mỗi đơn',
          },
          { status: 400 },
        ),
      ),
    );

    const bao = vi.spyOn(notify, 'error');
    const nguoiDung = await moTabCauHinh();
    await screen.findByText('Lý Mai Phương');
    await nguoiDung.click(screen.getByRole('button', { name: 'Mở lại cấu hình này' }));

    const hop = await screen.findByRole('dialog');
    await nguoiDung.type(within(hop).getByRole('textbox'), 'Người chăm báo đã sửa');
    await nguoiDung.click(within(hop).getByRole('button', { name: 'Mở lại' }));

    await waitFor(() =>
      expect(bao).toHaveBeenCalledWith('Bảng giá chưa khai số bé tối đa mỗi đơn'),
    );
    // Hộp thoại phải ở lại để người dùng đọc được lý do và bấm huỷ
    expect(screen.getByRole('dialog')).toBeInTheDocument();
  });
});
