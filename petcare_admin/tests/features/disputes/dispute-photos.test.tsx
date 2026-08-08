import { http, HttpResponse } from 'msw';
import { describe, expect, it } from 'vitest';
import { screen, within } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { MemoryRouter, Route, Routes } from 'react-router-dom';
import { DisputeDetailScreen } from '@/features/disputes/screens/dispute-detail-screen';
import { renderVoiKhung } from '@tests/support/render';
import { server } from '@tests/support/server';

const ANH_CHU_NUOI = 'https://kho.test/chu-nuoi-1.jpg';
const ANH_NGUOI_CHAM = 'https://kho.test/nguoi-cham-1.jpg';
const ANH_HE_THONG = 'https://kho.test/he-thong-1.jpg';

function hoSo() {
  return {
    dispute: {
      code: 'KN-PC9C4RN6',
      bookingCode: 'PC9C4RN6',
      serviceType: 'WALKING',
      serviceName: 'Dắt đi dạo',
      status: 'REVIEWING',
      description: 'Người chăm tới muộn 40 phút',
      evidenceUrls: [ANH_CHU_NUOI],
      createdAt: '2026-08-06T02:00:00+07:00',
      replyDeadline: '2026-08-07T02:00:00+07:00',
      sitterReply: 'Tôi kẹt xe ở hầm Thủ Thiêm',
      sitterReplyAt: '2026-08-06T05:00:00+07:00',
      sitterReplyPhotos: [ANH_NGUOI_CHAM],
      resolution: null,
      resolutionReason: null,
      refundAmount: null,
      resolvedAt: null,
    },
    reporter: { id: 'user-1', fullName: 'Nguyễn Hải Yến', role: 'OWNER' },
    sitter: {
      id: 'ncc-1',
      userId: 'user-9',
      fullName: 'Trịnh Văn Nam',
      violationCount6m: 0,
    },
    booking: {
      code: 'PC9C4RN6',
      totalPrice: 180000,
      scheduledAt: '2026-08-03T17:00:00+07:00',
    },
    systemEvidence: {
      gps: { distanceFromMeetingM: 120, note: null },
      photos: [
        {
          url: ANH_HE_THONG,
          takenAt: '2026-08-03T17:05:00+07:00',
          lat: 10.77,
          lng: 106.7,
        },
      ],
    },
    sitterHistory: [],
  };
}

function moMan() {
  server.use(http.get('*/admin/disputes/:code', () => HttpResponse.json(hoSo())));
  return renderVoiKhung(
    <MemoryRouter initialEntries={['/disputes/KN-PC9C4RN6']}>
      <Routes>
        <Route path="/disputes/:code" element={<DisputeDetailScreen />} />
      </Routes>
    </MemoryRouter>,
  );
}

describe('Ảnh trong hồ sơ khiếu nại', () => {
  it('ba bộ ảnh đều vẽ ảnh thật chứ không còn ô giữ chỗ', async () => {
    const { container } = moMan();

    await screen.findByText('Nguyễn Hải Yến');
    const nguon = Array.from(container.querySelectorAll('img')).map((anh) =>
      anh.getAttribute('src'),
    );

    expect(nguon).toContain(ANH_CHU_NUOI);
    expect(nguon).toContain(ANH_NGUOI_CHAM);
    expect(nguon).toContain(ANH_HE_THONG);
  });

  it('bấm ảnh thì mở lớp xem ảnh, đúng ảnh vừa bấm và ở cỡ gốc', async () => {
    const nguoiDung = userEvent.setup();
    moMan();

    await screen.findByText('Nguyễn Hải Yến');
    const oAnh = screen.getAllByRole('button', { name: 'Mở ảnh để xem lớn' });
    await nguoiDung.click(oAnh[0]);

    const hop = await screen.findByRole('dialog');
    expect(
      within(hop).getByRole('button', { name: 'Đóng chế độ xem ảnh' }),
    ).toBeInTheDocument();
    expect(within(hop).getByText('100%')).toBeInTheDocument();
    expect(within(hop).getByRole('img')).toHaveAttribute('src', ANH_CHU_NUOI);
  });

  it('mỗi bộ chỉ có một ảnh nên lớp xem ảnh không bày nút lướt', async () => {
    const nguoiDung = userEvent.setup();
    moMan();

    await screen.findByText('Nguyễn Hải Yến');
    await nguoiDung.click(
      screen.getAllByRole('button', { name: 'Mở ảnh để xem lớn' })[0],
    );

    const hop = await screen.findByRole('dialog');
    expect(within(hop).queryByRole('button', { name: 'Ảnh sau' })).toBeNull();
  });
});
