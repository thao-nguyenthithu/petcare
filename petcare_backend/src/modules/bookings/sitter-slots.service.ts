import {
  BadRequestException,
  ForbiddenException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { Prisma } from 'generated/prisma/client';
import { BookingStatus } from 'generated/prisma/enums';
import {
  MOT_NGAY_MS,
  dauNgayVn,
  khoaNgayVn,
  khoaTuNgayDb,
  ngayDb,
  soNgayLech,
  themNgay,
  thuTrongTuanVn,
} from '../../common/thoi-gian-vn';
import { PrismaService } from '../../prisma/prisma.service';
import {
  TRAN_DON_XEM,
  TRAN_NGAY_XEM,
} from '../sitter/schedule/schedule-shared';
import { dieuKienNccCongKhai } from '../sitter/public/sitter-public';
import { demTrongGiu, khoangBanCuaDon } from './slot-khoang-ban';
import { conGiuCho, hanGiuCho, mocGuiNguoiCham } from './booking-time';
import { sucChuaTrongGiu as sucChuaTuPricing } from './booking-pricing';

const TRANG_THAI_CHIEM_CHO: BookingStatus[] = [
  'CONFIRMED',
  'IN_PROGRESS',
  'AWAITING_OWNER_CONFIRM',
];

const TRANG_THAI_BE_BAN: BookingStatus[] = [
  'AWAITING_PAYMENT',
  'PENDING',
  'CONFIRMED',
  'IN_PROGRESS',
  'AWAITING_OWNER_CONFIRM',
];

type DbClient = Prisma.TransactionClient;

export type KhoangBan = { start: string; end: string };

export type NgayLich = {
  date: string;
  closed: boolean;
  start: string;
  end: string;
  busy: KhoangBan[];
  boardingLeft: number;
  petBusy: KhoangBan[];
  petBusyAllDay: boolean;
};

export type LichTrong = {
  workStart: string;
  workEnd: string;
  workDays: number[];
  boardingCapacity: number;
  days: NgayLich[];
};

export type DonChiemCho = {
  status: BookingStatus;
  createdAt: Date;
  paidAt: Date | null;
  scheduledAt: Date;
  scheduledEndAt: Date | null;
  durationMinutes: number | null;
  service: { type: string; durationMinutes: number | null };
  _count: { pets: number };
};

export function conHieuLuc(don: DonChiemCho): boolean {
  if (don.status === 'AWAITING_PAYMENT') {
    return Date.now() < hanGiuCho(don.createdAt).getTime();
  }
  return (
    don.status !== 'PENDING' ||
    conGiuCho(mocGuiNguoiCham(don), don.scheduledAt, Date.now())
  );
}

@Injectable()
export class SitterSlotsService {
  constructor(private readonly prisma: PrismaService) {}

  async layNccCongKhai(sitterId: string, db?: DbClient, xemBoiUserId?: string) {
    const ncc = await (db ?? this.prisma).sitter.findFirst({
      where: { id: sitterId, ...dieuKienNccCongKhai() },
      select: {
        id: true,
        userId: true,
        status: true,
        workStart: true,
        workEnd: true,
        workDays: true,
        lat: true,
        lng: true,
        serviceRadiusKm: true,
      },
    });
    if (!ncc) {
      throw new NotFoundException({
        code: 'KHONG_TIM_THAY_NCC',
        message: 'Không tìm thấy nhà cung cấp',
      });
    }
    if (xemBoiUserId && ncc.userId === xemBoiUserId) {
      throw new ForbiddenException({
        code: 'KHONG_TU_DAT_CHINH_MINH',
        message: 'Bạn không thể đặt lịch với chính hồ sơ người chăm của mình',
      });
    }
    return ncc;
  }

  async layLich(
    sitterId: string,
    from: string,
    to: string,
    opts: {
      petIds?: string[];
      ownerId?: string;
      db?: DbClient;
      xemBoiUserId?: string;
    } = {},
  ): Promise<LichTrong> {
    const db = opts.db;
    const c = db ?? this.prisma;
    const ncc = await this.layNccCongKhai(sitterId, db, opts.xemBoiUserId);
    const soNgay = soNgayLech(from, to) + 1;
    if (soNgay < 1) {
      throw new BadRequestException({
        code: 'KHOANG_KHONG_HOP_LE',
        message: 'Ngày kết thúc phải từ ngày bắt đầu trở đi',
      });
    }
    if (soNgay > TRAN_NGAY_XEM) {
      throw new BadRequestException({
        code: 'KHOANG_QUA_DAI',
        message: `Chỉ xem được tối đa ${TRAN_NGAY_XEM} ngày mỗi lần`,
      });
    }

    const tuUtc = dauNgayVn(from);
    const denUtc = new Date(dauNgayVn(to).getTime() + MOT_NGAY_MS);
    const [thietLap, donThoTat, sucChua] = await Promise.all([
      c.sitterDaySetting.findMany({
        where: {
          sitterId: ncc.id,
          date: { gte: ngayDb(from), lte: ngayDb(to) },
        },
        select: {
          date: true,
          mode: true,
          startTime: true,
          endTime: true,
          boardingSlots: true,
        },
      }),
      c.booking.findMany({
        where: {
          sitterId: ncc.id,
          status: { in: TRANG_THAI_CHIEM_CHO },
          scheduledAt: { lt: denUtc },
          OR: [
            { scheduledEndAt: { gte: tuUtc } },
            { scheduledEndAt: null, scheduledAt: { gte: tuUtc } },
          ],
        },
        select: {
          status: true,
          createdAt: true,
          paidAt: true,
          scheduledAt: true,
          scheduledEndAt: true,
          durationMinutes: true,
          service: { select: { type: true, durationMinutes: true } },
          _count: { select: { pets: true } },
        },
        take: TRAN_DON_XEM,
      }),
      this.sucChuaTrongGiu(ncc.id, db),
    ]);
    const donCuaBe = await this.donCuaBe(
      opts.petIds ?? [],
      opts.ownerId,
      tuUtc,
      denUtc,
      db,
    );

    const don = donThoTat.filter(conHieuLuc);

    const thietLapTheoNgay = new Map(
      thietLap.map((e) => [khoaTuNgayDb(e.date), e]),
    );
    const banTheoNgay = new Map<string, KhoangBan[]>();
    const trongGiuTheoNgay = new Map<string, number>();
    for (const d of don) {
      if (d.service.type === 'BOARDING') {
        const soBe = Math.max(d._count.pets, 1);
        for (const ngay of demTrongGiu(d)) {
          trongGiuTheoNgay.set(ngay, (trongGiuTheoNgay.get(ngay) ?? 0) + soBe);
        }
        continue;
      }
      const ban = khoangBanCuaDon(d);
      if (!ban) continue;
      const ds = banTheoNgay.get(ban.ngay) ?? [];
      ds.push({ start: ban.start, end: ban.end });
      banTheoNgay.set(ban.ngay, ds);
    }

    const beBanTheoNgay = new Map<string, KhoangBan[]>();
    const beBanCaNgay = new Set<string>();
    for (const d of donCuaBe) {
      if (d.service.type === 'BOARDING') {
        for (const ngay of demTrongGiu(d)) beBanCaNgay.add(ngay);
        if (d.scheduledEndAt) beBanCaNgay.add(khoaNgayVn(d.scheduledEndAt));
        continue;
      }
      const ban = khoangBanCuaDon(d);
      if (!ban) continue;
      const ds = beBanTheoNgay.get(ban.ngay) ?? [];
      ds.push({ start: ban.start, end: ban.end });
      beBanTheoNgay.set(ban.ngay, ds);
    }

    const days: NgayLich[] = [];
    for (let i = 0; i < soNgay; i++) {
      const ngay = themNgay(from, i);
      const tl = thietLapTheoNgay.get(ngay);
      // Giờ riêng mở được cả thứ vốn nghỉ, khỏi phải bật cả 52 chủ nhật (bộ luật mục 10)
      const nghi =
        tl?.mode === 'OFF' ||
        (tl?.mode !== 'CUSTOM_HOURS' &&
          !ncc.workDays.includes(thuTrongTuanVn(ngay)));
      const batDau =
        tl?.mode === 'CUSTOM_HOURS' && tl.startTime
          ? tl.startTime
          : ncc.workStart;
      const ketThuc =
        tl?.mode === 'CUSTOM_HOURS' && tl.endTime ? tl.endTime : ncc.workEnd;
      const choMoTrongNgay = nghi ? 0 : (tl?.boardingSlots ?? sucChua);
      const daNhan = trongGiuTheoNgay.get(ngay) ?? 0;
      days.push({
        date: ngay,
        closed: nghi,
        start: batDau,
        end: ketThuc,
        busy: (banTheoNgay.get(ngay) ?? []).sort((a, b) =>
          a.start.localeCompare(b.start),
        ),
        boardingLeft: Math.max(Math.min(choMoTrongNgay, sucChua) - daNhan, 0),
        petBusy: (beBanTheoNgay.get(ngay) ?? []).sort((a, b) =>
          a.start.localeCompare(b.start),
        ),
        petBusyAllDay: beBanCaNgay.has(ngay),
      });
    }

    return {
      workStart: ncc.workStart,
      workEnd: ncc.workEnd,
      workDays: [...ncc.workDays].sort((a, b) => a - b),
      boardingCapacity: sucChua,
      days,
    };
  }

  async donCuaBe(
    petIds: string[],
    ownerId: string | undefined,
    tuUtc: Date,
    denUtc: Date,
    db?: DbClient,
  ): Promise<DonChiemCho[]> {
    if (petIds.length === 0 || !ownerId) return [];
    const don = await (db ?? this.prisma).booking.findMany({
      where: {
        ownerId,
        status: { in: TRANG_THAI_BE_BAN },
        pets: { some: { petId: { in: petIds } } },
        scheduledAt: { lt: denUtc },
        OR: [
          { scheduledEndAt: { gte: tuUtc } },
          { scheduledEndAt: null, scheduledAt: { gte: tuUtc } },
        ],
      },
      select: {
        status: true,
        createdAt: true,
        paidAt: true,
        scheduledAt: true,
        scheduledEndAt: true,
        durationMinutes: true,
        service: { select: { type: true, durationMinutes: true } },
        _count: { select: { pets: true } },
      },
      take: TRAN_DON_XEM,
    });
    return don.filter(conHieuLuc);
  }

  async sucChuaTrongGiu(sitterId: string, db?: DbClient): Promise<number> {
    const dv = await (db ?? this.prisma).sitterService.findUnique({
      where: { sitterId_type: { sitterId, type: 'BOARDING' } },
      select: { enabled: true, pricing: true },
    });
    if (!dv?.enabled) return 0;
    return sucChuaTuPricing((dv.pricing as Record<string, unknown>) ?? {});
  }
}
