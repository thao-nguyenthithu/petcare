import { Transform } from 'class-transformer';
import { IsIn, IsOptional, IsString, MaxLength } from 'class-validator';

export const LY_DO_HUY_CHU_NUOI = [
  'doiLichKhac',
  'khongCanNua',
  'timDuocNccKhac',
  'nccChamPhanHoi',
  'khac',
  'nccChuaToi',
] as const;
export type LyDoHuyDto = (typeof LY_DO_HUY_CHU_NUOI)[number];

export const LY_DO_CAN_MO_TA: LyDoHuyDto = 'khac';

export const LY_DO_NCC_CHUA_TOI: LyDoHuyDto = 'nccChuaToi';

export class CancelBookingDto {
  @IsIn(LY_DO_HUY_CHU_NUOI)
  reason!: LyDoHuyDto;

  @IsOptional()
  @IsString()
  @MaxLength(500)
  @Transform(({ value }) => (value as string)?.trim())
  note?: string;
}
