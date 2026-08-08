import { Injectable, Logger } from '@nestjs/common';
import {
  MOT_NGAY_MS,
  dauNgayVn,
  gioVn,
  khoaNgayVn,
  khoaTuNgayDb,
  ngayDb,
  soNgayLech,
  themNgay,
} from '../../../common/thoi-gian-vn';
import { PrismaService } from '../../../prisma/prisma.service';
import { demTrongGiu } from '../../bookings/slot-khoang-ban';
import {
  CHE_DO_RA_APP,
  DonCuaLich,
  DongLich,
  PhanNgayTrongGiu,
  TRAN_DON_XEM,
  TRAN_NGAY_MOT_DON,
  TRAN_NGAY_XEM,
  TRANG_THAI_RA_APP,
  TRANG_THAI_TREN_LICH,
  kiemTraKhoang,
  layNccCuaToi,
  sucChuaTrongGiu,
} from './schedule-shared';

@Injectable()
export class ScheduleViewService {
  private readonly logger = new Logger(ScheduleViewService.name);

  constructor(private readonly prisma: PrismaService) {}

  async xemLich(userId: string, from: string, to: string) {
    kiemTraKhoang(from, to, TRAN_NGAY_XEM);
    const tuUtc = dauNgayVn(from);
    const denUtc = new Date(dauNgayVn(to).getTime() + MOT_NGAY_MS);

    // Lọc thẳng theo userId để cả bốn truy vấn chạy cùng lúc
    const [ncc, thietLap, don, sucChua] = await Promise.all([
      layNccCuaToi(this.prisma, userId),
      this.prisma.sitterDaySetting.findMany({
        where: {
          sitter: { userId },
          date: { gte: ngayDb(from), lte: ngayDb(to) },
        },
      }),
      this.prisma.booking.findMany({
        where: {
          sitter: { userId },
          status: { in: TRANG_THAI_TREN_LICH },
          scheduledAt: { lt: denUtc },
          OR: [
            { scheduledEndAt: { gte: tuUtc } },
            { scheduledEndAt: null, scheduledAt: { gte: tuUtc } },
          ],
        },
        select: {
          id: true,
          code: true,
          status: true,
          scheduledAt: true,
          scheduledEndAt: true,
          service: {
            select: { name: true, type: true, durationMinutes: true },
          },
          owner: { select: { fullName: true } },
          pets: {
            select: {
              pet: { select: { name: true, species: true, avatarUrl: true } },
            },
          },
        },
        orderBy: { scheduledAt: 'asc' },
        take: TRAN_DON_XEM,
      }),
      sucChuaTrongGiu(this.prisma, userId),
    ]);

    if (don.length >= TRAN_DON_XEM) {
      this.logger.warn(
        `Lịch của người chăm ${userId} chạm trần ${TRAN_DON_XEM} đơn mỗi lượt dựng, khoảng ${from} đến ${to} có thể thiếu đơn`,
      );
    }

    const donTheoNgay = new Map<string, DongLich[]>();
    for (const d of don) {
      for (const dong of this.traiRaTungNgay(d, ncc.workStart, ncc.workEnd)) {
        if (dong.ngay < from || dong.ngay > to) continue;
        const ds = donTheoNgay.get(dong.ngay) ?? [];
        ds.push(dong.appt);
        donTheoNgay.set(dong.ngay, ds);
      }
    }

    const thietLapTheoNgay = new Map(
      thietLap.map((e) => [khoaTuNgayDb(e.date), e]),
    );
    const beTrongGiuTheoNgay = new Map<string, number>();
    for (const d of don) {
      if (d.service.type !== 'BOARDING' || d.status === 'COMPLETED') continue;
      const soBe = Math.max(d.pets.length, 1);
      for (const ngay of demTrongGiu(d)) {
        beTrongGiuTheoNgay.set(
          ngay,
          (beTrongGiuTheoNgay.get(ngay) ?? 0) + soBe,
        );
      }
    }
    const cacNgay = [
      ...new Set([...donTheoNgay.keys(), ...thietLapTheoNgay.keys()]),
    ].sort();

    return {
      workStart: ncc.workStart,
      workEnd: ncc.workEnd,
      workDays: [...ncc.workDays].sort((a, b) => a - b),
      boardingCapacity: sucChua,
      days: cacNgay.map((ngay) => {
        const tl = thietLapTheoNgay.get(ngay);
        const appts = donTheoNgay.get(ngay) ?? [];
        return {
          date: ngay,
          mode: tl ? CHE_DO_RA_APP[tl.mode] : 'default',
          start: tl?.startTime ?? null,
          end: tl?.endTime ?? null,
          boardingSlots: tl?.boardingSlots ?? null,
          boardingUsed: beTrongGiuTheoNgay.get(ngay) ?? 0,
          reason: tl?.reason ?? null,
          appointments: appts.sort((a, b) =>
            a.startTime.localeCompare(b.startTime),
          ),
        };
      }),
    };
  }

  // Một dòng lịch của một ngày cụ thể
  private raDongLich(
    don: DonCuaLich,
    startTime: string,
    endTime: string,
    ngayThu: number,
    tongNgay: number,
    dayPart: PhanNgayTrongGiu | null,
  ): DongLich {
    return {
      id: don.id,
      code: don.code,
      startTime,
      endTime,
      dayPart,
      serviceName: don.service.name,
      serviceType: don.service.type.toLowerCase(),
      status: TRANG_THAI_RA_APP[don.status] ?? 'sapToi',
      ownerName: don.owner.fullName,
      district: null as string | null,
      pets: don.pets.map((e) => ({
        name: e.pet.name,
        species: e.pet.species === 'CAT' ? 'cat' : 'dog',
        avatarUrl: e.pet.avatarUrl,
      })),
      ngayThu,
      tongNgay,
    };
  }

  private traiRaTungNgay(don: DonCuaLich, workStart: string, workEnd: string) {
    const ketThuc =
      don.scheduledEndAt ??
      new Date(
        don.scheduledAt.getTime() +
          (don.service.durationMinutes ?? 60) * 60 * 1000,
      );
    const ngayDau = khoaNgayVn(don.scheduledAt);
    let ngayCuoi = khoaNgayVn(ketThuc);
    let gioCuoi = gioVn(ketThuc);
    if (gioCuoi === '00:00' && ngayCuoi !== ngayDau) {
      ngayCuoi = themNgay(ngayCuoi, -1);
      gioCuoi = workEnd;
    }
    const tongNgay = Math.min(
      Math.max(soNgayLech(ngayDau, ngayCuoi) + 1, 1),
      TRAN_NGAY_MOT_DON,
    );
    const ketQua: { ngay: string; appt: DongLich }[] = [];
    const keoQuaDem = tongNgay > 1;
    for (let i = 0; i < tongNgay; i++) {
      const ngay = themNgay(ngayDau, i);
      const batDau = i === 0 ? gioVn(don.scheduledAt) : workStart;
      const ket = i === tongNgay - 1 ? gioCuoi : workEnd;
      const phanNgay: PhanNgayTrongGiu | null = !keoQuaDem
        ? null
        : i === 0
          ? 'nhan'
          : i === tongNgay - 1
            ? 'tra'
            : 'troc';
      ketQua.push({
        ngay,
        appt: this.raDongLich(don, batDau, ket, i + 1, tongNgay, phanNgay),
      });
    }
    return ketQua;
  }
}
