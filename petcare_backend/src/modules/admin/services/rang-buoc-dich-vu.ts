import { ServiceType } from '../../../../generated/prisma/enums';
import {
  GROOMING_PACKAGES as GOI_GROOMING,
  GROOMING_PHUT_BUOC,
  GROOMING_PHUT_TOI_DA,
  GROOMING_PHUT_TOI_THIEU,
  WALKING_DURATIONS as PHUT_MOI_LUOT_DAT,
  WEIGHT_TIERS as BAC_CAN,
} from '../../sitter/services/sitter-services.service';

// Cửa khai giá của người chăm giữ bản gốc, chép sang đây là hai bảng lệch nhau
export { BAC_CAN, GOI_GROOMING, PHUT_MOI_LUOT_DAT };

// Bảng ràng buộc cố định của màn: chỉ số và khoá, chữ hiện màn nằm ở vi.json
export const RANG_BUOC_DICH_VU = [
  {
    code: 'MUC_THOI_LUONG_DAT',
    numbers: PHUT_MOI_LUOT_DAT,
    keys: [] as string[],
  },
  { code: 'GOI_GROOMING', numbers: [] as number[], keys: GOI_GROOMING },
  { code: 'BAC_CAN', numbers: [] as number[], keys: BAC_CAN },
  {
    code: 'THOI_LUONG_GROOMING',
    numbers: [
      GROOMING_PHUT_TOI_THIEU,
      GROOMING_PHUT_TOI_DA,
      GROOMING_PHUT_BUOC,
    ],
    keys: [] as string[],
  },
];

export type BangGiaDat = {
  type: 'WALKING';
  priceByDuration: Record<string, number>;
  additionalPetFee: number | null;
  maxPets: number | null;
};

export type BangGiaTrongGiu = {
  type: 'BOARDING';
  pricePerDay: number | null;
  capacity: number | null;
  additionalPetFee: number | null;
  maxPets: number | null;
};

export type BangGiaGrooming = {
  type: 'GROOMING';
  priceByPackage: Record<string, Record<string, number>>;
  durationByPackage: Record<string, Record<string, number>>;
  maxPets: number | null;
};

export type BangGia = BangGiaDat | BangGiaTrongGiu | BangGiaGrooming;

function tuiJson(gia: unknown): Record<string, unknown> {
  return gia && typeof gia === 'object' && !Array.isArray(gia)
    ? (gia as Record<string, unknown>)
    : {};
}

// Cột pricing là Json tự do nên số lẻ lọt vào được, tiền là số nguyên đồng (bộ luật mục 2)
function soNguyen(gia: unknown): number | null {
  return typeof gia === 'number' && Number.isFinite(gia)
    ? Math.floor(gia)
    : null;
}

function bangSo(gia: unknown, khoaChoPhep: string[]): Record<string, number> {
  const tho = tuiJson(gia);
  const ra: Record<string, number> = {};
  for (const khoa of khoaChoPhep) {
    const so = soNguyen(tho[khoa]);
    if (so !== null && so > 0) ra[khoa] = so;
  }
  return ra;
}

function bangHaiTang(gia: unknown): Record<string, Record<string, number>> {
  const tho = tuiJson(gia);
  const ra: Record<string, Record<string, number>> = {};
  for (const goi of GOI_GROOMING) {
    const muc = bangSo(tho[goi], BAC_CAN);
    if (Object.keys(muc).length > 0) ra[goi] = muc;
  }
  return ra;
}

// Đọc bảng giá người chăm tự khai về đúng ba hình dạng màn quản trị vẽ được
export function doiBangGia(type: ServiceType, pricing: unknown): BangGia {
  const tho = tuiJson(pricing);
  const maxPets = soNguyen(tho.maxPets);
  if (type === ServiceType.BOARDING) {
    return {
      type: 'BOARDING',
      pricePerDay: soNguyen(tho.pricePerDay),
      capacity: soNguyen(tho.capacity),
      additionalPetFee: soNguyen(tho.additionalPetFee),
      maxPets,
    };
  }
  if (type === ServiceType.GROOMING) {
    return {
      type: 'GROOMING',
      priceByPackage: bangHaiTang(tho.priceByPackage),
      durationByPackage: bangHaiTang(tho.durationByPackage),
      maxPets,
    };
  }
  return {
    type: 'WALKING',
    priceByDuration: bangSo(tho.priceByDuration, PHUT_MOI_LUOT_DAT.map(String)),
    additionalPetFee: soNguyen(tho.additionalPetFee),
    maxPets,
  };
}

export type LoiBangGia = { code: string; message: string };

function loi(message: string): LoiBangGia {
  return { code: 'BANG_GIA_CHUA_DU', message };
}

function phuPhiSai(fee: number | null, maxPets: number): LoiBangGia | null {
  const nhieuBe = maxPets >= 2;
  if (nhieuBe && fee === null) {
    return loi('Nhận từ 2 bé mỗi đơn thì bảng giá phải có phụ phí bé thêm');
  }
  if (!nhieuBe && fee !== null) {
    return loi('Chỉ đặt phụ phí bé thêm khi nhận từ 2 bé mỗi đơn');
  }
  return null;
}

function thieuGrooming(gia: BangGiaGrooming): LoiBangGia | null {
  const goiCoGia = Object.keys(gia.priceByPackage);
  if (goiCoGia.length === 0) {
    return loi('Bảng giá tắm và cắt tỉa chưa có ô giá nào');
  }
  for (const goi of goiCoGia) {
    for (const muc of Object.keys(gia.priceByPackage[goi])) {
      const phut = gia.durationByPackage[goi]?.[muc];
      if (phut === undefined) {
        return loi('Ô giá nào đã nhập thì phải có thời lượng đi kèm');
      }
      if (
        phut < GROOMING_PHUT_TOI_THIEU ||
        phut > GROOMING_PHUT_TOI_DA ||
        phut % GROOMING_PHUT_BUOC !== 0
      ) {
        return loi(
          `Thời lượng phải từ ${GROOMING_PHUT_TOI_THIEU} đến ${GROOMING_PHUT_TOI_DA} phút, bước ${GROOMING_PHUT_BUOC} phút`,
        );
      }
    }
  }
  return null;
}

// Cùng cửa với lúc người chăm tự bật, mở lại từ trang quản trị không được đi vòng (bộ luật mục 3)
export function thieuDeBat(gia: BangGia): LoiBangGia | null {
  if (gia.maxPets === null || gia.maxPets < 1) {
    return loi('Bảng giá chưa khai số bé tối đa mỗi đơn');
  }
  if (gia.type === 'WALKING') {
    const thieu = PHUT_MOI_LUOT_DAT.filter(
      (phut) => gia.priceByDuration[String(phut)] === undefined,
    );
    if (thieu.length > 0) {
      return loi(`Bảng giá chưa có giá cho lượt ${thieu.join(' và ')} phút`);
    }
    return phuPhiSai(gia.additionalPetFee, gia.maxPets);
  }
  if (gia.type === 'BOARDING') {
    if (gia.pricePerDay === null || gia.capacity === null) {
      return loi('Bảng giá chưa có giá một đêm hoặc sức chứa mỗi ngày');
    }
    if (gia.maxPets > gia.capacity) {
      return loi('Số bé tối đa mỗi đơn đang vượt sức chứa đã khai');
    }
    return phuPhiSai(gia.additionalPetFee, gia.maxPets);
  }
  return thieuGrooming(gia);
}
