import { IsIn, IsOptional, IsString, MaxLength } from 'class-validator';

export const LY_DO_HUY = [
  'OM_DOT_XUAT',
  'BAN_VIEC_GAP',
  'TRUNG_LICH',
  'KHAC',
] as const;
export type LyDoHuy = (typeof LY_DO_HUY)[number];

export class CancelBookingDto {
  @IsIn(LY_DO_HUY)
  reason!: LyDoHuy;

  @IsOptional()
  @IsString()
  @MaxLength(500)
  note?: string;
}
