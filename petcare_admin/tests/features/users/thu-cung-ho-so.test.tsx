import { http, HttpResponse } from 'msw';
import { describe, expect, it, vi } from 'vitest';
import { screen, waitFor } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { MemoryRouter, Route, Routes } from 'react-router-dom';
import { UserPetsScreen } from '@/features/users/screens/user-pets-screen';
import { notify } from '@/lib/toast';
import { renderVoiKhung } from '@tests/support/render';
import { server } from '@tests/support/server';

// Đủ đúng shape phần tử items của GET /admin/users/:id/pets
function be(ghiDe: Record<string, unknown> = {}) {
  return {
    id: 'pet-1',
    name: 'Mun',
    species: 'DOG',
    breed: 'Corgi',
    gender: 'MALE',
    birthDate: '2023-03-10',
    weightKg: 9.5,
    isNeutered: true,
    underTreatment: false,
    chronicDisease: null,
    medication: null,
    careNote: null,
    avatarUrl: null,
    isActive: true,
    photos: [],
    preventionCount: 1,
    ...ghiDe,
  };
}

function soPhongBenh(code: string, form: string | null = 'ORAL') {
  return {
    items: [
      {
        id: 'rec-1',
        code,
        customName: null,
        form,
        isPeriodic: true,
        doses: [
          {
            id: 'dose-1',
            doneAt: '2026-06-01',
            place: 'Thú y Hà Nội',
            nextDueAt: null,
            photos: [],
          },
        ],
      },
    ],
  };
}

function moMan(pets = [be()], so = soPhongBenh('tayGiun')) {
  server.use(
    http.get('*/admin/users/:id/pets', () => HttpResponse.json({ items: pets })),
    http.get('*/admin/pets/:id/preventions', () => HttpResponse.json(so)),
    http.get('*/admin/users/:id', () =>
      HttpResponse.json({
        user: { fullName: 'Trần Thị Hoa' },
        stats: { runningBookingCount: 0 },
      }),
    ),
  );
  return renderVoiKhung(
    <MemoryRouter initialEntries={['/users/u-1/pets']}>
      <Routes>
        <Route path="/users/:id/pets" element={<UserPetsScreen />} />
      </Routes>
    </MemoryRouter>,
  );
}

describe('Hồ sơ thú cưng hiện đủ trường của hợp đồng', () => {
  it('dòng phụ có loài bé, không chỉ có giống', async () => {
    moMan();

    expect(
      await screen.findByText('Chó · Corgi · đực · 9.5 kg · đã triệt sản'),
    ).toBeInTheDocument();
  });

  it('có ô đang điều trị, bé đang chữa thì ghi rõ', async () => {
    moMan([be({ underTreatment: true })]);

    expect(await screen.findByText('ĐANG ĐIỀU TRỊ')).toBeInTheDocument();
    expect(screen.getByText('Có')).toBeInTheDocument();
  });
});

describe('Sổ phòng bệnh không in mã kỹ thuật ra màn', () => {
  it('mã hạng mục của ứng dụng đọc ra tên tiếng Việt', async () => {
    const { container } = moMan();

    expect(await screen.findByText('Tẩy giun')).toBeInTheDocument();
    expect(container.textContent).not.toContain('tayGiun');
    expect(container.textContent).not.toContain('ORAL');
  });

  it('mã lạ rơi về nhãn chung chứ không lộ mã thô', async () => {
    const { container } = moMan([be()], soPhongBenh('ma-la-hoac-cu'));

    expect(await screen.findByText('Hạng mục khác')).toBeInTheDocument();
    expect(container.textContent).not.toContain('ma-la-hoac-cu');
  });
});

describe('Màn thú cưng không còn nút chết', () => {
  it('bỏ hẳn nút xuất hồ sơ, nút còn lại mở hộp thoại thật', async () => {
    const nguoiDung = userEvent.setup();
    const tin = vi.spyOn(notify, 'info');
    moMan();

    await screen.findByText('Tẩy giun');
    expect(screen.queryByRole('button', { name: /xuất hồ sơ/i })).not.toBeInTheDocument();

    await nguoiDung.click(screen.getByRole('button', { name: 'Ẩn hồ sơ này' }));
    expect(await screen.findByRole('dialog')).toBeInTheDocument();
    await nguoiDung.keyboard('{Escape}');
    await waitFor(() => expect(screen.queryByRole('dialog')).toBeNull());

    expect(tin).not.toHaveBeenCalled();
    tin.mockRestore();
  });
});
