import { Injectable, Logger } from '@nestjs/common';
import { GIAY_KY_ANH, duongDanAnh, khoCuaAnh } from './anh-duong-dan';
import { SupabaseService } from './supabase.service';

@Injectable()
export class AnhKyService {
  private readonly logger = new Logger(AnhKyService.name);

  constructor(private readonly supabase: SupabaseService) {}

  async kyLo(
    giaTri: readonly (string | null | undefined)[],
  ): Promise<Map<string, string>> {
    const theoKho = new Map<string, Set<string>>();
    for (const v of giaTri) {
      if (!v) continue;
      const kho = khoCuaAnh(v);
      if (!kho) continue;
      const nhom = theoKho.get(kho) ?? new Set<string>();
      nhom.add(v);
      theoKho.set(kho, nhom);
    }
    const ket = new Map<string, string>();
    await Promise.all(
      [...theoKho].map(([kho, tap]) => this.kyMotKho(kho, [...tap], ket)),
    );
    return ket;
  }

  private async kyMotKho(
    kho: string,
    can: string[],
    ket: Map<string, string>,
  ): Promise<void> {
    const duong = can.map(duongDanAnh);
    const { data, error } = await this.supabase
      .getClient()
      .storage.from(kho)
      .createSignedUrls(duong, GIAY_KY_ANH);
    if (error) {
      this.logger.error(
        `Không ký được ${duong.length} ảnh kho ${kho}: ${error.message}`,
      );
      return;
    }
    can.forEach((goc, i) => {
      const ky = data?.[i]?.signedUrl;
      if (ky) ket.set(goc, ky);
    });
  }

  async kyMang(giaTri: readonly string[]): Promise<string[]> {
    const ky = await this.kyLo(giaTri);
    return giaTri.map((v) => ky.get(v) ?? v);
  }

  async kyMot(giaTri: string | null): Promise<string | null> {
    if (!giaTri) return null;
    const ky = await this.kyLo([giaTri]);
    return ky.get(giaTri) ?? giaTri;
  }
}
