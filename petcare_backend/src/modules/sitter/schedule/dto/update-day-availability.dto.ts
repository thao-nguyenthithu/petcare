import {
  IsIn,
  IsInt,
  IsOptional,
  IsString,
  Matches,
  MaxLength,
  Min,
} from 'class-validator';
import { MAU_NGAY } from './schedule-range.dto';
import { MAU_GIO } from './update-working-hours.dto';

export const CHE_DO_NGAY = ['default', 'customHours', 'off'] as const;
export type CheDoNgay = (typeof CHE_DO_NGAY)[number];

export class UpdateDayAvailabilityDto {
  @Matches(MAU_NGAY, { message: 'date phải dạng YYYY-MM-DD' })
  date!: string;

  @IsIn(CHE_DO_NGAY)
  mode!: CheDoNgay;

  @IsOptional()
  @Matches(MAU_GIO, { message: 'start phải dạng HH:mm' })
  start?: string;

  @IsOptional()
  @Matches(MAU_GIO, { message: 'end phải dạng HH:mm' })
  end?: string;

  @IsInt()
  @Min(0)
  boardingSlots!: number;

  @IsOptional()
  @IsString()
  @MaxLength(200)
  reason?: string;
}
