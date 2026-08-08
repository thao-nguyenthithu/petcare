import { http, HttpResponse } from 'msw';
import { describe, expect, it } from 'vitest';
import { fireEvent, screen, waitFor, within } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { MemoryRouter, Route, Routes } from 'react-router-dom';
import { DisputeDetailScreen } from '@/features/disputes/screens/dispute-detail-screen';
import { renderVoiKhung } from '@tests/support/render';
import { server } from '@tests/support/server';

// Mở hồ sơ 20 ngày trước nên đã quá chỉ tiêu 7 ngày
const MO_LUC_QUA_HAN = new Date(Date.now() - 20 * 24 * 3600_000).toISOString();

function hoSo(ghiDe: Record<string, unknown> = {}) {
  return {
    dispute: {
      code: 'KN-PC9C4RN6',
      bookingCode: 'PC9C4RN6',
      serviceType: 'WALKING',
      serviceName: 'Dắt đi dạo',
      status: 'REVIEWING',
      description: 'Người chăm tới muộn 40 phút',
      evidenceUrls: [],
      createdAt: MO_LUC_QUA_HAN,
      replyDeadline: null,
      sitterReply: null,
      sitterReplyAt: null,
      sitterReplyPhotos: [],
      resolution: null,
      resolutionReason: null,
      refundAmount: null,
      resolvedAt: null,
      ...ghiDe,
    },
    reporter: { id: 'user-1', fullName: 'Nguyễn Hải Yến', role: 'OWNER' },
    sitter: {
      id: 'ncc-1',
      userId: 'user-9',
      fullName: 'Trịnh Văn Nam',
      violationCount6m: 2,
    },
    booking: {
      code: 'PC9C4RN6',
      totalPrice: 180000,
      scheduledAt: '2026-08-03T17:00:00+07:00',
    },
    systemEvidence: { gps: null, photos: [] },
    sitterHistory: [],
  };
}

function dungKho(du: ReturnType<typeof hoSo>) {
  const thanGui: unknown[] = [];
  server.use(
    http.get('*/admin/disputes/:code', () => HttpResponse.json(du)),
    http.patch('*/admin/disputes/:code/resolve', async ({ request }) => {
      thanGui.push(await request.json());
      return HttpResponse.json({
        code: 'KN-PC9C4RN6',
        status: 'RESOLVED',
        refundAmount: 0,
        resolvedAt: '2026-08-07T03:00:00+07:00',
      });
    }),
  );
  return thanGui;
}

function moMan() {
  renderVoiKhung(
    <MemoryRouter initialEntries={['/disputes/KN-PC9C4RN6']}>
      <Routes>
        <Route path="/disputes/:code" element={<DisputeDetailScreen />} />
        <Route path="/disputes" element={<p>Danh sach khieu nai</p>} />
      </Routes>
    </MemoryRouter>,
  );
}

async function chonKetLuan(nguoiDung: ReturnType<typeof userEvent.setup>) {
  await nguoiDung.click(screen.getByRole('button', { name: /Chọn kết luận/ }));
  await nguoiDung.click(
    await screen.findByRole('button', { name: 'Xác nhận người chăm trễ giờ hẹn' }),
  );
}

describe('Ra kết luận cho hồ sơ khiếu nại', () => {
  it('hồ sơ quá hạn vẫn kết luận được, không thao tác nào bị khoá', async () => {
    dungKho(hoSo());
    const nguoiDung = userEvent.setup();
    moMan();

    expect(await screen.findByText(/Hồ sơ đã trễ/)).toBeInTheDocument();
    await chonKetLuan(nguoiDung);
    fireEvent.change(screen.getByRole('textbox'), {
      target: { value: 'Log GPS cho thấy tới muộn 40 phút' },
    });

    await waitFor(() =>
      expect(screen.getByRole('button', { name: 'Xác nhận xử lý' })).toBeEnabled(),
    );
  });

  it('hoàn 0 đồng vẫn bắt ghi lý do rồi mới cho chốt', async () => {
    const thanGui = dungKho(hoSo());
    const nguoiDung = userEvent.setup();
    moMan();

    await screen.findByText('Nguyễn Hải Yến');
    await chonKetLuan(nguoiDung);

    const nutChot = screen.getByRole('button', { name: 'Xác nhận xử lý' });
    expect(nutChot).toBeDisabled();

    fireEvent.change(screen.getByRole('textbox'), {
      target: { value: 'Không đủ căn cứ' },
    });
    await waitFor(() => expect(nutChot).toBeEnabled());
    await nguoiDung.click(nutChot);
    const hopThoai = within(await screen.findByRole('dialog'));
    await nguoiDung.click(
      hopThoai.getByRole('button', { name: 'Xác nhận xử lý' }),
    );

    await waitFor(() => expect(thanGui).toHaveLength(1));
    expect(thanGui[0]).toMatchObject({
      refundAmount: 0,
      resolutionReason: 'Không đủ căn cứ',
    });
  });

  it('mức tạm ẩn gửi đúng mã enum và không nhắc con số ngày nào', async () => {
    const thanGui = dungKho(hoSo());
    const nguoiDung = userEvent.setup();
    moMan();

    await screen.findByText('Nguyễn Hải Yến');
    await chonKetLuan(nguoiDung);
    await nguoiDung.click(
      screen.getByRole('radio', { name: /Tạm ẩn hồ sơ khỏi tìm kiếm/ }),
    );
    fireEvent.change(screen.getByRole('textbox'), {
      target: { value: 'Tái phạm lần hai' },
    });
    await waitFor(() =>
      expect(screen.getByRole('button', { name: 'Xác nhận xử lý' })).toBeEnabled(),
    );
    await nguoiDung.click(screen.getByRole('button', { name: 'Xác nhận xử lý' }));
    const hopThoai = within(await screen.findByRole('dialog'));
    await nguoiDung.click(
      hopThoai.getByRole('button', { name: 'Xác nhận xử lý' }),
    );

    await waitFor(() => expect(thanGui).toHaveLength(1));
    expect(thanGui[0]).toMatchObject({ penalty: 'HIDE' });
    expect(screen.queryByText(/Tạm ẩn hồ sơ 7 ngày/)).not.toBeInTheDocument();
  });

  it('hồ sơ không có lượt đáp thì nói đúng lý do, không ghi hết hạn', async () => {
    dungKho(hoSo());
    moMan();

    expect(
      await screen.findByText(/không có lượt đáp nào, xử ngay/),
    ).toBeInTheDocument();
    expect(screen.queryByText(/Hết hạn đáp, hồ sơ chuyển/)).not.toBeInTheDocument();
  });

  it('hồ sơ đã chốt chỉ hiện bản tóm tắt, không còn form nhập', async () => {
    dungKho(
      hoSo({
        status: 'RESOLVED',
        resolution: 'Xác nhận người chăm trễ giờ hẹn',
        resolutionReason: 'Log GPS cho thấy tới muộn 40 phút',
        refundAmount: 90000,
        resolvedAt: '2026-08-07T03:00:00+07:00',
      }),
    );
    moMan();

    expect(await screen.findByText(/Hồ sơ đã chốt/)).toBeInTheDocument();
    expect(screen.queryByRole('button', { name: 'Xác nhận xử lý' })).toBeNull();
  });
});
