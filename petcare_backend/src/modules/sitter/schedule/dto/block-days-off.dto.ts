import { IsOptional, IsString, Matches, MaxLength } from 'class-validator';
import { MAU_NGAY } from './schedule-range.dto';

export class BlockDaysOffDto {
  @Matches(MAU_NGAY, { message: 'from phải dạng YYYY-MM-DD' })
  from!: string;

  @Matches(MAU_NGAY, { message: 'to phải dạng YYYY-MM-DD' })
  to!: string;

  @IsOptional()
  @IsString()
  @MaxLength(200)
  reason?: string;
}
