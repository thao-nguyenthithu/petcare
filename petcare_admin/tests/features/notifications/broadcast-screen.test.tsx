import { http, HttpResponse } from 'msw';
import { describe, expect, it } from 'vitest';
import { screen, waitFor, within } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { BroadcastScreen } from '@/features/notifications/screens/broadcast-screen';
import { renderVoiKhung } from '@tests/support/render';
import { server } from '@tests/support/server';

const TIEU_DE = 'Bảo trì hệ thống tối 08/08';
const NOI_DUNG = 'Hệ thống tạm dừng nhận đơn mới từ 02:00 tới 03:00 ngày 08/08.';

function luot(ghiDe: Record<string, unknown> = {}) {
  return {
    id: 'cmp-1',
    title: 'Cập nhật điều khoản sử dụng từ 10/08',
    body: 'Điều khoản sử dụng được cập nhật từ ngày 10/08.',
    role: 'CHU_NUOI',
    audienceKind: 'BOTH',
    audienceValue: null,
    urgent: false,
    recipientCount: 12466,
    readCount: 5983,
    sentAt: '2026-08-05T17:05:00+07:00',
    scheduledAt: null,
    createdAt: '2026-08-05T16:40:00+07:00',
    ...ghiDe,
  };
}

// Ba lối đọc của màn, mỗi test chỉ ghi đè cái nó quan tâm
function dungKho(items: Array<Record<string, unknown>>, soNguoiNhan = 12480) {
  server.use(
    http.get('*/admin/notifications/campaigns', () =>
      HttpResponse.json({ total: items.length, page: 1, limit: 10, items }),
    ),
    http.get('*/admin/provinces', () => HttpResponse.json(['Thành phố Hà Nội'])),
    http.get('*/admin/notifications/audience', ({ request }) => {
      const url = new URL(request.url);
      return HttpResponse.json({
        kind: url.searchParams.get('kind'),
        value: url.searchParams.get('value'),
        count: soNguoiNhan,
      });
    }),
  );
}

// Dán thay vì gõ: 88 ký tự trên ô controlled là 88 lượt render, cả suite chạy chung là quá 5 giây
async function dienForm(nguoiDung: ReturnType<typeof userEvent.setup>) {
  await nguoiDung.click(screen.getByPlaceholderText(/Bảo trì hệ thống 02:00/));
  await nguoiDung.paste(TIEU_DE);
  await nguoiDung.click(screen.getByPlaceholderText(/Câu chữ gửi đi lưu cứng/));
  await nguoiDung.paste(NOI_DUNG);
}

describe('Gửi thông báo hệ thống', () => {
  it('hộp thoại xác nhận đọc đúng số người nhận máy chủ trả về', async () => {
    dungKho([luot()], 12480);
    const nguoiDung = userEvent.setup();
    renderVoiKhung(<BroadcastScreen />);

    await screen.findAllByText('Cập nhật điều khoản sử dụng từ 10/08');
    expect(await screen.findByText('Sẽ gửi tới 12.480 tài khoản')).toBeInTheDocument();

    await dienForm(nguoiDung);
    await nguoiDung.click(screen.getByRole('button', { name: 'Gửi thông báo' }));

    const hop = await screen.findByRole('dialog');
    expect(within(hop).getByText(/Tin sẽ tới 12\.480 tài khoản/)).toBeInTheDocument();
    expect(within(hop).getByText(/không thu hồi được/)).toBeInTheDocument();
    expect(within(hop).getByText(TIEU_DE)).toBeInTheDocument();
  });

  it('chưa đếm được số người nhận thì khoá nút gửi, không cho gửi mù', async () => {
    server.use(
      http.get('*/admin/notifications/campaigns', () =>
        HttpResponse.json({ total: 0, page: 1, limit: 10, items: [] }),
      ),
      http.get('*/admin/provinces', () => HttpResponse.json([])),
      http.get('*/admin/notifications/audience', () => HttpResponse.error()),
    );
    const nguoiDung = userEvent.setup();
    renderVoiKhung(<BroadcastScreen />);

    await screen.findByText(/Chưa đếm được số người nhận/);
    await dienForm(nguoiDung);
    expect(screen.getByRole('button', { name: 'Gửi thông báo' })).toBeDisabled();
  });

  it('nhóm không còn tài khoản nào thì nói rõ và khoá nút gửi', async () => {
    dungKho([], 0);
    const nguoiDung = userEvent.setup();
    renderVoiKhung(<BroadcastScreen />);

    await screen.findByText('Nhóm này chưa có tài khoản nào để nhận tin');
    await dienForm(nguoiDung);
    expect(screen.getByRole('button', { name: 'Gửi thông báo' })).toBeDisabled();
  });

  it('bấm xác nhận hai lần chỉ gửi đúng một lượt', async () => {
    dungKho([luot()], 300);
    let soLanGoi = 0;
    let than: Record<string, unknown> | null = null;
    let moKhoa: () => void = () => {};
    const cho = new Promise<void>((resolve) => {
      moKhoa = resolve;
    });
    server.use(
      http.post('*/admin/notifications/broadcast', async ({ request }) => {
        soLanGoi += 1;
        than = (await request.json()) as Record<string, unknown>;
        await cho;
        return HttpResponse.json({ id: 'cmp-9', queued: 300, scheduledAt: null });
      }),
    );

    const nguoiDung = userEvent.setup();
    renderVoiKhung(<BroadcastScreen />);
    await screen.findByText('Sẽ gửi tới 300 tài khoản');
    await dienForm(nguoiDung);
    await nguoiDung.click(screen.getByRole('button', { name: 'Gửi thông báo' }));

    const hop = await screen.findByRole('dialog');
    const nutGui = within(hop).getByRole('button', { name: 'Gửi thông báo' });
    await nguoiDung.click(nutGui);
    await waitFor(() => expect(soLanGoi).toBe(1));

    // Lượt gửi chưa xong thì nút phải khoá lại, bấm nữa không thêm lượt nào
    expect(nutGui).toBeDisabled();
    await nguoiDung.click(nutGui);
    moKhoa();

    await waitFor(() => expect(screen.queryByRole('dialog')).toBeNull());
    expect(soLanGoi).toBe(1);
    expect(than).toMatchObject({
      title: TIEU_DE,
      body: NOI_DUNG,
      audienceKind: 'BOTH',
      urgent: false,
    });
  });

  it('lượt đang hẹn giờ huỷ được, lượt đã gửi thì không', async () => {
    dungKho([
      luot({ id: 'cmp-hen', sentAt: null, scheduledAt: '2026-08-09T20:00:00+07:00' }),
      luot({ id: 'cmp-da-gui', title: 'Tin đã gửi rồi' }),
    ]);
    let daXoa = '';
    server.use(
      http.delete('*/admin/notifications/campaigns/:id', ({ params }) => {
        daXoa = String(params.id);
        return HttpResponse.json({ id: daXoa, daHuy: true });
      }),
    );

    const nguoiDung = userEvent.setup();
    renderVoiKhung(<BroadcastScreen />);
    await screen.findAllByText('Tin đã gửi rồi');

    const nutHuy = screen.getAllByRole('button', { name: 'Huỷ lượt gửi đang hẹn giờ' });
    expect(nutHuy).toHaveLength(1);

    await nguoiDung.click(nutHuy[0]);
    const hop = await screen.findByRole('dialog');
    await nguoiDung.click(within(hop).getByRole('button', { name: 'Huỷ lượt gửi' }));

    await waitFor(() => expect(daXoa).toBe('cmp-hen'));
  });

  it('lượt chưa gửi xong để trống số người nhận chứ không hiện số 0', async () => {
    dungKho([
      luot({
        sentAt: null,
        scheduledAt: '2026-08-09T20:00:00+07:00',
        recipientCount: 0,
        readCount: 0,
      }),
    ]);
    renderVoiKhung(<BroadcastScreen />);

    await screen.findByText('Hẹn giờ');
    expect(screen.getByText('Chưa có')).toBeInTheDocument();
  });
});
