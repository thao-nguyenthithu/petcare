import { Injectable } from '@nestjs/common';
import { Prisma } from '../../../../generated/prisma/client';
import { ServiceType } from '../../../../generated/prisma/enums';
import { PrismaService } from '../../../prisma/prisma.service';
import { dungTrang, KetQuaTrang, kepTrang } from '../chung/phan-trang';
import { LocCauHinhDto } from './dto/loc-dich-vu.dto';
import { doiBangGia, RANG_BUOC_DICH_VU } from './rang-buoc-dich-vu';

const LOAI_DICH_VU: ServiceType[] = [
  ServiceType.WALKING,
  ServiceType.BOARDING,
  ServiceType.GROOMING,
];

@Injectable()
export class AdminServicesReadService {
  constructor(private readonly prisma: PrismaService) {}

  async danhMuc() {
    const [ds, dem] = await Promise.all([
      this.prisma.service.findMany({
        select: { id: true, type: true, name: true, description: true },
      }),
      this.prisma.sitterService.groupBy({
        by: ['type'],
        where: { enabled: true },
        _count: { _all: true },
      }),
    ]);

    const theoLoai = new Map(ds.map((d) => [d.type, d]));
    const soBat = new Map(dem.map((d) => [d.type, d._count._all]));
    // Dòng danh mục chỉ sinh khi có đơn đầu tiên, loại chưa có đơn vẫn phải hiện ra
    const items = LOAI_DICH_VU.map((type) => {
      const dong = theoLoai.get(type);
      return {
        id: dong?.id ?? null,
        type,
        name: dong?.name ?? null,
        description: dong?.description ?? null,
        enabledSitterCount: soBat.get(type) ?? 0,
      };
    });
    return { items };
  }

  rangBuoc() {
    return { items: RANG_BUOC_DICH_VU };
  }

  private dieuKien(loc: LocCauHinhDto): Prisma.SitterServiceWhereInput {
    const dieu: Prisma.SitterServiceWhereInput = {};
    if (loc.type) dieu.type = loc.type;
    if (loc.enabled !== undefined) dieu.enabled = loc.enabled;
    if (loc.q) {
      const tim = { contains: loc.q, mode: Prisma.QueryMode.insensitive };
      dieu.sitter = {
        OR: [{ legalName: tim }, { user: { fullName: tim } }],
      };
    }
    return dieu;
  }

  async cauHinh(loc: LocCauHinhDto): Promise<KetQuaTrang<unknown>> {
    const khoang = kepTrang(loc.page, loc.limit);
    const where = this.dieuKien(loc);

    const [total, ds] = await Promise.all([
      this.prisma.sitterService.count({ where }),
      this.prisma.sitterService.findMany({
        where,
        orderBy: { updatedAt: 'desc' },
        skip: khoang.boQua,
        take: khoang.moiTrang,
        select: {
          id: true,
          sitterId: true,
          type: true,
          enabled: true,
          petKind: true,
          pricing: true,
          updatedAt: true,
          // Chỉ tên hiện bảng, email và số điện thoại là trường riêng tư của người chăm
          sitter: { select: { user: { select: { fullName: true } } } },
        },
      }),
    ]);

    const items = ds.map((d) => ({
      id: d.id,
      sitterId: d.sitterId,
      sitterName: d.sitter.user.fullName,
      type: d.type,
      enabled: d.enabled,
      petKind: d.petKind,
      pricing: doiBangGia(d.type, d.pricing),
      updatedAt: d.updatedAt,
    }));
    return dungTrang(items, total, khoang);
  }
}
