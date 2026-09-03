import { BadRequestException, ConflictException } from '@nestjs/common';
import { PetSpecies } from 'generated/prisma/enums';
import { khoangCachKm } from '../../common/khoang-cach';
import {
  MOT_PHUT_MS,
  gioVn,
  homNayVn,
  mocVn,
  phutTrongNgay,
  soNgayLech,
  themNgay,
  truocHoacBang,
} from '../../common/thoi-gian-vn';
import {
  BeTinhGia,
  KetQuaGia,
  TRAN_BE_WALKING,
  soBeToiDa,
  tinhGiaBoarding,
  tinhGiaGrooming,
  tinhGiaWalking,
} from './booking-pricing';
import {
  MAX_ADVANCE_DAYS,
  MIN_LEAD_MINUTES,
  SLOT_STEP_MINUTES,
  TRAN_DEM_MOT_DON,
  phutTreCuaKy,
} from './booking-time';
import { CreateBookingDto, LoaiDichVuDto } from './dto/create-booking.dto';
import { NgayLich } from './sitter-slots.service';
import { moMoiCuaThoiGian } from '../../common/che-do-demo';

export type BeCuaDon = {
  id: string;
  name: string;
  species: PetSpecies;
  weightKg: number;
};

export type MocDon = {
  batDau: Date;
  ketThuc: Date;
  ngayDau: string;
  ngayCuoi: string;
  soDem: number;
};

export function kiemTraLoaiBe(
  pets: BeCuaDon[],
  loai: LoaiDichVuDto,
  petKind: string,
) {
  const nhan = loai === 'walking' ? 'DOG' : petKind;
  if (nhan === 'BOTH') return;
  const lech = pets.some((p) => p.species !== nhan);
  if (lech) {
    throw new BadRequestException({
      code: 'BE_KHONG_HOP_DICH_VU',
      message:
        nhan === 'DOG'
          ? 'Dịch vụ này chỉ nhận chó'
          : 'Dịch vụ này chỉ nhận mèo',
    });
  }
}

export function kiemTraSoBe(
  soBe: number,
  pricing: Record<string, unknown>,
  loai: LoaiDichVuDto,
) {
  if (loai === 'walking' && soBe > TRAN_BE_WALKING) {
    throw new BadRequestException({
      code: 'VUOT_SO_BE_MOT_LUOT_DAT',
      message: `Một lượt dắt nhận tối đa ${TRAN_BE_WALKING} bé`,
    });
  }
  const toiDa = soBeToiDa(pricing);
  if (soBe > toiDa) {
    throw new BadRequestException({
      code: 'VUOT_SO_BE_TOI_DA',
      message: `Người chăm chỉ nhận tối đa ${toiDa} bé mỗi lượt`,
    });
  }
}

export function kmDiemHenToiNcc(
  diaChi: { lat: number; lng: number },
  ncc: { lat: number | null; lng: number | null },
): number | null {
  if (ncc.lat === null || ncc.lng === null) return null;
  return (
    Math.round(khoangCachKm(diaChi.lat, diaChi.lng, ncc.lat, ncc.lng) * 10) / 10
  );
}

export function kiemTraBanKinh(
  diaChi: { lat: number; lng: number },
  ncc: {
    lat: number | null;
    lng: number | null;
    serviceRadiusKm: number | null;
  },
) {
  if (ncc.lat === null || ncc.lng === null || !ncc.serviceRadiusKm) return;
  const km = khoangCachKm(diaChi.lat, diaChi.lng, ncc.lat, ncc.lng);
  if (km > ncc.serviceRadiusKm) {
    throw new BadRequestException({
      code: 'NGOAI_BAN_KINH',
      message: `Địa chỉ nằm ngoài bán kính phục vụ ${ncc.serviceRadiusKm} km của người chăm`,
    });
  }
}

export function dungMocThoiGian(
  dto: CreateBookingDto,
  loai: LoaiDichVuDto,
): MocDon {
  if (phutTrongNgay(dto.startTime) % SLOT_STEP_MINUTES !== 0) {
    throw new BadRequestException({
      code: 'GIO_KHONG_HOP_LE',
      message: `Giờ bắt đầu phải rơi đúng mốc ${SLOT_STEP_MINUTES} phút`,
    });
  }
  const batDau = mocVn(dto.startDate, dto.startTime);
  const bayGio = Date.now();
  if (
    !moMoiCuaThoiGian() &&
    (batDau.getTime() - bayGio) / MOT_PHUT_MS < MIN_LEAD_MINUTES
  ) {
    throw new BadRequestException({
      code: 'CHUA_DU_LEAD_TIME',
      message: `Đơn phải đặt trước giờ bắt đầu ít nhất ${MIN_LEAD_MINUTES / 60} giờ`,
    });
  }
  if (soNgayLech(homNayVn(), dto.startDate) > MAX_ADVANCE_DAYS) {
    throw new BadRequestException({
      code: 'NGOAI_CUA_SO_DAT_TRUOC',
      message: `Chỉ đặt trước tối đa ${MAX_ADVANCE_DAYS} ngày`,
    });
  }

  if (loai !== 'boarding') {
    return {
      batDau,
      ketThuc: batDau,
      ngayDau: dto.startDate,
      ngayCuoi: dto.startDate,
      soDem: 0,
    };
  }

  if (!dto.endDate || !dto.endTime) {
    throw new BadRequestException({
      code: 'THIEU_NGAY_TRA',
      message: 'Cần chọn ngày và giờ trả bé',
    });
  }
  if (phutTrongNgay(dto.endTime) % SLOT_STEP_MINUTES !== 0) {
    throw new BadRequestException({
      code: 'GIO_KHONG_HOP_LE',
      message: `Giờ trả bé phải rơi đúng mốc ${SLOT_STEP_MINUTES} phút`,
    });
  }
  const soDem = soNgayLech(dto.startDate, dto.endDate);
  if (soDem < 1) {
    throw new BadRequestException({
      code: 'KHOANG_KHONG_HOP_LE',
      message: 'Kỳ trông giữ phải có ít nhất một đêm',
    });
  }
  if (soDem > TRAN_DEM_MOT_DON) {
    throw new BadRequestException({
      code: 'QUA_NHIEU_DEM',
      message: `Mỗi đơn trông giữ tối đa ${TRAN_DEM_MOT_DON} đêm`,
    });
  }
  return {
    batDau,
    ketThuc: mocVn(dto.endDate, dto.endTime),
    ngayDau: dto.startDate,
    ngayCuoi: dto.endDate,
    soDem,
  };
}

export function tinhTien(
  loai: LoaiDichVuDto,
  pricing: Record<string, unknown>,
  pets: BeCuaDon[],
  dto: CreateBookingDto,
  moc: MocDon,
): KetQuaGia {
  switch (loai) {
    case 'walking': {
      if (!dto.durationMinutes) {
        throw new BadRequestException({
          code: 'THIEU_THOI_LUONG',
          message: 'Cần chọn thời lượng của lượt dắt',
        });
      }
      return tinhGiaWalking(pricing, pets.length, dto.durationMinutes);
    }
    case 'grooming': {
      const goiTheoBe = new Map(
        (dto.packages ?? []).map((e) => [e.petId, e.packageCode]),
      );
      const beTinhGia: BeTinhGia[] = pets.map((p) => ({
        id: p.id,
        weightKg: p.weightKg,
        packageCode: goiTheoBe.get(p.id),
      }));
      return tinhGiaGrooming(pricing, beTinhGia);
    }
    case 'boarding':
      return tinhGiaBoarding(
        pricing,
        pets.length,
        moc.soDem,
        phutTreCuaKy(moc.batDau, moc.soDem, moc.ketThuc),
      );
  }
}

export function kiemTraLich(
  days: NgayLich[],
  loai: LoaiDichVuDto,
  moc: MocDon,
  thoiLuong: number | null,
  soBe: number,
) {
  const theoNgay = new Map(days.map((d) => [d.date, d]));
  const ngayDau = theoNgay.get(moc.ngayDau);
  if (!ngayDau || ngayDau.closed) {
    throw new ConflictException({
      code: 'NCC_NGHI_NGAY_NAY',
      message: 'Người chăm không nhận đơn vào ngày này',
    });
  }

  if (loai === 'boarding') {
    const ngayCuoi = theoNgay.get(moc.ngayCuoi);
    if (!ngayCuoi || ngayCuoi.closed) {
      throw new ConflictException({
        code: 'NCC_NGHI_NGAY_NAY',
        message: 'Người chăm không nhận đơn vào ngày trả bé',
      });
    }
    kiemTraTrongGioLam(ngayDau, moc.batDau, moc.batDau);
    kiemTraTrongGioLam(ngayCuoi, moc.ketThuc, moc.ketThuc);
    for (let i = 0; i < moc.soDem; i++) {
      const ngay = theoNgay.get(themNgay(moc.ngayDau, i));
      if (!ngay || ngay.closed || ngay.boardingLeft < soBe) {
        throw new ConflictException({
          code: 'HET_CHO_TRONG_GIU',
          message: 'Người chăm không còn đủ chỗ cho số bé này',
        });
      }
    }
    return;
  }

  kiemTraTrongGioLam(ngayDau, moc.batDau, moc.ketThuc);
  const batDau = phutTrongNgay(gioVn(moc.batDau));
  const ketThuc = batDau + (thoiLuong ?? 0);
  for (const ban of ngayDau.busy) {
    const banDau = phutTrongNgay(ban.start);
    const banCuoi = phutTrongNgay(ban.end);
    if (batDau < banCuoi && ketThuc > banDau) {
      throw new ConflictException({
        code: 'KHUNG_GIO_DA_CO_DON',
        message: 'Người chăm đã có đơn khác trong khung giờ này',
      });
    }
  }
}

function kiemTraTrongGioLam(ngay: NgayLich, batDau: Date, ketThuc: Date) {
  const dau = gioVn(batDau);
  const cuoi = gioVn(ketThuc);
  if (!truocHoacBang(ngay.start, dau) || !truocHoacBang(cuoi, ngay.end)) {
    throw new ConflictException({
      code: 'NGOAI_GIO_LAM_VIEC',
      message: `Người chăm chỉ nhận đơn từ ${ngay.start} đến ${ngay.end}`,
    });
  }
}
