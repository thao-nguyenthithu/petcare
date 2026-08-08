import { Prisma } from '../../../generated/prisma/client';
import { SearchSittersDto } from './dto/search-sitters.dto';
import { dichVuTuTuKhoa, loaiBeEpTheoDichVu } from './sitter-search.helpers';


export function khoangNgay(dto: SearchSittersDto) {
  if (!dto.dateFrom || !dto.dateTo) return null;
  const tu = new Date(dto.dateFrom);
  const den = new Date(dto.dateTo);
  if (Number.isNaN(tu.getTime()) || Number.isNaN(den.getTime())) return null;
  if (den < tu) return null;
  const MOT_NGAY = 24 * 60 * 60 * 1000;
  const soNgay = Math.round((den.getTime() - tu.getTime()) / MOT_NGAY) + 1;
  return { tu, den, soNgay };
}

export function dieuKienTuKhoa(
  q: string,
  dieuKienDichVu: Prisma.SitterServiceWhereInput,
): Prisma.SitterWhereInput {
  const theoTen: Prisma.SitterWhereInput = {
    user: { fullName: { contains: q, mode: 'insensitive' } },
  };
  const loai = dichVuTuTuKhoa(q);
  if (loai === null) return theoTen;
  return {
    OR: [
      theoTen,
      {
        services: {
          some: {
            ...dieuKienDichVu,
            type: loai,
            ...dieuKienLoaiBe(loaiBeEpTheoDichVu(loai)),
          },
        },
      },
    ],
  };
}

export function dieuKienLoaiBe(
  loaiBe?: 'dog' | 'cat',
): Prisma.SitterServiceWhereInput {
  if (!loaiBe) return {};
  return { petKind: { in: [loaiBe === 'dog' ? 'DOG' : 'CAT', 'BOTH'] } };
}

export function coToaDo(dto: SearchSittersDto) {
  return (
    dto.lat !== undefined && dto.lng !== undefined && dto.radiusKm !== undefined
  );
}

export function doLech(km: number) {
  return km / 111;
}

export function doLechKinh(km: number, lat: number) {
  const heSo = Math.max(Math.cos((lat * Math.PI) / 180), 0.01);
  return km / (111 * heSo);
}
