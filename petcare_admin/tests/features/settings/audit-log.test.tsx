import { http, HttpResponse } from 'msw';
import { describe, expect, it } from 'vitest';
import { screen } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { AuditLogTable } from '@/features/settings/components/audit-log-table';
import { renderVoiKhung } from '@tests/support/render';
import { server } from '@tests/support/server';

// Đúng tập mã backend đang ghi thật, không phải một danh sách dựng riêng ở màn
const MA_BACKEND_GHI = [
  'AN_HO_SO_THU_CUNG',
  'CAN_THIEP_HUY_DON',
  'CAP_NHAT_THAM_SO',
  'DUYET_HO_SO_NCC',
  'GIU_CO_GPS',
  'GIU_PHAT_NCC',
  'GO_CO_GPS',
  'GO_KHOA_HO_SO_NCC',
  'HIEN_HO_SO_THU_CUNG',
  'KET_LUAN_KHIEU_NAI',
  'KHOA_HO_SO_NCC',
  'KHOA_TAI_KHOAN',
  'MIEN_PHAT_NCC',
  'MO_KHOA_TAI_KHOAN',
  'TAM_AN_HO_SO_NCC',
  'TU_CHOI_HO_SO_NCC',
];

function dong(ghiDe: Record<string, unknown> = {}) {
  return {
    id: 'log-1',
    adminId: 'admin-1',
    adminName: 'Kendra Nguyễn',
    action: 'KET_LUAN_KHIEU_NAI',
    targetType: 'DISPUTE',
    targetId: 'hs-1',
    targetCode: 'KN-PC9C4RN6',
    reason: 'Log GPS cho thấy tới muộn 40 phút',
    oldValue: 'REVIEWING',
    newValue: 'hoan=90000|phat=WARNING',
    createdAt: '2026-08-07T03:00:00+07:00',
    ...ghiDe,
  };
}

function dungKho(items: Array<Record<string, unknown>>) {
  server.use(
    http.get('*/admin/audit-logs/filters', () =>
      HttpResponse.json({
        actions: MA_BACKEND_GHI,
        targetTypes: ['BOOKING', 'DISPUTE', 'PET', 'SETTING', 'SITTER', 'USER'],
      }),
    ),
    http.get('*/admin/audit-logs', () =>
      HttpResponse.json({ total: items.length, page: 1, limit: 10, items }),
    ),
  );
}

describe('Nhật ký thao tác', () => {
  it('mọi mã backend ghi thật đều có nhãn tiếng Việt, không hiện mã thô', async () => {
    dungKho([dong()]);
    renderVoiKhung(<AuditLogTable />);

    await screen.findByText('Kết luận khiếu nại');
    await userEvent.setup().click(screen.getByRole('button', { name: /Hành động/ }));

    for (const ma of MA_BACKEND_GHI) {
      expect(screen.queryByRole('button', { name: ma })).toBeNull();
    }
    expect(
      screen.getByRole('button', { name: 'Gỡ khoá hồ sơ người chăm' }),
    ).toBeInTheDocument();
    expect(
      screen.getByRole('button', { name: 'Ẩn hồ sơ thú cưng' }),
    ).toBeInTheDocument();
  });

  it('ô lọc chỉ bày mã đã có bản ghi, không bày mã chưa ai ghi', async () => {
    dungKho([dong()]);
    renderVoiKhung(<AuditLogTable />);

    await screen.findByText('Kết luận khiếu nại');
    await userEvent.setup().click(screen.getByRole('button', { name: /Hành động/ }));

    // Quản trị viên không duyệt ảnh check-in nên mã này không được xuất hiện
    expect(screen.queryByRole('button', { name: /Chấp nhận thủ công ảnh/ })).toBeNull();
    expect(screen.queryByRole('button', { name: /Chuyển khoản lệnh rút/ })).toBeNull();
  });

  it('loại đối tượng PET có nhãn riêng, không rơi về mã thô', async () => {
    dungKho([dong({ targetType: 'PET', targetCode: 'Mochi', action: 'AN_HO_SO_THU_CUNG' })]);
    renderVoiKhung(<AuditLogTable />);

    expect(await screen.findByText('Hồ sơ thú cưng')).toBeInTheDocument();
    expect(screen.queryByText('PET')).toBeNull();
  });
});
