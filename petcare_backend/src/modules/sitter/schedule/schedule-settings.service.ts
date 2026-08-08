import {
  BadRequestException,
  ConflictException,
  Injectable,
} from '@nestjs/common';
import { BookingStatus } from 'generated/prisma/enums';
import {
  MOT_NGAY_MS,
  dauNgayVn,
  homNayVn,
  khoaNgayVn,
  khoaTuNgayDb,
  ngayDb,
  soNgayLech,
  themNgay,
  truocHoacBang,
} from '../../../common/thoi-gian-vn';
import { PrismaService } from '../../../prisma/prisma.service';
import { demTrongGiu } from '../../bookings/slot-khoang-ban';
import { BlockDaysOffDto } from './dto/block-days-off.dto';
import { UpdateDayAvailabilityDto } from './dto/update-day-availability.dto';
import { UpdateWorkingHoursDto } from './dto/update-working-hours.dto';
import {
  CHE_DO_RA_APP,
  CHE_DO_RA_DB,
  TRAN_DON_XEM,
  TRAN_NGAY_DA_CHINH,
  TRAN_NGAY_MOT_DON,
  TRAN_NGAY_NGHI,
  TRANG_THAI_CON_HIEU_LUC,
  kiemTraKhoang,
  layNccCuaToi,
  sucChuaTrongGiu,
} from './schedule-shared';

@Injectable()
export class ScheduleSettingsService {
  constructor(private readonly prisma: PrismaService) {}

  async luuGioLamViec(userId: string, dto: UpdateWorkingHoursDto) {
    await layNccCuaToi(this.prisma, userId);
    if (dto.workDays.length === 0) {
      throw new BadRequestException({
        code: 'CHUA_CHON_NGAY_LAM_VIEC',
        message: 'Chọn ít nhất một ngày làm việc trong tuần',
      });
    }
    if (truocHoacBang(dto.workEnd, dto.workStart)) {
      throw new BadRequestException({
        code: 'GIO_KHONG_HOP_LE',
        message: 'Giờ kết thúc phải sau giờ bắt đầu',
      });
    }
    const ncc = await this.prisma.sitter.update({
      where: { userId },
      data: {
        workStart: dto.workStart,
        workEnd: dto.workEnd,
        workDays: [...dto.workDays].sort((a, b) => a - b),
      },
      select: { workStart: true, workEnd: true, workDays: true },
    });
    return ncc;
  }

  // Đơn chưa xong của một khoảng, gom theo ngày VN
  private async donConHieuLuc(sitterId: string, tu: string, den: string) {
    const tuUtc = dauNgayVn(tu);
    const denUtc = new Date(dauNgayVn(den).getTime() + MOT_NGAY_MS);
    const don = await this.prisma.booking.findMany({
      where: {
        sitterId,
        status: { in: TRANG_THAI_CON_HIEU_LUC },
        scheduledAt: { lt: denUtc },
        OR: [
          { scheduledEndAt: { gte: tuUtc } },
          { scheduledEndAt: null, scheduledAt: { gte: tuUtc } },
        ],
      },
      select: {
        id: true,
        status: true,
        scheduledAt: true,
        scheduledEndAt: true,
        service: { select: { durationMinutes: true } },
      },
      take: TRAN_DON_XEM,
    });
    const theoNgay = new Map<string, BookingStatus[]>();
    for (const d of don) {
      const ketThuc =
        d.scheduledEndAt ??
        new Date(
          d.scheduledAt.getTime() +
            (d.service.durationMinutes ?? 60) * 60 * 1000,
        );
      let ngay = khoaNgayVn(d.scheduledAt);
      const ngayCuoi = khoaNgayVn(ketThuc);
      const soNgayDon = Math.min(soNgayLech(ngay, ngayCuoi), TRAN_NGAY_MOT_DON);
      for (let i = 0; i <= soNgayDon; i++) {
        if (ngay >= tu && ngay <= den) {
          theoNgay.set(ngay, [...(theoNgay.get(ngay) ?? []), d.status]);
        }
        ngay = themNgay(ngay, 1);
      }
    }
    return theoNgay;
  }

  private loiConDon(theoNgay: Map<string, BookingStatus[]>): never {
    const ngayDangChay = [...theoNgay.entries()]
      .filter(([, ds]) => ds.includes('IN_PROGRESS'))
      .map(([ngay]) => ngay);
    const soDon = [...theoNgay.values()].reduce((s, ds) => s + ds.length, 0);
    if (ngayDangChay.length > 0) {
      throw new ConflictException({
        code: 'DON_DANG_DIEN_RA',
        message: 'Ngày đang có đơn diễn ra nên không đặt nghỉ được',
        days: ngayDangChay,
      });
    }
    throw new ConflictException({
      code: 'CON_DON_CHUA_XONG',
      message: `Còn ${soDon} đơn chưa diễn ra, huỷ các đơn đó rồi mới đặt nghỉ được`,
      days: [...theoNgay.keys()],
    });
  }

  // PUT /sitter/schedule/day
  async luuNgay(userId: string, dto: UpdateDayAvailabilityDto) {
    const ncc = await layNccCuaToi(this.prisma, userId);
    if (dto.date < homNayVn()) {
      throw new BadRequestException({
        code: 'NGAY_DA_QUA',
        message: 'Ngày đã qua nên không chỉnh được nữa',
      });
    }
    if (dto.mode === 'customHours') {
      if (!dto.start || !dto.end || truocHoacBang(dto.end, dto.start)) {
        throw new BadRequestException({
          code: 'GIO_KHONG_HOP_LE',
          message: 'Giờ kết thúc phải sau giờ bắt đầu',
        });
      }
    }
    const sucChua = await sucChuaTrongGiu(this.prisma, userId);
    if (dto.boardingSlots > sucChua) {
      throw new BadRequestException({
        code: 'VUOT_SUC_CHUA',
        message: `Số chỗ trông giữ không được vượt sức chứa ${sucChua}`,
      });
    }
    const daNhan = await this.beDangTrongGiu(ncc.id, dto.date);
    if (dto.mode !== 'off' && dto.boardingSlots < daNhan) {
      throw new BadRequestException({
        code: 'DUOI_SO_BE_DA_NHAN',
        message: `Ngày này đã nhận ${daNhan} bé nên không hạ số chỗ xuống dưới mức đó`,
      });
    }
    if (dto.mode === 'off') {
      const conDon = await this.donConHieuLuc(ncc.id, dto.date, dto.date);
      if (conDon.size > 0) this.loiConDon(conDon);
    }
    await this.kiemTraTranNgayDaChinh(ncc.id, dto.date);

    const luu = {
      mode: CHE_DO_RA_DB[dto.mode],
      startTime: dto.mode === 'customHours' ? (dto.start ?? null) : null,
      endTime: dto.mode === 'customHours' ? (dto.end ?? null) : null,
      boardingSlots: dto.mode === 'off' ? 0 : dto.boardingSlots,
      reason: dto.reason ?? null,
    };
    const dong = await this.prisma.sitterDaySetting.upsert({
      where: { sitterId_date: { sitterId: ncc.id, date: ngayDb(dto.date) } },
      create: { sitterId: ncc.id, date: ngayDb(dto.date), ...luu },
      update: luu,
    });
    return {
      date: khoaTuNgayDb(dong.date),
      mode: CHE_DO_RA_APP[dong.mode],
      start: dong.startTime,
      end: dong.endTime,
      boardingSlots: dong.boardingSlots,
      reason: dong.reason,
    };
  }

  private async beDangTrongGiu(sitterId: string, ngay: string) {
    const tuUtc = dauNgayVn(ngay);
    const denUtc = new Date(tuUtc.getTime() + MOT_NGAY_MS);
    const don = await this.prisma.booking.findMany({
      where: {
        sitterId,
        status: { in: TRANG_THAI_CON_HIEU_LUC },
        service: { type: 'BOARDING' },
        scheduledAt: { lt: denUtc },
        OR: [
          { scheduledEndAt: { gte: tuUtc } },
          { scheduledEndAt: null, scheduledAt: { gte: tuUtc } },
        ],
      },
      select: {
        scheduledAt: true,
        scheduledEndAt: true,
        _count: { select: { pets: true } },
      },
      take: TRAN_DON_XEM,
    });
    return don
      .filter((d) => demTrongGiu(d).includes(ngay))
      .reduce((tong, d) => tong + Math.max(d._count.pets, 1), 0);
  }

  // Ngày chỉnh riêng là bản ghi do người dùng tạo nên phải có trần
  private async kiemTraTranNgayDaChinh(sitterId: string, ngay: string) {
    const daCo = await this.prisma.sitterDaySetting.findUnique({
      where: { sitterId_date: { sitterId, date: ngayDb(ngay) } },
      select: { id: true },
    });
    if (daCo) return;
    const soDong = await this.prisma.sitterDaySetting.count({
      where: { sitterId },
    });
    if (soDong >= TRAN_NGAY_DA_CHINH) {
      throw new BadRequestException({
        code: 'QUA_NHIEU_NGAY_DA_CHINH',
        message: `Chỉ giữ được tối đa ${TRAN_NGAY_DA_CHINH} ngày chỉnh riêng`,
      });
    }
  }

  // POST /sitter/schedule/block chặn cả một khoảng ngày nghỉ
  async datNghiKhoang(userId: string, dto: BlockDaysOffDto) {
    const ncc = await layNccCuaToi(this.prisma, userId);
    const soNgay = kiemTraKhoang(dto.from, dto.to, TRAN_NGAY_NGHI);
    if (dto.to < homNayVn()) {
      throw new BadRequestException({
        code: 'NGAY_DA_QUA',
        message: 'Ngày đã qua nên không đặt nghỉ được',
      });
    }
    const tu = dto.from < homNayVn() ? homNayVn() : dto.from;
    const conDon = await this.donConHieuLuc(ncc.id, tu, dto.to);
    if (conDon.size > 0) this.loiConDon(conDon);

    const cacNgay = Array.from({ length: soNgay }, (_, i) =>
      themNgay(dto.from, i),
    ).filter((ngay) => ngay >= tu);
    await this.prisma.$transaction([
      this.prisma.sitterDaySetting.deleteMany({
        where: {
          sitterId: ncc.id,
          date: { gte: ngayDb(tu), lte: ngayDb(dto.to) },
        },
      }),
      this.prisma.sitterDaySetting.createMany({
        data: cacNgay.map((ngay) => ({
          sitterId: ncc.id,
          date: ngayDb(ngay),
          mode: 'OFF',
          boardingSlots: 0,
          reason: dto.reason ?? null,
        })),
      }),
    ]);
    return { days: cacNgay };
  }
}
