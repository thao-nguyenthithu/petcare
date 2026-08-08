// Trần điểm một lượt tra soát kéo về, suy từ mức của lượt dài nhất (bộ luật mục 8)
export const TRAN_DIEM_TRA_SOAT = 5000;

// Mã đơn đi thẳng vào tên tệp nên phải chặn ký tự lạ, không thì nhét được header
export const MA_DON_HOP_LE = /^[A-Za-z0-9-]{1,40}$/;

// Bốn tab đều đọc thẳng từ dữ liệu, không tab nào dựng trên một ngưỡng tự đặt
export const TAB_GPS = ['flagged', 'reviewed', 'noClaim', 'all'] as const;
export type TabGps = (typeof TAB_GPS)[number];
