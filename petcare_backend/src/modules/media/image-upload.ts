import { BadRequestException } from '@nestjs/common';
import { kieuTheoNoiDung } from './anh-kich-thuoc';

export type UploadedImage = {
  buffer?: Buffer;
  mimetype?: string;
  size?: number;
};

// Mỗi ảnh tối đa 8MB
export const GIOI_HAN_ANH_BYTE = 8 * 1024 * 1024;

// chỉ nhận đúng ba kiểu ảnh này
const KIEU_CHO_PHEP: Record<string, string> = {
  'image/jpeg': 'image/jpeg',
  'image/jpg': 'image/jpeg',
  'image/png': 'image/png',
  'image/webp': 'image/webp',
};

const DUOI_THEO_KIEU: Record<string, string> = {
  'image/jpeg': 'jpg',
  'image/png': 'png',
  'image/webp': 'webp',
};

// Chuẩn hoá kiểu ảnh theo whitelist
export function kieuAnhChoPhep(mimetype: string | undefined): string | null {
  return (
    KIEU_CHO_PHEP[(mimetype || '').toLowerCase().split(';')[0].trim()] ?? null
  );
}

export function kiemTraAnh(file: UploadedImage) {
  if (!file?.buffer?.length) {
    throw new BadRequestException({
      code: 'ANH_KHONG_HOP_LE',
      message: 'Ảnh tải lên không đọc được',
    });
  }
  if (file.buffer.length > GIOI_HAN_ANH_BYTE) {
    throw new BadRequestException({
      code: 'ANH_QUA_LON',
      message: `Mỗi ảnh chỉ được tối đa ${GIOI_HAN_ANH_BYTE / (1024 * 1024)}MB`,
    });
  }
  const kieu = kieuTheoNoiDung(file.buffer);
  if (!kieu) {
    throw new BadRequestException({
      code: 'KIEU_ANH_KHONG_HO_TRO',
      message: 'Chỉ nhận ảnh JPG, PNG hoặc WEBP',
    });
  }
  return { contentType: kieu, duoi: DUOI_THEO_KIEU[kieu] };
}

export const TRAN_TEP_MOI_LUOT = 12;
export const CAU_HINH_ANH = {
  limits: { fileSize: GIOI_HAN_ANH_BYTE },
};
