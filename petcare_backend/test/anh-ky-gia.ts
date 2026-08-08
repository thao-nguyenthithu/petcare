import { AnhKyService } from '../src/modules/media/anh-ky.service';
import { khoCuaAnh } from '../src/modules/media/anh-duong-dan';

// Ký giả cho các spec khác: ghi lại TỪNG LƯỢT ký để bắt được kiểu ký trong vòng lặp
export function anhKyGia() {
  const luot: string[][] = [];
  const kyLo = (giaTri: readonly (string | null | undefined)[]) => {
    const can = [
      ...new Set(
        giaTri.filter((v): v is string => Boolean(v) && khoCuaAnh(v!) !== null),
      ),
    ];
    luot.push(can);
    return Promise.resolve(new Map(can.map((v) => [v, `ky://${v}`])));
  };
  const service = {
    kyLo,
    kyMang: async (giaTri: readonly string[]) => {
      const ky = await kyLo(giaTri);
      return giaTri.map((v) => ky.get(v) ?? v);
    },
    kyMot: async (giaTri: string | null) => {
      if (!giaTri) return null;
      const ky = await kyLo([giaTri]);
      return ky.get(giaTri) ?? giaTri;
    },
  };
  return { luot, service: service as unknown as AnhKyService };
}
