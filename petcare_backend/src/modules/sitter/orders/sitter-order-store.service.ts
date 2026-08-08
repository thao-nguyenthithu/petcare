import {
  BadRequestException,
  ConflictException,
  Injectable,
} from '@nestjs/common';
import { Prisma } from 'generated/prisma/client';
import { BookingStatus, PhotoPhase } from 'generated/prisma/enums';
import { khoangCachKm } from '../../../common/khoang-cach';
import { MOT_PHUT_MS } from '../../../common/thoi-gian-vn';
import { PrismaService } from '../../../prisma/prisma.service';
import { SystemSettingsService } from '../../admin/system-settings.service';
import {
  mocNhaTien,
  NO_SHOW_WAIT,
  PHUT_TU_HUY_KHONG_AI_BAT_DAU,
} from '../../bookings/booking-compensation';
import { LOAI_RA_APP } from '../../bookings/booking-enums';
import { hanNhanDonCua } from '../../bookings/booking-time';
import { LoaiDichVuDto } from '../../bookings/dto/create-booking.dto';
import { BUCKET_ANH_DON } from '../../media/anh-duong-dan';
import { AnhKyService } from '../../media/anh-ky.service';
import { AnhTaiLenService } from '../../media/anh-tai-len.service';
import { type UploadedImage } from '../../media/image-upload';
import { SO_ANH_MO_KHIEU_NAI } from '../../wallet/dto/wallet.dto';
import { layNccCuaToi, khongTimThayDon } from './sitter-guard';

const BUCKET = BUCKET_ANH_DON;

export const SO_ANH_GIUA_PHIEN = 5;
export const SO_ANH_BANG_CHUNG = 3;
export const SO_ANH_DO_DUNG = 5;

export type DbClient = Prisma.TransactionClient;

export const CHON = {
  id: true,
  status: true,
  scheduledAt: true,
  scheduledEndAt: true,
  createdAt: true,
  paidAt: true,
  acceptedAt: true,
  departedAt: true,
  arrivedAt: true,
  ownerArrivedAt: true,
  ownerDepartedAt: true,
  _count: { select: { pets: true } },
  gearReportedAt: true,
  lateReportedAt: true,
  startedAt: true,
  totalPrice: true,
  platformFeePercent: true,
  cancelFeePercent: true,
  priceBreakdown: true,
  addressLat: true,
  pickupDistanceKm: true,
  addressLng: true,
  gearCommittedAt: true,
  sitterId: true,
  service: { select: { type: true } },
} satisfies Prisma.BookingSelect;

export type DonMayTrangThai = Prisma.BookingGetPayload<{
  select: typeof CHON;
}>;

export function loaiDichVu(don: DonMayTrangThai): LoaiDichVuDto {
  return LOAI_RA_APP[don.service.type];
}

export function soDem(don: DonMayTrangThai): number {
  const bd = don.priceBreakdown as { nights?: number } | null;
  return typeof bd?.nights === 'number' ? bd.nights : 0;
}

export function hanNhanDon(don: DonMayTrangThai): Date {
  return hanNhanDonCua(don);
}

export function phaiDangO(don: DonMayTrangThai, cho: BookingStatus[]) {
  if (!cho.includes(don.status)) {
    throw new ConflictException({
      code: 'TRANG_THAI_KHONG_HOP_LE',
      message: 'Đơn không còn ở bước làm được việc này',
    });
  }
}

export function chiDichVu(don: DonMayTrangThai, loai: LoaiDichVuDto) {
  if (loaiDichVu(don) !== loai) {
    throw new ConflictException({
      code: 'SAI_LOAI_DICH_VU',
      message: 'Việc này không thuộc dịch vụ của đơn',
    });
  }
}

export function chuaCoMoc(moc: Date | null, code: string, message: string) {
  if (moc) throw new ConflictException({ code, message });
}

export function phaiChoDu(tuLuc: number, bayGio: number) {
  if (bayGio < tuLuc + NO_SHOW_WAIT * MOT_PHUT_MS) {
    throw new ConflictException({
      code: 'CHUA_CHO_DU_AN_HAN',
      message: `Cần chờ đủ ${NO_SHOW_WAIT} phút rồi mới báo vắng mặt`,
    });
  }
  if (bayGio > tuLuc + PHUT_TU_HUY_KHONG_AI_BAT_DAU * MOT_PHUT_MS) {
    throw new ConflictException({
      code: 'QUA_HAN_BAO_VANG_MAT',
      message: `Quá ${PHUT_TU_HUY_KHONG_AI_BAT_DAU} phút chờ nên đơn đã được khép ở mức không tính phí bên nào`,
    });
  }
}

export function batBuocMoTa(canMoTa: boolean, moTa?: string) {
  if (canMoTa && !moTa) {
    throw new BadRequestException({
      code: 'THIEU_MO_TA_LY_DO',
      message: 'Cần mô tả thêm lý do',
    });
  }
}

export function metToiDiemHen(
  don: DonMayTrangThai,
  lat: number,
  lng: number,
): number | null {
  if (don.addressLat === null || don.addressLng === null) return null;
  return khoangCachKm(lat, lng, don.addressLat, don.addressLng) * 1000;
}

export function phaiCoAnhBangChung(files: UploadedImage[]) {
  if (!files?.length) {
    throw new BadRequestException({
      code: 'THIEU_ANH_BANG_CHUNG',
      message: 'Cần ít nhất một ảnh chụp tại điểm hẹn để báo vắng mặt',
    });
  }
  if (files.length > SO_ANH_BANG_CHUNG) {
    throw new BadRequestException({
      code: 'VUOT_GIOI_HAN_ANH',
      message: `Chỉ gửi tối đa ${SO_ANH_BANG_CHUNG} ảnh bằng chứng`,
    });
  }
}

export function phaiHopLeAnhSuCo(files: UploadedImage[]) {
  if ((files?.length ?? 0) > SO_ANH_MO_KHIEU_NAI) {
    throw new BadRequestException({
      code: 'VUOT_GIOI_HAN_ANH',
      message: `Chỉ gửi tối đa ${SO_ANH_MO_KHIEU_NAI} ảnh kèm sự cố`,
    });
  }
}

export function phaiCoAnhGiuaPhien(files: UploadedImage[]) {
  if (!files?.length) {
    throw new BadRequestException({
      code: 'THIEU_ANH',
      message: 'Cần ít nhất một ảnh',
    });
  }
  if (files.length > SO_ANH_GIUA_PHIEN) {
    throw new BadRequestException({
      code: 'VUOT_GIOI_HAN_ANH',
      message: `Mỗi lần gửi tối đa ${SO_ANH_GIUA_PHIEN} ảnh`,
    });
  }
}

export function phaiCoAnhHaiDauPhien(
  files: UploadedImage[],
  soBe: number,
  loai: LoaiDichVuDto,
) {
  const so = files?.length ?? 0;
  const { toiThieu, toiDa, mota } = mucAnhCanCo(soBe, loai);
  if (so < toiThieu || so > toiDa) {
    throw new BadRequestException({
      code: 'SAI_SO_ANH_BAT_BUOC',
      message: `Bước này cần ${mota}`,
    });
  }
}

export function phaiHopLeAnhDoDung(
  files: UploadedImage[],
  loai: LoaiDichVuDto,
) {
  const so = files?.length ?? 0;
  if (so === 0) return;
  if (loai !== 'boarding') {
    throw new BadRequestException({
      code: 'KHONG_CO_ANH_DO_DUNG',
      message: 'Chỉ kỳ trông giữ mới có ảnh đồ dùng gửi kèm',
    });
  }
  if (so > SO_ANH_DO_DUNG) {
    throw new BadRequestException({
      code: 'VUOT_GIOI_HAN_ANH',
      message: `Chỉ gửi tối đa ${SO_ANH_DO_DUNG} ảnh đồ dùng`,
    });
  }
}

function mucAnhCanCo(soBe: number, loai: LoaiDichVuDto) {
  if (loai === 'walking') {
    return {
      toiThieu: 1,
      toiDa: SO_ANH_BANG_CHUNG,
      mota: `từ 1 đến ${SO_ANH_BANG_CHUNG} ảnh`,
    };
  }
  if (loai === 'grooming') {
    return {
      toiThieu: soBe,
      toiDa: soBe,
      mota: `mỗi bé một ảnh, tổng ${soBe} ảnh`,
    };
  }
  return {
    toiThieu: soBe,
    toiDa: soBe * 2,
    mota: `mỗi bé một hoặc hai ảnh, từ ${soBe} đến ${soBe * 2} ảnh`,
  };
}

export type TienDiDau = 'hoanNgay' | 'giuChoPhanDoi';

export type KhepDonTin = {
  trangThai: BookingStatus;
  lyDo: string;
  moTa?: string | null;
  chuNuoiChiu: number;
  nccNhan: number;
  tienDi: TienDiDau;
};

function laClientGoc(db: DbClient | PrismaService): db is PrismaService {
  return typeof (db as PrismaService).$transaction === 'function';
}

@Injectable()
export class SitterOrderStore {
  constructor(
    private readonly prisma: PrismaService,
    private readonly anh: AnhTaiLenService,
    private readonly anhKy: AnhKyService,
    private readonly thamSo: SystemSettingsService,
  ) {}

  kyAnh(duong: string[]): Promise<Map<string, string>> {
    return this.anhKy.kyLo(duong);
  }

  kyAnhMang(duong: string[]): Promise<string[]> {
    return this.anhKy.kyMang(duong);
  }

  async timDon(userId: string, id: string) {
    const ncc = await layNccCuaToi(this.prisma, userId);
    const don = await this.prisma.booking.findFirst({
      where: { id, sitterId: ncc.id },
      select: CHON,
    });
    if (!don) khongTimThayDon();
    return { ncc, don };
  }

  dayAnhLenStorage(
    bookingId: string,
    files: UploadedImage[],
  ): Promise<string[]> {
    return this.anh.dayLen(BUCKET, bookingId, files);
  }

  async taiAnh(
    bookingId: string,
    files: UploadedImage[],
    pha: PhotoPhase,
    anhDoDung = false,
  ): Promise<string[]> {
    if (!files?.length) return [];
    const urls = await this.dayAnhLenStorage(bookingId, files);
    await this.prisma.sessionPhoto.createMany({
      data: urls.map((url) => ({
        bookingId,
        photoUrl: url,
        phase: pha,
        anhDoDung,
      })),
    });
    return urls;
  }

  async khepDon(
    id: string,
    tin: KhepDonTin,
    db: DbClient | PrismaService = this.prisma,
  ) {
    if (laClientGoc(db)) {
      return db.$transaction((tx) => this.khepTrongTran(id, tin, tx));
    }
    return this.khepTrongTran(id, tin, db);
  }

  private async khepTrongTran(id: string, tin: KhepDonTin, db: DbClient) {
    const luc = new Date();
    await db.booking.update({
      where: { id },
      data: {
        status: tin.trangThai,
        cancelledAt: luc,
        cancellationReason: tin.lyDo,
        cancellationNote: tin.moTa ?? null,
        cancellationFee: tin.chuNuoiChiu,
        sitterPayout: tin.nccNhan,
        platformFee: tin.chuNuoiChiu - tin.nccNhan,
        ...(tin.tienDi === 'giuChoPhanDoi'
          ? { escrowReleaseAt: mocNhaTien(luc, this.thamSo.so('escrow.hours')) }
          : {}),
      },
    });
    if (tin.tienDi !== 'hoanNgay') return;
    await db.payment.updateMany({
      where: { bookingId: id, status: 'HELD' },
      data: { status: 'REFUNDING' },
    });
  }
}
