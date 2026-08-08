import { Transform, Type } from 'class-transformer';
import {
  IsIn,
  IsInt,
  IsOptional,
  IsString,
  Max,
  MaxLength,
  Min,
} from 'class-validator';
import { LOAI_DICH_VU, type LoaiDichVuDto } from './create-booking.dto';

export const NHOM_DON = [
  'pending',
  'upcoming',
  'ongoing',
  'completed',
  'cancelled',
] as const;
export type NhomDonDto = (typeof NHOM_DON)[number];

export class ListBookingsDto {
  @IsOptional()
  @IsIn(NHOM_DON)
  status?: NhomDonDto;

  @IsOptional()
  @IsIn(LOAI_DICH_VU)
  serviceType?: LoaiDichVuDto;

  @IsOptional()
  @IsString()
  @MaxLength(100)
  @Transform(({ value }) => (value as string)?.trim())
  q?: string;

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
