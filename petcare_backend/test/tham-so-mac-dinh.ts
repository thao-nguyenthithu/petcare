import { THAM_SO } from '../src/modules/admin/tham-so.dinh-nghia';

// Lấy từ bộ khai chứ không chép số: đổi mặc định là test đổi theo, đúng ý đồ
export const PHI_HUY = THAM_SO['cancel.fee.percent'].macDinh;
export const NEN_TANG = THAM_SO['platform.fee.percent'].macDinh;
export const GIO_GIU_TIEN = THAM_SO['escrow.hours'].macDinh;
export const NGAY_CUA_SO = THAM_SO['penalty.window_days'].macDinh;
export const CANH_CAO_TAM_AN = THAM_SO['penalty.warnings_to_hide'].macDinh;
export const SO_LAN_RUT_MOI_NGAY = THAM_SO['withdraw.per_day'].macDinh;
export const SO_TIEN_RUT_TOI_THIEU = THAM_SO['withdraw.min'].macDinh;
