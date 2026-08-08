import { http, HttpResponse } from 'msw';
import { describe, expect, it, vi } from 'vitest';
import { fireEvent, screen, waitFor, within } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { MemoryRouter, Route, Routes } from 'react-router-dom';
import { SitterDetailScreen } from '@/features/sitters/screens/sitter-detail-screen';
import { notify } from '@/lib/toast';
import { renderVoiKhung } from '@tests/support/render';
import { server } from '@tests/support/server';

function hoSoChoDuyet(ghiDe: Record<string, unknown> = {}) {
  return {
    sitter: {
      id: 'ncc-1',
      userId: 'user-9',
      legalName: 'Trịnh Văn Nam',
      gender: 'MALE',
      dateOfBirth: '1998-04-02',
      nationalId: '001098000123',
      idIssuedPlace: 'Cục Cảnh sát',
      idIssuedDate: '2021-06-10',
      province: 'Hà Nội',
      addressDetail: 'Số 12 Giải Phóng, Đống Đa, Hà Nội',
      submittedAt: '2026-08-05T02:00:00+07:00',
      onboardedAt: null,
      serviceAddress: null,
      serviceAddressNote: null,
      serviceRadiusKm: null,
      lat: null,
      lng: null,
      status: 'PENDING',
      hiddenUntil: null,
      hiddenCount: 0,
      hiddenTimesInWindow: 0,
      bannedAt: null,
      lastSupplementRequestAt: null,
      ...ghiDe,
    },
    user: {
      fullName: 'Nam Trịnh',
      email: 'nam@example.com',
      phone: '0901234567',
      createdAt: '2026-05-01T02:00:00+07:00',
      avatarUrl: null,
    },
    documents: { frontUrl: null, backUrl: null },
    services: [],
    penalties: [],
    stats: {
      bookingCount: 0,
      cancelRate: 0,
      runningBookingCount: 0,
      ratingAvg: 0,
      totalReviews: 0,
    },
  };
}

function moMan(du = hoSoChoDuyet()) {
  server.use(
    http.get('*/admin/settings', () =>
      HttpResponse.json({ capNhatLuc: null, items: [] }),
    ),
    http.get('*/admin/sitters/:id', () => HttpResponse.json(du)),
  );
  return renderVoiKhung(
    <MemoryRouter initialEntries={['/sitter-approvals/ncc-1']}>
      <Routes>
        <Route path="/sitter-approvals/:id" element={<SitterDetailScreen />} />
      </Routes>
    </MemoryRouter>,
  );
}

describe('Yêu cầu bổ sung hồ sơ người chăm', () => {
  it('gửi đúng lý do tới lối bổ sung, không đụng lối duyệt', async () => {
    const nguoiDung = userEvent.setup();
    const daGoi: Array<{ url: string; body: unknown }> = [];
    moMan();
    server.use(
      http.post('*/admin/sitters/:id/supplement-request', async ({ request }) => {
        daGoi.push({ url: request.url, body: await request.json() });
        return HttpResponse.json({ id: 'ncc-1' });
      }),
    );

    await screen.findAllByText('Nam Trịnh');
    await nguoiDung.click(screen.getByRole('button', { name: 'Yêu cầu bổ sung' }));

    const hop = await screen.findByRole('dialog');
    fireEvent.change(within(hop).getByRole('textbox'), {
      target: { value: 'Ảnh mặt sau giấy tờ bị mờ' },
    });
    await nguoiDung.click(
      within(hop).getByRole('button', { name: 'Yêu cầu bổ sung' }),
    );

    await waitFor(() => expect(daGoi).toHaveLength(1));
    expect(daGoi[0].url).toContain('/admin/sitters/ncc-1/supplement-request');
    expect(daGoi[0].body).toEqual({ reason: 'Ảnh mặt sau giấy tờ bị mờ' });
  });

  it('chưa nhập đủ lý do thì không bấm gửi được', async () => {
    const nguoiDung = userEvent.setup();
    moMan();

    await screen.findAllByText('Nam Trịnh');
    await nguoiDung.click(screen.getByRole('button', { name: 'Yêu cầu bổ sung' }));

    const hop = await screen.findByRole('dialog');
    expect(within(hop).getByRole('button', { name: 'Yêu cầu bổ sung' })).toBeDisabled();
    fireEvent.change(within(hop).getByRole('textbox'), { target: { value: 'x' } });
    expect(within(hop).getByRole('button', { name: 'Yêu cầu bổ sung' })).toBeDisabled();
  });

  it('máy chủ từ chối thì báo đúng câu của máy chủ', async () => {
    const nguoiDung = userEvent.setup();
    moMan();
    server.use(
      http.post('*/admin/sitters/:id/supplement-request', () =>
        HttpResponse.json(
          { code: 'HO_SO_DA_XU_LY', message: 'Hồ sơ này đã được xử lý rồi' },
          { status: 400 },
        ),
      ),
    );

    await screen.findAllByText('Nam Trịnh');
    await nguoiDung.click(screen.getByRole('button', { name: 'Yêu cầu bổ sung' }));

    const hop = await screen.findByRole('dialog');
    fireEvent.change(within(hop).getByRole('textbox'), {
      target: { value: 'Thiếu ảnh mặt sau' },
    });
    const loi = vi.spyOn(notify, 'error');
    await nguoiDung.click(
      within(hop).getByRole('button', { name: 'Yêu cầu bổ sung' }),
    );

    await waitFor(() =>
      expect(loi).toHaveBeenCalledWith('Hồ sơ này đã được xử lý rồi'),
    );
    loi.mockRestore();
  });

  it('đã nhắn rồi thì card hồ sơ hiện mốc, để khỏi nhắn lại cùng một thứ', async () => {
    moMan(
      hoSoChoDuyet({ lastSupplementRequestAt: '2026-08-06T09:30:00+07:00' }),
    );

    expect(await screen.findByText('Đã nhắn bổ sung')).toBeInTheDocument();
    expect(screen.getByText('06/08/2026 · 09:30')).toBeInTheDocument();
  });

  it('chưa nhắn lần nào thì không vẽ dòng mốc rỗng', async () => {
    moMan();

    await screen.findAllByText('Nam Trịnh');
    expect(screen.queryByText('Đã nhắn bổ sung')).not.toBeInTheDocument();
  });
});

describe('Màn hồ sơ người chăm không còn nút chết', () => {
  it('mọi nút đầu trang đều mở hộp thoại thật, không nút nào chỉ hiện toast', async () => {
    const nguoiDung = userEvent.setup();
    const tin = vi.spyOn(notify, 'info');
    moMan();

    await screen.findAllByText('Nam Trịnh');
    for (const nhan of ['Yêu cầu bổ sung', 'Từ chối hồ sơ', 'Duyệt hồ sơ']) {
      await nguoiDung.click(screen.getByRole('button', { name: nhan }));
      expect(await screen.findByRole('dialog')).toBeInTheDocument();
      await nguoiDung.keyboard('{Escape}');
      await waitFor(() => expect(screen.queryByRole('dialog')).toBeNull());
    }
    expect(tin).not.toHaveBeenCalled();
    tin.mockRestore();
  });
});
