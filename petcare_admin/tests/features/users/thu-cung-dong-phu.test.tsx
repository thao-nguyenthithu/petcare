import { http, HttpResponse } from 'msw';
import { describe, expect, it } from 'vitest';
import { screen } from '@testing-library/react';
import { MemoryRouter, Route, Routes } from 'react-router-dom';
import { UserPetsScreen } from '@/features/users/screens/user-pets-screen';
import { renderVoiKhung } from '@tests/support/render';
import { server } from '@tests/support/server';

// Lùi xa mốc tròn năm để phép quy đổi tháng không rơi đúng ranh giới lúc chạy test
const NAM_TRUOC = new Date(Date.now() - 1278 * 24 * 3600_000).toISOString();

function be(ghiDe: Record<string, unknown> = {}) {
  return {
    id: 'pet-1',
    name: 'Mochi',
    species: 'DOG',
    breed: 'Corgi',
    gender: 'MALE',
    birthDate: NAM_TRUOC,
    weightKg: 9.5,
    isNeutered: true,
    underTreatment: false,
    chronicDisease: null,
    medication: null,
    careNote: null,
    avatarUrl: null,
    isActive: true,
    photos: [],
    preventionCount: 2,
    ...ghiDe,
  };
}

function moMan(items: Array<Record<string, unknown>>) {
  server.use(
    http.get('*/admin/users/:id/pets', () => HttpResponse.json({ items })),
    http.get('*/admin/users/:id', () =>
      HttpResponse.json({
        user: { id: 'u-1', fullName: 'Trần Thị Hoa' },
      }),
    ),
    http.get('*/admin/pets/:id/preventions', () => HttpResponse.json({ items: [] })),
  );
  return renderVoiKhung(
    <MemoryRouter initialEntries={['/users/u-1/pets']}>
      <Routes>
        <Route path="/users/:id/pets" element={<UserPetsScreen />} />
      </Routes>
    </MemoryRouter>,
  );
}

describe('Danh sách bé của một chủ nuôi', () => {
  it('dòng phụ đủ bốn mảnh giống, giới tính, tuổi và cân nặng', async () => {
    moMan([be()]);

    expect(await screen.findByText(/^Corgi · đực · \d+ tuổi · 9\.5 kg$/)).toBeInTheDocument();
  });

  it('bé nhiều hơn sáu ảnh thì lưới nới ra chứ không nuốt mất ảnh cuối', async () => {
    const photos = Array.from({ length: 9 }, (_, i) => ({
      id: `anh-${i}`,
      url: `https://kho.example/anh-${i}.jpg`,
      sortOrder: i,
    }));
    moMan([be({ photos })]);

    await screen.findAllByText(/Corgi/);
    const nut = await screen.findAllByRole('button', { name: 'Mở ảnh để xem lớn' });
    expect(nut).toHaveLength(photos.length);
  });
});
