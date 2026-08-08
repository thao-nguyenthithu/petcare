import { lechMet, ToaDo } from './anh-bang-chung';

// Ảnh đồ dùng đứng nhóm riêng nên nhóm pha CHỈ nhận ảnh của các bé (ui-contracts admin 10b)
export const PHA_PHIEN = ['CHECK_IN', 'IN_PROGRESS', 'CHECK_OUT'] as const;

export type AnhPhienTho = {
  id: string;
  photoUrl: string;
  phase: string;
  anhDoDung: boolean;
  anhVanXa: boolean;
  photoLat: number | null;
  photoLng: number | null;
  takenAt: Date;
  aiConfidenceScore: number | null;
  aiPassed: boolean | null;
};

export type BanGhiNgayTho = {
  id: string;
  message: string | null;
  conditions: string[];
  photoUrls: string[];
  createdAt: Date;
};

export type AnhAlbum = {
  id: string;
  url: string;
  takenAt: Date;
  photoLat: number | null;
  photoLng: number | null;
  distanceFromMeetingM: number | null;
  anhDoDung: boolean;
  anhVanXa: boolean;
  aiConfidenceScore: number | null;
  aiPassed: boolean | null;
};

// dayIndex khác null là nhóm một ngày của kỳ giữ, màn tự dựng chữ "Ngày n" theo ngôn ngữ
export type NhomAnh = {
  key: string;
  dayIndex: number | null;
  date: Date | null;
  photoCount: number;
  conditions: string[];
  message: string | null;
  photos: AnhAlbum[];
};

function veAnh(tho: AnhPhienTho, diem: ToaDo): AnhAlbum {
  return {
    id: tho.id,
    url: tho.photoUrl,
    takenAt: tho.takenAt,
    photoLat: tho.photoLat,
    photoLng: tho.photoLng,
    distanceFromMeetingM: lechMet(diem, {
      lat: tho.photoLat,
      lng: tho.photoLng,
    }),
    anhDoDung: tho.anhDoDung,
    anhVanXa: tho.anhVanXa,
    aiConfidenceScore: tho.aiConfidenceScore,
    aiPassed: tho.aiPassed,
  };
}

// Ảnh chỉ có đường dẫn thì không có toạ độ để đối chiếu, để trống chứ không mượn của đơn
function veAnhTuUrl(id: string, url: string, takenAt: Date): AnhAlbum {
  return {
    id,
    url,
    takenAt,
    photoLat: null,
    photoLng: null,
    distanceFromMeetingM: null,
    anhDoDung: false,
    anhVanXa: false,
    aiConfidenceScore: null,
    aiPassed: null,
  };
}

function dungNhom(
  key: string,
  photos: AnhAlbum[],
  them: Partial<NhomAnh> = {},
): NhomAnh {
  return {
    key,
    dayIndex: null,
    date: photos[0]?.takenAt ?? null,
    photoCount: photos.length,
    conditions: [],
    message: null,
    photos,
    ...them,
  };
}

// Luôn đủ ba nhóm: thiếu ảnh check-out là thứ phải thấy ngay chứ không phải nhóm biến mất
export function nhomTheoPha(anh: AnhPhienTho[], diem: ToaDo): NhomAnh[] {
  return PHA_PHIEN.map((pha) =>
    dungNhom(
      pha,
      anh
        .filter((a) => a.phase === pha && !a.anhDoDung)
        .map((a) => veAnh(a, diem)),
    ),
  );
}

// Món gửi kèm là thứ hay tranh cãi nhất lúc trả bé nên phải mở riêng ra xem được
export function nhomTrongGiu(
  anh: AnhPhienTho[],
  banGhi: BanGhiNgayTho[],
  diem: ToaDo,
): NhomAnh[] {
  const loc = (pha: string, doDung: boolean) =>
    anh
      .filter((a) => a.phase === pha && a.anhDoDung === doDung)
      .map((a) => veAnh(a, diem));

  const ngay = banGhi.map((ban, i) =>
    dungNhom(
      `ngay-${i + 1}`,
      ban.photoUrls.map((url, ord) =>
        veAnhTuUrl(`${ban.id}-${ord + 1}`, url, ban.createdAt),
      ),
      {
        dayIndex: i + 1,
        date: ban.createdAt,
        conditions: ban.conditions,
        message: ban.message,
      },
    ),
  );

  return [
    dungNhom('nhanBe', loc('CHECK_IN', false)),
    dungNhom('supplyIn', loc('CHECK_IN', true)),
    ...ngay,
    dungNhom('traBe', loc('CHECK_OUT', false)),
    dungNhom('supplyOut', loc('CHECK_OUT', true)),
  ];
}

// Chỉ dựng khi thật sự có ảnh: đơn chạy trơn tru không cần một nhóm rỗng nói về sự cố
export function nhomSuCo(
  bookingId: string,
  urls: string[],
  takenAt: Date,
): NhomAnh[] {
  if (!urls.length) return [];
  const photos = urls.map((url, ord) =>
    veAnhTuUrl(`${bookingId}-${ord + 1}`, url, takenAt),
  );
  return [dungNhom('suCo', photos, { date: takenAt })];
}
