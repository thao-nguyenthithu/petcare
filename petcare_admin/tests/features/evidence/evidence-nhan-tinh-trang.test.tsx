import { http, HttpResponse } from 'msw';
import { describe, expect, it } from 'vitest';
import { screen } from '@testing-library/react';
import { MemoryRouter } from 'react-router-dom';
import { EvidenceScreen } from '@/features/evidence/screens/evidence-screen';
import { renderVoiKhung } from '@tests/support/render';
import { server } from '@tests/support/server';

function anh(ghiDe: Record<string, unknown> = {}) {
  return {
    id: 'anh-1',
    source: 'boarding',
    bookingCode: 'PC9C4RN6',
    serviceType: 'BOARDING',
    serviceName: 'Trông giữ tại nhà',
    url: 'https://anh.example.com/1.jpg',
    phase: null,
    takenAt: '2026-08-05T02:00:00.000Z',
    photoLat: null,
    photoLng: null,
    conditions: ['anNguTot', 'boAnMotBua'],
    anhDoDung: false,
    reportKind: null,
    aiConfidenceScore: null,
    aiPassed: null,
    anhVanXa: false,
    ...ghiDe,
  };
}

function dungKho(items: unknown[]) {
  server.use(
    http.get('*/admin/evidence/counts', () =>
      HttpResponse.json({ session: 0, boarding: items.length, noShow: 0, gpsFlagged: 0 }),
    ),
    http.get('*/admin/evidence', () =>
      HttpResponse.json({ total: items.length, page: 1, limit: 9, items }),
    ),
  );
}

function moMan() {
  renderVoiKhung(
    <MemoryRouter>
      <EvidenceScreen />
    </MemoryRouter>,
  );
}

describe('Nhãn tình trạng bé trên màn ảnh bằng chứng', () => {
  it('mã tình trạng đọc thành chữ người dùng hiểu, không in mã thô', async () => {
    dungKho([anh()]);
    moMan();

    expect(await screen.findAllByText('Ăn ngủ tốt')).not.toHaveLength(0);
    expect(screen.getAllByText('Bỏ ăn một bữa')).not.toHaveLength(0);
    expect(screen.queryByText('anNguTot')).toBeNull();
    expect(screen.queryByText('boAnMotBua')).toBeNull();
  });

  it('mã lạ rơi về ghi chú khác chứ không in nguyên văn', async () => {
    dungKho([anh({ conditions: ['maLaChuaKhai'] })]);
    moMan();

    expect(await screen.findAllByText('Ghi chú khác của người chăm')).not.toHaveLength(0);
    expect(screen.queryByText('maLaChuaKhai')).toBeNull();
  });

  it('ảnh không có pha thì không dán badge Check-in', async () => {
    dungKho([anh({ source: 'session', serviceType: 'WALKING', phase: null, conditions: [] })]);
    moMan();

    expect(await screen.findAllByText('PC9C4RN6')).not.toHaveLength(0);
    expect(screen.queryByText('Check-in')).toBeNull();
  });
});
