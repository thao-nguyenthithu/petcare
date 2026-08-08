export const VIEC_GUI_THONG_BAO = 'gui-thong-bao-he-thong';

export type ViecGuiThongBao = { campaignId: string };

// Trần một lần sendEachForMulticast của FCM, đọc người nhận cũng theo lô này
export const CO_LO_NGUOI_NHAN = 500;

// Chặn vòng lặp vô hạn khi một lô ghi hụt mà không ném lỗi
export const TRAN_SO_LO = 400;

const MOT_PHUT_MS = 60_000;

// Lượt gửi tạo trong khoảng này mà chưa chốt thì coi như đang chạy dở
export const CUA_SO_DANG_GUI_MS = 10 * MOT_PHUT_MS;

// Cùng tiêu đề trong khoảng này là bấm hai lần, không phải hai lượt khác nhau
export const CUA_SO_TRUNG_MS = 5 * MOT_PHUT_MS;

export function maJobLuotGui(campaignId: string) {
  return `thong-bao-${campaignId}`;
}
