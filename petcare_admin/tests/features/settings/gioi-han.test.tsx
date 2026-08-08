import { http, HttpResponse } from 'msw';
import { describe, expect, it } from 'vitest';
import { screen, within } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { MemoryRouter, Route, Routes } from 'react-router-dom';
import { LimitsScreen } from '@/features/settings/screens/limits-screen';
import { renderVoiKhung } from '@tests/support/render';
import { server } from '@tests/support/server';

// Đúng hình dạng GET /admin/limits trả về, thiếu một trường là màn ném lỗi lúc dựng
const NHOM = [
  {
    key: 'taiKhoan',
    title: 'Tài khoản và mã xác minh',
    source: 'Áp cho đăng ký, đăng nhập, xác minh email và mọi ảnh tải lên',
    cot: 'trai',
    items: [
      {
        label: 'Mật khẩu tối thiểu',
        desc: 'Áp chung cho mọi tài khoản, kể cả quản trị',
        value: '6',
        unit: 'ký tự',
      },
      {
        label: 'Phiên đăng nhập',
        desc: 'Đổi mật khẩu là mọi phiên cũ chết ngay',
        value: '30',
        unit: 'ngày',
      },
    ],
  },
  {
    key: 'kyLuat',
    title: 'Kỷ luật người chăm',
    source: 'Áp cho cảnh cáo, tạm ẩn và khoá hồ sơ người chăm',
    cot: 'phai',
    coDongDaChuyen: true,
    items: [
      {
        label: 'Thời gian tạm ẩn hồ sơ',
        desc: 'Ba bậc theo số lần bị ẩn, lần đầu là lời nhắc',
        value: '3 · 7 · 14',
        unit: 'ngày',
      },
    ],
  },
  {
    key: 'chuaCo',
    title: 'Chưa có trong code, cần thống nhất',
    source: 'Những mức chưa được thống nhất, hiện hệ thống không chặn',
    cot: 'phai',
    chuaCoTrongCode: true,
    items: [
      {
        label: 'Số địa chỉ tối đa mỗi tài khoản',
        desc: 'Lối tạo địa chỉ hiện không đếm và không chặn',
        value: 'chưa có',
        unit: '',
      },
    ],
  },
];

function dungKho(tra: () => Response) {
  let soLuot = 0;
  server.use(
    http.get('*/admin/limits', () => {
      soLuot += 1;
      return tra();
    }),
  );
  return () => soLuot;
}

function moMan() {
  renderVoiKhung(
    <MemoryRouter initialEntries={['/limits']}>
      <Routes>
        <Route path="/limits" element={<LimitsScreen />} />
        <Route path="/settings" element={<p>Man cau hinh van hanh</p>} />
      </Routes>
    </MemoryRouter>,
  );
}

describe('Màn giới hạn và hạn mức', () => {
  it('dựng hai cột theo cột máy chủ trả, không giữ danh sách khoá ở màn', async () => {
    dungKho(() => HttpResponse.json(NHOM));
    moMan();

    const tieuDeTrai = await screen.findByRole('heading', {
      name: 'Tài khoản và mã xác minh',
    });
    const cotTrai = tieuDeTrai.closest('section')!.parentElement!;
    const cotPhai = screen
      .getByRole('heading', { name: 'Kỷ luật người chăm' })
      .closest('section')!.parentElement!;

    expect(cotTrai).not.toBe(cotPhai);
    expect(within(cotTrai).getAllByRole('heading')).toHaveLength(1);
    expect(within(cotPhai).getAllByRole('heading')).toHaveLength(2);
  });

  it('hiện đủ nhãn, mô tả, giá trị và đơn vị của từng dòng', async () => {
    dungKho(() => HttpResponse.json(NHOM));
    moMan();

    await screen.findByText('Mật khẩu tối thiểu');
    expect(screen.getByText('Áp chung cho mọi tài khoản, kể cả quản trị')).toBeInTheDocument();
    expect(screen.getByText('6')).toBeInTheDocument();
    expect(screen.getByText('ký tự')).toBeInTheDocument();
    expect(screen.getByText('3 · 7 · 14')).toBeInTheDocument();
    expect(screen.getByText('chưa có')).toBeInTheDocument();
  });

  it('là bản kê CHỈ ĐỌC: không ô nhập, không nút lưu', async () => {
    dungKho(() => HttpResponse.json(NHOM));
    moMan();

    await screen.findByText('Mật khẩu tối thiểu');
    expect(screen.queryAllByRole('textbox')).toHaveLength(0);
    expect(screen.queryAllByRole('spinbutton')).toHaveLength(0);
    expect(screen.queryAllByRole('switch')).toHaveLength(0);
    expect(screen.queryByRole('button', { name: /lưu/i })).not.toBeInTheDocument();
  });

  it('chỉ nhóm từng có dòng chuyển đi mới có lối sang màn Cấu hình vận hành', async () => {
    dungKho(() => HttpResponse.json(NHOM));
    moMan();

    await screen.findByText('Mật khẩu tối thiểu');
    const loi = screen.getAllByRole('link', { name: /Xem tham số sửa được/ });
    expect(loi).toHaveLength(1);

    await userEvent.click(loi[0]);
    expect(await screen.findByText('Man cau hinh van hanh')).toBeInTheDocument();
  });

  it('máy chủ lỗi thì hiện nhánh lỗi và bấm thử lại gọi lại đúng lối đó', async () => {
    let hong = true;
    const demLuot = dungKho(() =>
      hong ? new HttpResponse(null, { status: 500 }) : HttpResponse.json(NHOM),
    );
    moMan();

    const nutThuLai = await screen.findByRole('button', { name: 'Thử lại' });
    expect(demLuot()).toBe(1);

    hong = false;
    await userEvent.click(nutThuLai);

    expect(await screen.findByText('Mật khẩu tối thiểu')).toBeInTheDocument();
    expect(demLuot()).toBe(2);
  });

  it('máy chủ trả bản kê rỗng thì nói rõ chưa có dữ liệu', async () => {
    dungKho(() => HttpResponse.json([]));
    moMan();

    expect(await screen.findByText('Chưa có dữ liệu nào')).toBeInTheDocument();
  });
});
