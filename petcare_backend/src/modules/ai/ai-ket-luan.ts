import {
  CANH_DAI_DU_NET_PX,
  NGUONG_TIN_CAY_DAT,
  NGUONG_TIN_CAY_TU_XAC_NHAN,
} from './ai.constants';
import { AiVerifyResult } from './interfaces/ai-vision.interface';

type Gear = 'PRESENT' | 'ABSENT' | 'UNCLEAR';

export type BaoCaoModel = {
  dog_visible: boolean;
  image_clear: boolean;
  muzzle: Gear;
  confidence: number;
};

export const CAU_TIENG_VIET = {
  DAT: 'Bé đã đeo rọ mõm, ảnh đạt yêu cầu.',
  THIEU_RO_MOM: 'Không thấy rọ mõm trên mõm bé. Hãy đeo rọ mõm rồi chụp lại.',
  KHONG_THAY_CHO:
    'Không nhận ra bé nào trong ảnh. Hãy chụp lại rõ cả người bé.',
  ANH_MO: 'Ảnh mờ hoặc thiếu sáng nên chưa soi được. Hãy chụp lại rõ hơn.',
  KHONG_RO_RO_MOM:
    'Chưa nhìn rõ phần mõm của bé. Hãy chụp lại thấy rõ mặt và mõm.',
  ANH_DO_PHAN_GIAI_THAP:
    'Ảnh chưa đủ nét để máy chắc chắn. Bạn đang đứng cạnh bé nên hãy tự xác nhận.',
  ANH_KHONG_TAI_DUOC: 'Không tải được ảnh vừa gửi. Hãy thử chụp lại.',
  ANH_QUA_LON: 'Ảnh quá nặng nên chưa gửi đi soi được. Hãy chụp lại.',
  KIEU_ANH_KHONG_HO_TRO:
    'Định dạng ảnh không hỗ trợ. Hãy chụp lại bằng máy ảnh.',
  THIEU_KHOA_API: 'Hệ thống nhận diện ảnh đang không sẵn sàng.',
  KHOA_API_KHONG_DUNG: 'Hệ thống nhận diện ảnh đang không sẵn sàng.',
  HET_HAN_MUC: 'Hệ thống nhận diện ảnh đang quá tải. Hãy thử lại sau ít phút.',
  QUA_HAN_CHO: 'Soi ảnh lâu quá không xong. Hãy thử lại.',
  KET_QUA_KHONG_DOC_DUOC: 'Chưa đọc được kết quả soi ảnh. Hãy thử lại.',
  LOI_DICH_VU_AI: 'Chưa soi được ảnh lúc này. Hãy thử lại.',
} satisfies Record<string, string>;

export type MaKetQuaAi = keyof typeof CAU_TIENG_VIET;

export const CAU_MAC_DINH = 'Chưa xác minh được ảnh lúc này. Hãy thử lại.';

export function chuaXacMinhDuoc(
  code: MaKetQuaAi,
  rawResponse: Record<string, unknown> = {},
): AiVerifyResult {
  return {
    trangThai: 'CHUA_XAC_MINH_DUOC',
    isSafe: false,
    confidence: 0,
    code,
    reason: CAU_TIENG_VIET[code] ?? CAU_MAC_DINH,
    rawResponse,
  };
}

export type XuLySlot = 'DI_TIEP' | 'TU_XAC_NHAN' | 'CHUP_LAI';

export function xuLySlot(ket: {
  trangThai: string | null;
  confidence: number | null;
  canhDaiPx?: number | null;
}): XuLySlot {
  if (ket.trangThai !== 'DAT') return 'CHUP_LAI';
  const doTin = ket.confidence ?? 0;
  if (doTin < NGUONG_TIN_CAY_TU_XAC_NHAN) return 'CHUP_LAI';
  if (doTin < NGUONG_TIN_CAY_DAT) return 'TU_XAC_NHAN';
  return anhDuNet(ket.canhDaiPx) ? 'DI_TIEP' : 'TU_XAC_NHAN';
}

export function anhDuNet(canhDaiPx: number | null | undefined): boolean {
  return (canhDaiPx ?? 0) >= CANH_DAI_DU_NET_PX;
}

const MA_HE_THONG_HONG = [
  'THIEU_KHOA_API',
  'KHOA_API_KHONG_DUNG',
  'HET_HAN_MUC',
  'QUA_HAN_CHO',
  'LOI_DICH_VU_AI',
  'KET_QUA_KHONG_DOC_DUOC',
  'ANH_KHONG_TAI_DUOC',
  'ANH_QUA_LON',
  'KIEU_ANH_KHONG_HO_TRO',
] satisfies MaKetQuaAi[];

export function laHeThongHong(code: MaKetQuaAi): boolean {
  return (MA_HE_THONG_HONG as MaKetQuaAi[]).includes(code);
}

// Lượt hệ thống hỏng không được ăn vào ba lần chụp lại của bé
export function truLuotChupLai(code: MaKetQuaAi): boolean {
  return !laHeThongHong(code);
}

export function maLoiTheoTrangThai(status: number | undefined): MaKetQuaAi {
  if (status === 401 || status === 403) return 'KHOA_API_KHONG_DUNG';
  if (status === 429) return 'HET_HAN_MUC';
  if (status === 408 || status === 504) return 'QUA_HAN_CHO';
  return 'LOI_DICH_VU_AI';
}

function ketLuan(
  trangThai: 'DAT' | 'KHONG_DAT',
  code: MaKetQuaAi,
  confidence: number,
  rawResponse: Record<string, unknown>,
): AiVerifyResult {
  return {
    trangThai,
    isSafe: trangThai === 'DAT',
    confidence,
    code,
    reason: CAU_TIENG_VIET[code] ?? CAU_MAC_DINH,
    rawResponse,
  };
}

function laGear(gia: unknown): gia is Gear {
  return gia === 'PRESENT' || gia === 'ABSENT' || gia === 'UNCLEAR';
}

export function docBaoCao(tho: unknown): BaoCaoModel | null {
  if (!tho || typeof tho !== 'object') return null;
  const o = tho as Record<string, unknown>;
  if (typeof o.dog_visible !== 'boolean') return null;
  if (typeof o.image_clear !== 'boolean') return null;
  if (!laGear(o.muzzle)) return null;
  const doTin = typeof o.confidence === 'number' ? o.confidence : 0;
  return {
    dog_visible: o.dog_visible,
    image_clear: o.image_clear,
    muzzle: o.muzzle,
    confidence: Math.min(1, Math.max(0, doTin)),
  };
}

export function ketLuanTuBaoCao(
  bc: BaoCaoModel,
  rawResponse: Record<string, unknown>,
): AiVerifyResult {
  if (!bc.dog_visible) return chuaXacMinhDuoc('KHONG_THAY_CHO', rawResponse);
  if (!bc.image_clear) return chuaXacMinhDuoc('ANH_MO', rawResponse);
  if (bc.muzzle === 'UNCLEAR') {
    return chuaXacMinhDuoc('KHONG_RO_RO_MOM', rawResponse);
  }
  if (bc.muzzle === 'ABSENT') {
    return ketLuan('KHONG_DAT', 'THIEU_RO_MOM', bc.confidence, rawResponse);
  }
  return ketLuan('DAT', 'DAT', bc.confidence, rawResponse);
}
