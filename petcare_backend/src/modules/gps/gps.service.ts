import {
  BadRequestException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';
import { GpsBatchDto } from './dto/gps-batch.dto';
import { danhDauNoise, DiemGps } from './gps-noise';
import { lechDangKe, tiLeLech, tongQuangDuongKm } from './gps-quang-duong';
import { NGUONG_TOC_DO_TB_KMH, PHUT_AN_HAN_FLUSH_CUOI } from './gps.constants';

interface DonGps {
  id: string;
  ownerId: string;
  status: string;
  departedAt: Date | null;
  endedAt: Date | null;
  sitter: { userId: string };
  service: { type: string };
}

@Injectable()
export class GpsService {
  constructor(private readonly prisma: PrismaService) {}

  private timDon(bookingId: string): Promise<DonGps | null> {
    return this.prisma.booking.findUnique({
      where: { id: bookingId },
      select: {
        id: true,
        ownerId: true,
        status: true,
        departedAt: true,
        endedAt: true,
        sitter: { select: { userId: true } },
        service: { select: { type: true } },
      },
    });
  }

  private dangPhatSong(don: DonGps): boolean {
    if (don.service.type !== 'WALKING') return false;
    if (don.status === 'IN_PROGRESS') return true;
    return don.status === 'CONFIRMED' && don.departedAt !== null;
  }

  private nhanDuocBatch(don: DonGps): boolean {
    if (this.dangPhatSong(don)) return true;
    if (don.service.type !== 'WALKING') return false;
    if (don.status !== 'AWAITING_OWNER_CONFIRM' || !don.endedAt) return false;
    const anHanMs = PHUT_AN_HAN_FLUSH_CUOI * 60_000;
    return Date.now() - don.endedAt.getTime() <= anHanMs;
  }

  async duocVaoRoom(userId: string, bookingId: string): Promise<boolean> {
    const don = await this.timDon(bookingId);
    if (!don || don.service.type !== 'WALKING') return false;
    return don.ownerId === userId || don.sitter.userId === userId;
  }

  async duocPhatViTri(userId: string, bookingId: string): Promise<boolean> {
    const don = await this.timDon(bookingId);
    if (!don || don.sitter.userId !== userId) return false;
    return this.dangPhatSong(don);
  }

  async ghiBatch(userId: string, dto: GpsBatchDto) {
    const don = await this.timDon(dto.bookingId);
    if (!don || don.sitter.userId !== userId) {
      throw new NotFoundException({
        code: 'KHONG_TIM_THAY_DON',
        message: 'Không tìm thấy đơn',
      });
    }
    if (don.service.type !== 'WALKING') {
      throw new BadRequestException({
        code: 'DON_KHONG_PHAI_DAT_DI_DAO',
        message: 'Chỉ đơn dắt đi dạo mới ghi lộ trình GPS',
      });
    }
    if (!this.nhanDuocBatch(don)) {
      throw new BadRequestException({
        code: 'DON_NGOAI_PHIEN_DAT',
        message: 'Đơn không trong phiên dắt nên không nhận vị trí',
      });
    }

    const seqCu = await this.prisma.locationTrack.aggregate({
      where: { bookingId: don.id },
      _max: { batchSeq: true },
    });
    const batchSeq = (seqCu._max.batchSeq ?? 0) + 1;

    const diem: (DiemGps & { mocked: boolean })[] = dto.waypoints
      .map((w) => ({
        lat: w.lat,
        lng: w.lng,
        tsMs: Date.parse(w.clientTs),
        mocked: w.isMocked === true,
      }))
      .sort((a, b) => a.tsMs - b.tsMs);

    const diemCuoi = await this.prisma.locationTrack.findFirst({
      where: { bookingId: don.id, isNoise: false },
      orderBy: { clientTs: 'desc' },
      select: { latitude: true, longitude: true, clientTs: true },
    });
    const laNoise = danhDauNoise(
      diemCuoi
        ? {
            lat: diemCuoi.latitude,
            lng: diemCuoi.longitude,
            tsMs: diemCuoi.clientTs.getTime(),
          }
        : null,
      diem,
    );

    const serverTs = new Date();
    await this.prisma.locationTrack.createMany({
      data: diem.map((d, i) => ({
        bookingId: don.id,
        latitude: d.lat,
        longitude: d.lng,
        clientTs: new Date(d.tsMs),
        serverTs,
        driftMs: Math.abs(serverTs.getTime() - d.tsMs),
        batchSeq,
        isNoise: laNoise[i],
        isMocked: d.mocked,
      })),
    });

    if (don.endedAt) await this.chotBaoCao(don.id);

    return {
      batchSeq,
      soDiemGhi: diem.length,
      soDiemNoise: laNoise.filter(Boolean).length,
    };
  }

  async lichSuLoTrinh(userId: string, bookingId: string) {
    const don = await this.timDon(bookingId);
    if (!don || (don.ownerId !== userId && don.sitter.userId !== userId)) {
      throw new NotFoundException({
        code: 'KHONG_TIM_THAY_DON',
        message: 'Không tìm thấy đơn',
      });
    }
    if (don.service.type !== 'WALKING') {
      throw new BadRequestException({
        code: 'DON_KHONG_PHAI_DAT_DI_DAO',
        message: 'Chỉ đơn dắt đi dạo mới có lộ trình GPS',
      });
    }
    const diem = await this.prisma.locationTrack.findMany({
      where: { bookingId: don.id, isNoise: false },
      orderBy: { clientTs: 'asc' },
      select: { latitude: true, longitude: true, clientTs: true },
    });
    return {
      bookingId: don.id,
      diem: diem.map((d) => ({
        lat: d.latitude,
        lng: d.longitude,
        ts: d.clientTs.toISOString(),
      })),
    };
  }

  async chotBaoCao(bookingId: string): Promise<void> {
    const don = await this.prisma.booking.findUnique({
      where: { id: bookingId },
      select: {
        id: true,
        distanceKm: true,
        startedAt: true,
        endedAt: true,
        service: { select: { type: true } },
      },
    });
    if (!don || don.service.type !== 'WALKING') return;

    const diem = await this.prisma.locationTrack.findMany({
      where: { bookingId: don.id, isNoise: false },
      orderBy: { clientTs: 'asc' },
      select: { latitude: true, longitude: true, clientTs: true },
    });
    const km = tongQuangDuongKm(
      diem.map((d) => ({ lat: d.latitude, lng: d.longitude })),
    );
    const phut = this.phutPhien(don, diem);
    const kmApp = don.distanceKm;
    const lech = diem.length < 2 ? (kmApp ?? 0) > 0 : lechDangKe(km, kmApp);

    const [soDiemGia, daSoat] = await Promise.all([
      this.prisma.locationTrack.count({
        where: { bookingId: don.id, isMocked: true },
      }),
      this.prisma.bookingGpsReport.findUnique({
        where: { bookingId: don.id },
        select: { reviewedAt: true },
      }),
    ]);
    const tocDoTb = phut > 0 ? Math.round((km / (phut / 60)) * 10) / 10 : 0;
    const chayXe = tocDoTb > NGUONG_TOC_DO_TB_KMH;
    const canXem = lech || chayXe || soDiemGia > 0;

    const soLieu = {
      totalWaypoints: diem.length,
      totalDistanceM: Math.round(km * 1000),
      durationMinutes: phut,
      avgSpeedKmh: tocDoTb,
      suspicionScore: tiLeLech(km, kmApp),
      mockedCount: soDiemGia,
      speedFlag: chayXe,
    };
    const ketLuanMay = {
      flaggedForReview: canXem,
      suspicionNote: canXem
        ? this.ghiChuNghiNgo(diem.length, km, kmApp, lech, tocDoTb, soDiemGia)
        : null,
    };
    await this.prisma.bookingGpsReport.upsert({
      where: { bookingId: don.id },
      create: { bookingId: don.id, ...soLieu, ...ketLuanMay },
      update: daSoat?.reviewedAt ? soLieu : { ...soLieu, ...ketLuanMay },
    });
  }

  private phutPhien(
    don: { startedAt: Date | null; endedAt: Date | null },
    diem: { clientTs: Date }[],
  ): number {
    const dau = don.startedAt ?? diem.at(0)?.clientTs ?? null;
    const cuoi = don.endedAt ?? diem.at(-1)?.clientTs ?? null;
    if (!dau || !cuoi) return 0;
    return Math.max(0, Math.round((cuoi.getTime() - dau.getTime()) / 60_000));
  }

  private ghiChuNghiNgo(
    soDiem: number,
    km: number,
    kmApp: number | null,
    lech: boolean,
    tocDoTb: number,
    soDiemGia: number,
  ): string {
    const y: string[] = [];
    if (lech) {
      const soApp = (kmApp ?? 0).toFixed(1);
      y.push(
        soDiem < 2
          ? `Server không nhận được lộ trình nào, app báo đã đi ${soApp} km`
          : `App báo ${soApp} km, lộ trình về tới server ${km.toFixed(1)} km`,
      );
    }
    if (tocDoTb > NGUONG_TOC_DO_TB_KMH) {
      y.push(
        `Tốc độ trung bình cả lượt ${tocDoTb} km/h, vượt mức đi bộ ${NGUONG_TOC_DO_TB_KMH} km/h`,
      );
    }
    if (soDiemGia > 0) {
      y.push(`Có ${soDiemGia} điểm bị hệ điều hành báo là vị trí giả`);
    }
    return y.join('. ');
  }
}
