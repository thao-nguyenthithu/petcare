export const BUCKET_ANH_DON = 'booking-media';
export const BUCKET_ANH_CHAT = 'chat-media';
export const GIAY_KY_ANH = 3600;
export const THU_MUC_ANH_CHAT = 'chat';

function laUrlTuyetDoi(giaTri: string): boolean {
  return /^https?:\/\//i.test(giaTri);
}

export function khoCuaAnh(giaTri: string): string | null {
  if (!giaTri) return null;
  if (!laUrlTuyetDoi(giaTri)) {
    return giaTri.startsWith(`${THU_MUC_ANH_CHAT}/`)
      ? BUCKET_ANH_CHAT
      : BUCKET_ANH_DON;
  }
  if (giaTri.includes(`/${BUCKET_ANH_CHAT}/`)) return BUCKET_ANH_CHAT;
  return giaTri.includes(`/${BUCKET_ANH_DON}/`) ? BUCKET_ANH_DON : null;
}

export function duongDanAnh(giaTri: string): string {
  if (!laUrlTuyetDoi(giaTri)) return giaTri;
  const kho = khoCuaAnh(giaTri);
  if (!kho) return giaTri;
  const doan = giaTri.split(`/${kho}/`);
  return doan.length > 1 ? doan[doan.length - 1].split('?')[0] : giaTri;
}
