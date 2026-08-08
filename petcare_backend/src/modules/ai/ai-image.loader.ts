import { Injectable, Logger } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { kieuAnhChoPhep } from '../media/image-upload';
import { MaKetQuaAi } from './ai-ket-luan';
import { HAN_CHO_GOI_AI_MS, TRAN_ANH_GUI_AI_BYTE } from './ai.constants';

export type KieuAnhAi = 'image/jpeg' | 'image/png' | 'image/webp';
export type AnhChoAi = { base64: string; contentType: KieuAnhAi };
export type KetQuaTaiAnh =
  | { ok: true; anh: AnhChoAi }
  | { ok: false; code: MaKetQuaAi };

@Injectable()
export class AiImageLoader {
  private readonly logger = new Logger(AiImageLoader.name);

  constructor(private readonly config: ConfigService) {}

  private nguonHopLe(url: string): boolean {
    const kho = this.config.get<string>('supabase.url');
    if (!kho) return false;
    try {
      const dich = new URL(url);
      if (dich.protocol !== 'https:') return false;
      return dich.host === new URL(kho).host;
    } catch {
      return false;
    }
  }

  async tai(imageUrl: string): Promise<KetQuaTaiAnh> {
    if (!this.nguonHopLe(imageUrl)) {
      this.logger.error(`Từ chối tải ảnh ngoài kho của hệ thống: ${imageUrl}`);
      return { ok: false, code: 'ANH_KHONG_TAI_DUOC' };
    }
    let res: Response;
    try {
      res = await fetch(imageUrl, {
        signal: AbortSignal.timeout(HAN_CHO_GOI_AI_MS),
      });
    } catch (loi) {
      this.logger.error('Không tải được ảnh để gửi AI', loi as Error);
      return { ok: false, code: 'ANH_KHONG_TAI_DUOC' };
    }
    if (!res.ok) {
      this.logger.error(`Kho ảnh trả về ${res.status} cho ${imageUrl}`);
      return { ok: false, code: 'ANH_KHONG_TAI_DUOC' };
    }

    const contentType = kieuAnhChoPhep(
      res.headers.get('content-type') ?? '',
    ) as KieuAnhAi | null;
    if (!contentType) {
      return { ok: false, code: 'KIEU_ANH_KHONG_HO_TRO' };
    }
    const khai = Number(res.headers.get('content-length'));
    if (Number.isFinite(khai) && khai > TRAN_ANH_GUI_AI_BYTE) {
      return { ok: false, code: 'ANH_QUA_LON' };
    }
    let bytes: Buffer;
    try {
      bytes = Buffer.from(await res.arrayBuffer());
    } catch (loi) {
      this.logger.error('Không đọc được nội dung ảnh', loi as Error);
      return { ok: false, code: 'ANH_KHONG_TAI_DUOC' };
    }
    if (!bytes.length) return { ok: false, code: 'ANH_KHONG_TAI_DUOC' };
    if (bytes.length > TRAN_ANH_GUI_AI_BYTE) {
      return { ok: false, code: 'ANH_QUA_LON' };
    }
    return { ok: true, anh: { base64: bytes.toString('base64'), contentType } };
  }
}
