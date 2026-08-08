import { http, HttpResponse } from 'msw';
import { describe, expect, it, vi } from 'vitest';
import { screen, waitFor } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import type { UserEvent } from '@testing-library/user-event';
import { OperatingParamsCard } from '@/features/settings/components/operating-params-card';
import { renderVoiKhung } from '@tests/support/render';
import { server } from '@tests/support/server';

// Giá trị thứ ba cố tình lạ: danh sách phải đến từ máy chủ chứ không chép cứng ở màn
const LUA_CHON = ['anthropic', 'gemini', 'openai'];

const TEN_THAM_SO = 'Nhà cung cấp nhận diện ảnh';

function thamSoChon(giaTri: string) {
  return {
    capNhatLuc: null,
    items: [
      {
        key: 'ai.vision.provider',
        nhan: TEN_THAM_SO,
        kieu: 'chon',
        donVi: null,
        giaTri,
        macDinh: 'anthropic',
        min: null,
        max: null,
        luaChon: LUA_CHON,
        congKhai: false,
        nguoiDoi: null,
        capNhatLuc: null,
      },
    ],
  };
}

async function moDanhSach(nguoiDung: UserEvent) {
  await nguoiDung.click(await screen.findByRole('button', { name: TEN_THAM_SO }));
}

describe('OperatingParamsCard - tham số dạng chọn', () => {
  it('dựng ô chọn đúng danh sách máy chủ trả về', async () => {
    server.use(http.get('*/admin/settings', () => HttpResponse.json(thamSoChon('anthropic'))));
    renderVoiKhung(<OperatingParamsCard />);

    await moDanhSach(userEvent.setup());

    for (const giaTri of LUA_CHON) {
      expect(screen.getByRole('button', { name: new RegExp(giaTri, 'i') })).toBeInTheDocument();
    }
  });

  it('chọn giá trị khác thì ghi ngay bằng chuỗi, không đợi nút Lưu', async () => {
    let thanGui: unknown = null;
    server.use(
      http.get('*/admin/settings', () => HttpResponse.json(thamSoChon('anthropic'))),
      http.put('*/admin/settings/:key', async ({ request, params }) => {
        thanGui = await request.json();
        return HttpResponse.json({
          key: params.key,
          giaTri: 'gemini',
          capNhatLuc: '2026-08-07T03:00:00.000Z',
        });
      }),
    );
    const nguoiDung = userEvent.setup();
    renderVoiKhung(<OperatingParamsCard />);

    await moDanhSach(nguoiDung);
    await nguoiDung.click(screen.getByRole('button', { name: /gemini/i }));

    await waitFor(() => expect(thanGui).toEqual({ giaTri: 'gemini' }));
  });

  it('chọn lại đúng giá trị đang chạy thì không gọi máy chủ', async () => {
    const daGoi = vi.fn();
    server.use(
      http.get('*/admin/settings', () => HttpResponse.json(thamSoChon('gemini'))),
      http.put('*/admin/settings/:key', () => {
        daGoi();
        return HttpResponse.json({ key: 'ai.vision.provider', giaTri: 'gemini' });
      }),
    );
    const nguoiDung = userEvent.setup();
    renderVoiKhung(<OperatingParamsCard />);

    await moDanhSach(nguoiDung);
    await nguoiDung.click(screen.getByRole('button', { name: /gemini/i }));

    await waitFor(() =>
      expect(screen.queryByRole('button', { name: /anthropic/i })).not.toBeInTheDocument(),
    );
    expect(daGoi).not.toHaveBeenCalled();
  });
});
