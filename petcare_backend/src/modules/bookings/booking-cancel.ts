import {
  MOT_PHUT_MS,
  khoaNgayVn,
  mocVn,
  themNgay,
} from '../../common/thoi-gian-vn';
import { phiHuy, phiNenTang } from '../../common/tien';
import { THAM_SO } from '../admin/tham-so.dinh-nghia';
import { tinhKetThucSom } from './booking-pricing';
import { LoaiDichVuDto } from './dto/create-booking.dto';

export function phanTramPhiHuyCuaDon(phanTramLuu: number | null): number {
  return phanTramLuu ?? THAM_SO['cancel.fee.percent'].macDinh;
}

export function phanTramNenTangCuaDon(phanTramLuu: number | null): number {
  return phanTramLuu ?? THAM_SO['platform.fee.percent'].macDinh;
}

export const LATE_BOOK_GRACE_MINUTES = 30;
export const GIO_HUY_MIEN_PHI_VN = '12:00';
export const NGAY_LUI_MAC_DINH = 1;
export const NGAY_LUI_KY_DAI = 7;
export const DEM_KY_DAI = 7;
export const DEM_TINH_PHI_TOI_DA = 7;
export const PHUT_QUA_HEN_NCC = 15;
export const PHUT_TU_HUY_NCC_CHUA_TOI = 30;

export function mocTuHuyNccChuaToi(batDau: Date): Date {
  return new Date(batDau.getTime() + PHUT_TU_HUY_NCC_CHUA_TOI * MOT_PHUT_MS);
}

export type KetQuaXetMienPhi = {
  mienPhi: boolean;
  doNguoiCham: boolean;
};

export type DonXetHuy = {
  loai: LoaiDichVuDto;
  batDau: Date;
  soDem: number;
  tongTien: number;
  dangCho: boolean;
  taoLuc: Date;
  acceptedAt: Date | null;
  arrivedAt: Date | null;
  departedAt: Date | null;
};

// Mốc huỷ miễn phí của đúng đơn này
export function hanHuyMienPhiAt(
  loai: LoaiDichVuDto,
  batDau: Date,
  soDem: number,
): Date {
  const lui =
    loai === 'boarding' && soDem > DEM_KY_DAI
      ? NGAY_LUI_KY_DAI
      : NGAY_LUI_MAC_DINH;
  const ngay = themNgay(khoaNgayVn(batDau), -lui);
  return mocVn(ngay, GIO_HUY_MIEN_PHI_VN);
}

export function laDatGap(taoLuc: Date, han: Date): boolean {
  return taoLuc.getTime() > han.getTime();
}

export function xetMienPhi(don: DonXetHuy, bayGio: number): KetQuaXetMienPhi {
  if (don.dangCho) return { mienPhi: true, doNguoiCham: false };

  const quaHen =
    don.loai !== 'boarding' &&
    don.arrivedAt === null &&
    bayGio >= don.batDau.getTime() + PHUT_QUA_HEN_NCC * MOT_PHUT_MS;
  if (quaHen) return { mienPhi: true, doNguoiCham: true };

  const han = hanHuyMienPhiAt(don.loai, don.batDau, don.soDem);
  if (bayGio <= han.getTime()) return { mienPhi: true, doNguoiCham: false };

  if (laDatGap(don.taoLuc, han) && don.acceptedAt && !don.departedAt) {
    const hetAnHan =
      don.acceptedAt.getTime() + LATE_BOOK_GRACE_MINUTES * MOT_PHUT_MS;
    if (bayGio <= hetAnHan) return { mienPhi: true, doNguoiCham: false };
  }
  return { mienPhi: false, doNguoiCham: false };
}

export function hetAnHanDatGapAt(don: DonXetHuy, han: Date): Date | null {
  if (!laDatGap(don.taoLuc, han) || !don.acceptedAt || don.departedAt) {
    return null;
  }
  return new Date(
    don.acceptedAt.getTime() + LATE_BOOK_GRACE_MINUTES * MOT_PHUT_MS,
  );
}

export function phiHuyCuaDon(
  loai: LoaiDichVuDto,
  tongTien: number,
  soDem: number,
  phanTramPhiHuy: number,
  batDau?: Date,
  bamLuc: number = Date.now(),
): number {
  if (loai !== 'boarding' || soDem < 1) return phiHuy(tongTien, phanTramPhiHuy);
  const dauKy = batDau ?? new Date(bamLuc);
  return tinhKetThucSom(tongTien, soDem, phanTramPhiHuy, dauKy, 0, bamLuc)
    .chuNuoiTra;
}

export function phanChiaPhiHuy(
  khoanPhiHuy: number,
  phanTramNenTang: number,
): {
  nccNhan: number;
  nenTang: number;
} {
  const nenTang = phiNenTang(khoanPhiHuy, phanTramNenTang);
  return { nccNhan: khoanPhiHuy - nenTang, nenTang };
}
