import { Injectable } from '@nestjs/common';
import { ServiceType } from '../../../../generated/prisma/enums';
import { PrismaService } from '../../../prisma/prisma.service';
import { AnhKyService } from '../../media/anh-ky.service';
import {
  dungTrang,
  KetQuaTrang,
  kepTrang,
  KhoangTrang,
} from '../chung/phan-trang';
import { KieuBaoSuCo, kieuBaoSuCo } from './anh-bang-chung';
import { LocAnhDto, NguonAnh } from './dto/loc-anh.dto';

// Danh sách CỐ Ý không kèm tên hay liên lạc của hai vai: mã đơn là đủ để lần ra hồ sơ
export type AnhBangChung = {
  id: string;
  source: NguonAnh;
  bookingCode: string;
  serviceType: ServiceType;
  serviceName: string;
  url: string;
  phase: string | null;
  takenAt: Date;
  photoLat: number | null;
  photoLng: number | null;
  conditions: string[];
  anhDoDung: boolean;
  anhVanXa: boolean;
  aiConfidenceScore: number | null;
  aiPassed: boolean | null;
  reportKind: KieuBaoSuCo | null;
};

type DongChung = {
  id: string;
  url: string;
  takenAt: Date;
  bookingCode: string;
  serviceName: string;
  serviceType: ServiceType;
};

type DongPhien = DongChung & {
  phase: string;
  anhDoDung: boolean;
  anhVanXa: boolean;
  photoLat: number | null;
  photoLng: number | null;
  aiConfidenceScore: number | null;
  aiPassed: boolean | null;
};

type DongNhatKy = DongChung & { conditions: string[] };

type DongSuCo = DongChung & { status: string; gearReportedAt: Date | null };

type DongDem = { tong: number };

const KHONG_CHAM_DIEM = { aiConfidenceScore: null, aiPassed: null } as const;

@Injectable()
export class AdminEvidenceReadService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly kyAnh: AnhKyService,
  ) {}

  async danhSach(loc: LocAnhDto): Promise<KetQuaTrang<AnhBangChung>> {
    const khoang = kepTrang(loc.page, loc.limit);
    const nguon = loc.source ?? 'session';
    const trang =
      nguon === 'boarding'
        ? await this.nhatKyGiu(khoang)
        : nguon === 'noShow'
          ? await this.baoSuCo(khoang)
          : await this.anhPhien(khoang);
    // Ký cả trang trong MỘT lượt, ký từng ô lưới là một lượt mạng mỗi tấm
    const ky = await this.kyAnh.kyLo(trang.items.map((a) => a.url));
    return {
      ...trang,
      items: trang.items.map((a) => ({ ...a, url: ky.get(a.url) ?? a.url })),
    };
  }

  async demNguon() {
    const [session, boarding, noShow, gpsFlagged] = await Promise.all([
      this.prisma.sessionPhoto.count(),
      this.demAnhNhatKy(),
      this.demAnhSuCo(),
      // Đúng điều kiện hàng chờ soát lộ trình của màn 09b, tab này dẫn thẳng sang đó
      this.prisma.bookingGpsReport.count({
        where: { flaggedForReview: true, reviewedAt: null },
      }),
    ]);
    return { session, boarding, noShow, gpsFlagged };
  }

  // Cộng độ dài mảng ngay trong database, kéo cả cột về Node rồi đếm là chở thừa mọi đường dẫn
  private async demAnhNhatKy(): Promise<number> {
    const [dong] = await this.prisma.$queryRaw<DongDem[]>`
      SELECT COALESCE(SUM(COALESCE(array_length("photoUrls", 1), 0)), 0)::int AS tong
      FROM "BoardingUpdate"`;
    return dong?.tong ?? 0;
  }

  private async demAnhSuCo(): Promise<number> {
    const [dong] = await this.prisma.$queryRaw<DongDem[]>`
      SELECT COALESCE(SUM(array_length("noShowProofUrls", 1)), 0)::int AS tong
      FROM "Booking"
      WHERE "noShowProofUrls" <> '{}'`;
    return dong?.tong ?? 0;
  }

  private async anhPhien(
    khoang: KhoangTrang,
  ): Promise<KetQuaTrang<AnhBangChung>> {
    const [tong, ds] = await Promise.all([
      this.prisma.sessionPhoto.count(),
      this.prisma.$queryRaw<DongPhien[]>`
        SELECT sp.id,
               sp."photoUrl" AS url,
               sp.phase::text AS phase,
               sp."anhDoDung",
               sp."anhVanXa",
               sp."photoLat",
               sp."photoLng",
               sp."takenAt",
               sp."aiConfidenceScore",
               sp."aiPassed",
               b.code AS "bookingCode",
               sv.name AS "serviceName",
               sv.type::text AS "serviceType"
        FROM "SessionPhoto" sp
        JOIN "Booking" b ON b.id = sp."bookingId"
        JOIN "Service" sv ON sv.id = b."serviceId"
        ORDER BY sp."takenAt" DESC, sp.id
        LIMIT ${khoang.moiTrang} OFFSET ${khoang.boQua}`,
    ]);

    const items = ds.map((d) => ({
      ...this.phanChung(d, 'session'),
      phase: d.phase,
      photoLat: d.photoLat,
      photoLng: d.photoLng,
      conditions: [],
      anhDoDung: d.anhDoDung,
      anhVanXa: d.anhVanXa,
      // Chưa qua AI thì để RỖNG, số 0 là kết luận máy không đọc được gì (bộ luật mục 8)
      aiConfidenceScore: d.aiConfidenceScore,
      aiPassed: d.aiPassed,
      reportKind: null,
    }));
    return dungTrang(items, tong, khoang);
  }

  // Mỗi bản cập nhật giữ nhiều đường dẫn trong một mảng, trải ra mới phân trang được theo ẢNH
  private async nhatKyGiu(
    khoang: KhoangTrang,
  ): Promise<KetQuaTrang<AnhBangChung>> {
    const [tong, ds] = await Promise.all([
      this.demAnhNhatKy(),
      this.prisma.$queryRaw<DongNhatKy[]>`
        SELECT bu.id || '-' || u.ord AS id,
               u.url,
               bu."createdAt" AS "takenAt",
               bu.conditions,
               b.code AS "bookingCode",
               sv.name AS "serviceName",
               sv.type::text AS "serviceType"
        FROM "BoardingUpdate" bu
        CROSS JOIN LATERAL unnest(bu."photoUrls") WITH ORDINALITY AS u(url, ord)
        JOIN "Booking" b ON b.id = bu."bookingId"
        JOIN "Service" sv ON sv.id = b."serviceId"
        ORDER BY bu."createdAt" DESC, bu.id, u.ord
        LIMIT ${khoang.moiTrang} OFFSET ${khoang.boQua}`,
    ]);

    const items = ds.map((d) => ({
      ...this.phanChung(d, 'boarding'),
      phase: null,
      // Bản nhật ký không kèm toạ độ, ép một con số vào đây là bịa vị trí
      photoLat: null,
      photoLng: null,
      conditions: d.conditions,
      anhDoDung: false,
      anhVanXa: false,
      ...KHONG_CHAM_DIEM,
      reportKind: null,
    }));
    return dungTrang(items, tong, khoang);
  }

  private async baoSuCo(
    khoang: KhoangTrang,
  ): Promise<KetQuaTrang<AnhBangChung>> {
    const [tong, ds] = await Promise.all([
      this.demAnhSuCo(),
      this.prisma.$queryRaw<DongSuCo[]>`
        SELECT b.id || '-' || u.ord AS id,
               u.url,
               COALESCE(b."cancelledAt", b."gearReportedAt", b."updatedAt") AS "takenAt",
               b.status::text AS status,
               b."gearReportedAt",
               b.code AS "bookingCode",
               sv.name AS "serviceName",
               sv.type::text AS "serviceType"
        FROM "Booking" b
        CROSS JOIN LATERAL unnest(b."noShowProofUrls") WITH ORDINALITY AS u(url, ord)
        JOIN "Service" sv ON sv.id = b."serviceId"
        ORDER BY "takenAt" DESC, b.id, u.ord
        LIMIT ${khoang.moiTrang} OFFSET ${khoang.boQua}`,
    ]);

    const items = ds.map((d) => ({
      ...this.phanChung(d, 'noShow'),
      phase: null,
      photoLat: null,
      photoLng: null,
      conditions: [],
      anhDoDung: false,
      anhVanXa: false,
      ...KHONG_CHAM_DIEM,
      reportKind: kieuBaoSuCo(d.status, d.gearReportedAt),
    }));
    return dungTrang(items, tong, khoang);
  }

  private phanChung(d: DongChung, source: NguonAnh) {
    return {
      id: d.id,
      source,
      bookingCode: d.bookingCode,
      serviceType: d.serviceType,
      serviceName: d.serviceName,
      url: d.url,
      takenAt: d.takenAt,
    };
  }
}
