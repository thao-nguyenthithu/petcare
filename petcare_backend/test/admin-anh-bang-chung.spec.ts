import { NotFoundException } from '@nestjs/common';
import { AdminBookingEvidenceService } from '../src/modules/admin/evidence/admin-booking-evidence.service';
import { AdminEvidenceReadService } from '../src/modules/admin/evidence/admin-evidence-read.service';
import {
  nhomSuCo,
  nhomTheoPha,
  nhomTrongGiu,
} from '../src/modules/admin/evidence/album-nhom';
import {
  diemHen,
  kieuBaoSuCo,
  lechMet,
  soDem,
} from '../src/modules/admin/evidence/anh-bang-chung';
import { PrismaService } from '../src/prisma/prisma.service';
import { anhKyGia } from './anh-ky-gia';

type BanGhi = Record<string, unknown>;

const NHA_NCC = { lat: 21.03, lng: 105.81 };
const NHA_CHU_NUOI = { lat: 21.0, lng: 105.8 };

function anhPhien(ghiDe: BanGhi = {}) {
  return {
    id: 'sp-1',
    photoUrl: 'https://kho/anh-1.jpg',
    phase: 'CHECK_IN',
    anhDoDung: false,
    anhVanXa: false,
    photoLat: null,
    photoLng: null,
    takenAt: new Date('2026-08-04T02:00:00Z'),
    aiConfidenceScore: null,
    aiPassed: null,
    ...ghiDe,
  };
}

// Trả câu SQL nào cũng khớp theo từ khoá, khỏi phải dựng cả một database cho một phép ánh xạ
function khoQueryRaw(bang: Array<{ khop: RegExp; dong: unknown[] }>) {
  return (strings: TemplateStringsArray) => {
    const sql = strings.join(' ');
    return Promise.resolve(bang.find((b) => b.khop.test(sql))?.dong ?? []);
  };
}

function dungDocAnh(
  bang: Array<{ khop: RegExp; dong: unknown[] }>,
  demPhien = 0,
) {
  const prisma: BanGhi = {
    sessionPhoto: { count: () => Promise.resolve(demPhien) },
    bookingGpsReport: { count: () => Promise.resolve(3) },
    $queryRaw: khoQueryRaw(bang),
  };
  return new AdminEvidenceReadService(
    prisma as unknown as PrismaService,
    anhKyGia().service,
  );
}

describe('Ba nhánh cùng ghi vào một cột ảnh phải phân biệt được', () => {
  it('khép đơn thắng lượt báo thiếu dụng cụ vì nó ghi đè mảng ảnh', () => {
    const luc = new Date('2026-08-04T01:00:00Z');
    expect(kieuBaoSuCo('CANCELLED_NO_SHOW', luc)).toBe('NO_SHOW');
    expect(kieuBaoSuCo('CANCELLED_BY_SITTER', luc)).toBe('SITTER_ABANDON');
    expect(kieuBaoSuCo('IN_PROGRESS', luc)).toBe('GEAR');
    expect(kieuBaoSuCo('IN_PROGRESS', null)).toBeNull();
  });
});

describe('Điểm hẹn và độ lệch của ảnh', () => {
  it('trông giữ lấy nhà người chăm, hai dịch vụ kia lấy địa chỉ đơn', () => {
    expect(diemHen('BOARDING', NHA_CHU_NUOI, NHA_NCC)).toEqual(NHA_NCC);
    expect(diemHen('WALKING', NHA_CHU_NUOI, NHA_NCC)).toEqual(NHA_CHU_NUOI);
  });

  it('thiếu toạ độ một đầu thì để rỗng chứ không suy ra 0 mét', () => {
    expect(lechMet(NHA_CHU_NUOI, { lat: null, lng: null })).toBeNull();
    expect(lechMet({ lat: null, lng: null }, NHA_NCC)).toBeNull();
    expect(lechMet(NHA_CHU_NUOI, NHA_CHU_NUOI)).toBe(0);
  });

  it('chưa chốt ngày trả bé thì số đêm để rỗng', () => {
    const tu = new Date('2026-08-01T00:00:00Z');
    expect(soDem(tu, null)).toBeNull();
    expect(soDem(tu, new Date('2026-08-04T00:00:00Z'))).toBe(3);
  });
});

describe('Gom nhóm ảnh của một đơn', () => {
  it('đơn dắt và cắt tỉa luôn đủ ba nhóm pha để thấy pha nào thiếu ảnh', () => {
    const nhom = nhomTheoPha([anhPhien()], NHA_CHU_NUOI);
    expect(nhom.map((n) => n.key)).toEqual([
      'CHECK_IN',
      'IN_PROGRESS',
      'CHECK_OUT',
    ]);
    expect(nhom[1].photoCount).toBe(0);
    expect(nhom[1].photos).toEqual([]);
  });

  it('ảnh đồ dùng đứng nhóm riêng, không lẫn vào nhóm ảnh các bé cùng pha', () => {
    const nhom = nhomTrongGiu(
      [
        anhPhien({ id: 'be-1' }),
        anhPhien({ id: 'do-1', anhDoDung: true }),
        anhPhien({ id: 'do-2', phase: 'CHECK_OUT', anhDoDung: true }),
      ],
      [
        {
          id: 'bu-1',
          message: 'Bé ăn ngoan',
          conditions: ['Ăn ngon miệng'],
          photoUrls: ['https://kho/ngay1-a.jpg', 'https://kho/ngay1-b.jpg'],
          createdAt: new Date('2026-08-02T01:00:00Z'),
        },
      ],
      NHA_NCC,
    );

    expect(nhom.map((n) => n.key)).toEqual([
      'nhanBe',
      'supplyIn',
      'ngay-1',
      'traBe',
      'supplyOut',
    ]);
    expect(nhom[0].photos.map((a) => a.id)).toEqual(['be-1']);
    expect(nhom[1].photos.map((a) => a.id)).toEqual(['do-1']);
    expect(nhom[4].photos.map((a) => a.id)).toEqual(['do-2']);
    expect(nhom[2].dayIndex).toBe(1);
    expect(nhom[2].photoCount).toBe(2);
  });

  it('bản nhật ký chỉ có đường dẫn nên ảnh của nó không có điểm AI và không có toạ độ', () => {
    const [nhom] = nhomTrongGiu(
      [],
      [
        {
          id: 'bu-1',
          message: null,
          conditions: [],
          photoUrls: ['https://kho/a.jpg'],
          createdAt: new Date('2026-08-02T01:00:00Z'),
        },
      ],
      NHA_NCC,
    ).filter((n) => n.dayIndex !== null);

    expect(nhom.photos[0]).toMatchObject({
      photoLat: null,
      photoLng: null,
      distanceFromMeetingM: null,
      aiConfidenceScore: null,
      aiPassed: null,
    });
  });

  it('đơn chạy trơn tru không đẻ ra một nhóm sự cố rỗng', () => {
    expect(nhomSuCo('bk-1', [], new Date())).toEqual([]);
    expect(nhomSuCo('bk-1', ['https://kho/a.jpg'], new Date())).toHaveLength(1);
  });
});

describe('Thư viện ảnh không tô 0 lên chỗ chưa chấm điểm', () => {
  it('ảnh chưa qua AI giữ nguyên rỗng ở cả hai cột', async () => {
    const doc = dungDocAnh(
      [
        {
          khop: /FROM "SessionPhoto"/,
          dong: [
            {
              id: 'sp-1',
              url: 'https://kho/a.jpg',
              phase: 'CHECK_OUT',
              anhDoDung: false,
              anhVanXa: false,
              photoLat: null,
              photoLng: null,
              takenAt: new Date('2026-08-04T02:00:00Z'),
              aiConfidenceScore: null,
              aiPassed: null,
              bookingCode: 'PC001',
              serviceName: 'Dắt đi dạo',
              serviceType: 'WALKING',
            },
          ],
        },
      ],
      1,
    );

    const ket = await doc.danhSach({ source: 'session' });
    expect(ket.total).toBe(1);
    expect(ket.items[0]).toMatchObject({
      source: 'session',
      aiConfidenceScore: null,
      aiPassed: null,
      reportKind: null,
    });
  });

  it('ảnh đã chấm giữ nguyên điểm và kết luận của lượt soi', async () => {
    const doc = dungDocAnh(
      [
        {
          khop: /FROM "SessionPhoto"/,
          dong: [
            {
              id: 'sp-2',
              url: 'https://kho/b.jpg',
              phase: 'CHECK_IN',
              anhDoDung: false,
              anhVanXa: true,
              photoLat: 21.0,
              photoLng: 105.8,
              takenAt: new Date('2026-08-04T02:00:00Z'),
              aiConfidenceScore: 0.62,
              aiPassed: false,
              bookingCode: 'PC002',
              serviceName: 'Dắt đi dạo',
              serviceType: 'WALKING',
            },
          ],
        },
      ],
      1,
    );

    const ket = await doc.danhSach({ source: 'session' });
    expect(ket.items[0]).toMatchObject({
      aiConfidenceScore: 0.62,
      aiPassed: false,
      anhVanXa: true,
    });
  });

  it('ảnh báo sự cố nói rõ nó thuộc nhánh nào và không kèm dữ liệu của hai vai', async () => {
    const doc = dungDocAnh([
      { khop: /SUM\(array_length\("noShowProofUrls"/, dong: [{ tong: 2 }] },
      {
        khop: /FROM "Booking" b/,
        dong: [
          {
            id: 'bk-1-1',
            url: 'https://kho/c.jpg',
            takenAt: new Date('2026-08-02T00:48:00Z'),
            status: 'CANCELLED_NO_SHOW',
            gearReportedAt: null,
            bookingCode: 'PC003',
            serviceName: 'Dắt đi dạo',
            serviceType: 'WALKING',
          },
        ],
      },
    ]);

    const ket = await doc.danhSach({ source: 'noShow' });
    expect(ket.total).toBe(2);
    expect(ket.items[0].reportKind).toBe('NO_SHOW');
    expect(Object.keys(ket.items[0])).not.toContain('ownerName');
    expect(Object.keys(ket.items[0])).not.toContain('sitterName');
  });

  it('đếm bốn tab lấy số ẢNH chứ không lấy số bản ghi cha', async () => {
    const doc = dungDocAnh(
      [
        { khop: /FROM "BoardingUpdate"/, dong: [{ tong: 15 }] },
        { khop: /FROM "Booking"/, dong: [{ tong: 4 }] },
      ],
      9,
    );

    await expect(doc.demNguon()).resolves.toEqual({
      session: 9,
      boarding: 15,
      noShow: 4,
      gpsFlagged: 3,
    });
  });
});

function dungAlbum(don: BanGhi | null) {
  const prisma: BanGhi = {
    booking: { findUnique: () => Promise.resolve(don) },
  };
  return new AdminBookingEvidenceService(
    prisma as unknown as PrismaService,
    anhKyGia().service,
  );
}

function donMau(ghiDe: BanGhi = {}) {
  return {
    id: 'bk-1',
    code: 'PC001',
    status: 'COMPLETED',
    scheduledAt: new Date('2026-08-01T01:00:00Z'),
    scheduledEndAt: new Date('2026-08-04T01:00:00Z'),
    cancelledAt: null,
    gearReportedAt: null,
    updatedAt: new Date('2026-08-04T02:00:00Z'),
    addressLat: NHA_CHU_NUOI.lat,
    addressLng: NHA_CHU_NUOI.lng,
    noShowProofUrls: [],
    service: { name: 'Trông giữ', type: 'BOARDING' },
    sitter: NHA_NCC,
    sessionPhotos: [],
    boardingUpdates: [],
    ...ghiDe,
  };
}

describe('Album ảnh của một đơn', () => {
  it('mã đơn không có thì báo không tìm thấy chứ không trả album rỗng', async () => {
    await expect(dungAlbum(null).album('PCXXX')).rejects.toBeInstanceOf(
      NotFoundException,
    );
  });

  it('kỳ giữ ba đêm mà chỉ có một bản là thiếu hai ngày', async () => {
    const ket = await dungAlbum(
      donMau({
        boardingUpdates: [
          {
            id: 'bu-1',
            message: 'Bé ngủ ngon',
            conditions: ['Ăn ngon miệng', 'Ngủ ngon'],
            photoUrls: ['https://kho/a.jpg'],
            createdAt: new Date('2026-08-02T01:00:00Z'),
          },
        ],
      }),
    ).album('PC001');

    // Số đêm chỉ để tính ra ô thiếu ngày, màn đọc ô đó chứ không đọc số đêm
    expect(ket.stats).toEqual({
      total: 1,
      dayCount: 1,
      conditionCount: 2,
      missingDayCount: 2,
      messageCount: 1,
    });
  });

  it('đơn dắt để RỖNG bốn ô của kỳ giữ, trả 0 là bịa ra ngày thiếu ảnh', async () => {
    const ket = await dungAlbum(
      donMau({
        service: { name: 'Dắt đi dạo', type: 'WALKING' },
        sessionPhotos: [anhPhien({ photoLat: 21.0, photoLng: 105.8 })],
      }),
    ).album('PC001');

    expect(ket.stats).toEqual({
      total: 1,
      dayCount: null,
      conditionCount: null,
      missingDayCount: null,
      messageCount: null,
    });
    expect(ket.groups[0].photos[0].distanceFromMeetingM).toBe(0);
  });

  it('đơn có ảnh báo sự cố thì mọc thêm đúng một nhóm ở cuối', async () => {
    const ket = await dungAlbum(
      donMau({
        status: 'CANCELLED_BY_SITTER',
        cancelledAt: new Date('2026-08-02T03:00:00Z'),
        service: { name: 'Dắt đi dạo', type: 'WALKING' },
        noShowProofUrls: ['https://kho/x.jpg', 'https://kho/y.jpg'],
      }),
    ).album('PC001');

    expect(ket.groups.map((n) => n.key)).toEqual([
      'CHECK_IN',
      'IN_PROGRESS',
      'CHECK_OUT',
      'suCo',
    ]);
    expect(ket.booking.reportKind).toBe('SITTER_ABANDON');
    expect(ket.stats.total).toBe(2);
  });
});
