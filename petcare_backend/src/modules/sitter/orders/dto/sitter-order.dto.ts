import { Transform, Type } from 'class-transformer';
import {
  IsArray,
  IsBoolean,
  IsIn,
  IsInt,
  IsLatitude,
  IsLongitude,
  IsNumber,
  IsOptional,
  IsString,
  Max,
  MaxLength,
  Min,
  MinLength,
} from 'class-validator';
import { chuoiThanhMang } from '../../../../common/multipart';
import {
  LOAI_DICH_VU,
  type LoaiDichVuDto,
} from '../../../bookings/dto/create-booking.dto';

// Một chip gom vài trạng thái nên client gửi tên chip, không gửi trạng thái DB
export const NHOM_DON_NCC = [
  'pending',
  'upcoming',
  'ongoing',
  'waitConfirm',
  'completed',
  'cancelled',
] as const;
export type NhomDonNccDto = (typeof NHOM_DON_NCC)[number];

export class ListSitterBookingsDto {
  @IsOptional()
  @IsIn(NHOM_DON_NCC)
  status?: NhomDonNccDto;

  @IsOptional()
  @IsIn(LOAI_DICH_VU)
  serviceType?: LoaiDichVuDto;

  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(1)
  page?: number;

  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(1)
  @Max(50)
  limit?: number;
}

export class AcceptBookingDto {
  @IsOptional()
  @IsBoolean()
  safetyCommitted?: boolean;
}

export const LY_DO_TU_CHOI = [
  'trungLich',
  'quaXa',
  'khongNhanGiongNay',
  'banDotXuat',
  'khac',
] as const;

export class RejectBookingDto {
  @IsIn(LY_DO_TU_CHOI)
  reason!: (typeof LY_DO_TU_CHOI)[number];

  @IsOptional()
  @IsString()
  @MaxLength(500)
  @Transform(({ value }) => (value as string)?.trim())
  note?: string;
}

export const LY_DO_HUY_NCC = [
  'banViecDotXuat',
  'trungLichDonKhac',
  'sucKhoeKhongTot',
  'quaXaKhongToiKip',
  'taiNanSuCo',
  'xeHongGiuaDuong',
  'khac',
] as const;
export type LyDoHuyNccDto = (typeof LY_DO_HUY_NCC)[number];

export class SitterCancelDto {
  @IsIn(LY_DO_HUY_NCC)
  reason!: LyDoHuyNccDto;

  @IsOptional()
  @IsString()
  @MaxLength(500)
  @Transform(({ value }) => (value as string)?.trim())
  note?: string;
}

export class ArriveDto {
  @Type(() => Number)
  @IsLatitude()
  lat!: number;

  @Type(() => Number)
  @IsLongitude()
  lng!: number;
}

export class LateReportDto {
  @Type(() => Number)
  @IsInt()
  @Min(1)
  @Max(120)
  minutes!: number;
}

export const LY_DO_SU_CO = [
  'beKhongHopTac',
  'chuNuoiVang',
  'diaChiSai',
  'thoiTietXau',
  'khac',
] as const;

export const LY_DO_SU_CO_CAN_MO_TA = 'khac';

export class IncidentDto {
  @IsIn(LY_DO_SU_CO)
  reason!: string;

  @IsOptional()
  @IsString()
  @MaxLength(2000)
  @Transform(({ value }) => (value as string)?.trim())
  @MinLength(10)
  description?: string;
}

export class FinishDto {
  @IsOptional()
  @IsString()
  @MaxLength(1000)
  @Transform(({ value }) => (value as string)?.trim())
  note?: string;

  @IsOptional()
  @Type(() => Number)
  @IsNumber()
  @Min(0)
  @Max(200)
  distanceKm?: number;

  @IsOptional()
  @IsArray()
  @IsString({ each: true })
  @Transform(({ value }) => chuoiThanhMang(value))
  conditions?: string[];
}

export class DailyUpdateDto {
  @IsOptional()
  @IsString()
  @MaxLength(1000)
  @Transform(({ value }) => (value as string)?.trim())
  message?: string;

  @IsOptional()
  @IsArray()
  @IsString({ each: true })
  @Transform(({ value }) => chuoiThanhMang(value))
  conditions?: string[];
}

export class HandoverDto {
  @IsOptional()
  @IsString()
  @MaxLength(1000)
  @Transform(({ value }) => (value as string)?.trim())
  note?: string;
}
