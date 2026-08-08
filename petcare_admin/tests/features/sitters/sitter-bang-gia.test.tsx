import { http, HttpResponse } from 'msw';
import { describe, expect, it } from 'vitest';
import { screen } from '@testing-library/react';
import { MemoryRouter, Route, Routes } from 'react-router-dom';
import { SitterDetailScreen } from '@/features/sitters/screens/sitter-detail-screen';
import { renderVoiKhung } from '@tests/support/render';
import { server } from '@tests/support/server';

// Đúng hình dạng GET /admin/sitters/:id trả về sau doiBangGia: pricing là hợp phân biệt theo type
function hoSo(services: unknown[], ghiDeSitter: Record<string, unknown> = {}) {
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
      submittedAt: '2026-07-20T02:00:00+07:00',
      onboardedAt: '2026-07-22T02:00:00+07:00',
      serviceAddress: 'Số 12 Giải Phóng, Đống Đa, Hà Nội',
      serviceAddressNote: null,
      serviceRadiusKm: 8,
      lat: 21.0025,
      lng: 105.8412,
      status: 'APPROVED',
      hiddenUntil: null,
      hiddenCount: 0,
      hiddenTimesInWindow: 1,
      bannedAt: null,
      lastSupplementRequestAt: null,
      ...ghiDeSitter,
    },
    user: {
      fullName: 'Nam Trịnh',
      email: 'nam@example.com',
      phone: '0901234567',
      createdAt: '2026-05-01T02:00:00+07:00',
      avatarUrl: null,
    },
    documents: { frontUrl: null, backUrl: null },
    services,
    penalties: [],
    stats: {
      bookingCount: 12,
      cancelRate: 0.05,
      runningBookingCount: 0,
      ratingAvg: 4.8,
      totalReviews: 20,
    },
  };
}

function dungKho(du: unknown) {
  server.use(http.get('*/admin/sitters/:id', () => HttpResponse.json(du)));
}

function moMan() {
  renderVoiKhung(
    <MemoryRouter initialEntries={['/sitter-approvals/ncc-1']}>
      <Routes>
        <Route path="/sitter-approvals/:id" element={<SitterDetailScreen />} />
      </Routes>
    </MemoryRouter>,
  );
}

describe('Bảng giá trên hồ sơ người chăm', () => {
  it('trông giữ hiện giá mỗi đêm và sức chứa của chính nhánh BOARDING', async () => {
    dungKho(
      hoSo([
        {
          type: 'BOARDING',
          enabled: true,
          petKind: 'DOG',
          pricing: {
            type: 'BOARDING',
            pricePerDay: 250000,
            capacity: 3,
            additionalPetFee: 50000,
            maxPets: 2,
          },
        },
      ]),
    );
    moMan();

    expect(await screen.findByText('Một đêm')).toBeInTheDocument();
    expect(screen.getByText('250.000 đ')).toBeInTheDocument();
    expect(screen.getByText('Sức chứa mỗi ngày')).toBeInTheDocument();
    expect(screen.getByText('3 thú cưng')).toBeInTheDocument();
    expect(screen.getByText('Mỗi thú cưng thêm')).toBeInTheDocument();
  });

  it('dắt đi dạo hiện từng mức thời lượng, không hiện dòng của loại khác', async () => {
    dungKho(
      hoSo([
        {
          type: 'WALKING',
          enabled: true,
          petKind: 'DOG',
          pricing: {
            type: 'WALKING',
            priceByDuration: { '30': 100000, '60': 160000 },
            additionalPetFee: 40000,
            maxPets: 2,
          },
        },
      ]),
    );
    moMan();

    expect(await screen.findByText('Gói 30 phút')).toBeInTheDocument();
    expect(screen.getByText('100.000 đ')).toBeInTheDocument();
    expect(screen.getByText('Gói 60 phút')).toBeInTheDocument();
    expect(screen.queryByText('Một đêm')).toBeNull();
    expect(screen.queryByText('Sức chứa mỗi ngày')).toBeNull();
  });

  it('grooming ghép thời lượng vào ô giá, không hiện NaN đ', async () => {
    dungKho(
      hoSo([
        {
          type: 'GROOMING',
          enabled: true,
          petKind: 'BOTH',
          pricing: {
            type: 'GROOMING',
            priceByPackage: {
              bath: { duoi5: 180000, tren20: 320000 },
              bathAndTrim: { duoi5: 260000 },
            },
            durationByPackage: { bath: { duoi5: 60 } },
            maxPets: 1,
          },
        },
      ]),
    );
    moMan();

    expect(await screen.findByText('Gói tắm · Dưới 5 kg')).toBeInTheDocument();
    expect(screen.getByText('180.000 đ · 60 phút')).toBeInTheDocument();
    expect(screen.getByText('Gói tắm · Trên 20 kg')).toBeInTheDocument();
    // Ô chưa khai thời lượng vẫn phải hiện giá chứ không rơi mất dòng
    expect(screen.getByText('320.000 đ')).toBeInTheDocument();
    expect(screen.getByText('Gói tắm và cắt tỉa · Dưới 5 kg')).toBeInTheDocument();
    expect(screen.queryByText(/NaN/)).toBeNull();
  });

  it('grooming không có phụ phí bé thêm nên không được hiện dòng đó', async () => {
    dungKho(
      hoSo([
        {
          type: 'GROOMING',
          enabled: true,
          petKind: 'CAT',
          pricing: {
            type: 'GROOMING',
            priceByPackage: { bath: { duoi5: 180000 } },
            durationByPackage: { bath: { duoi5: 60 } },
            maxPets: 1,
          },
        },
      ]),
    );
    moMan();

    expect(await screen.findByText('Nhận tối đa')).toBeInTheDocument();
    expect(screen.queryByText('Mỗi thú cưng thêm')).toBeNull();
  });

  it('ô giá bằng null thì bỏ hẳn dòng chứ không hiện 0 đ', async () => {
    dungKho(
      hoSo([
        {
          type: 'BOARDING',
          enabled: true,
          petKind: 'CAT',
          pricing: {
            type: 'BOARDING',
            pricePerDay: null,
            capacity: null,
            additionalPetFee: null,
            maxPets: 1,
          },
        },
      ]),
    );
    moMan();

    expect(await screen.findByText('Nhận tối đa')).toBeInTheDocument();
    expect(screen.queryByText('0 đ')).toBeNull();
    expect(screen.queryByText('Một đêm')).toBeNull();
  });

  it('loại phạt tạm ẩn có nhãn tiếng Việt, không in khoá dịch ra màn', async () => {
    dungKho({
      ...hoSo([]),
      penalties: [
        {
          id: 'p-1',
          kind: 'HIDE',
          status: 'ACTIVE',
          reason: 'Bỏ đơn sau khi xuất phát',
          createdAt: '2026-08-01T02:00:00+07:00',
          bookingCode: 'PC9C4RN6',
        },
      ],
    });
    moMan();

    expect(await screen.findByText(/Bỏ đơn sau khi xuất phát/)).toBeInTheDocument();
    expect(screen.queryByText('kyLuat.loai.HIDE')).toBeNull();
    expect(screen.getAllByText('Tạm ẩn hồ sơ').length).toBeGreaterThan(0);
  });
});
