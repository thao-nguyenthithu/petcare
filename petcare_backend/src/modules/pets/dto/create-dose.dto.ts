import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import {
  IsDateString,
  IsEnum,
  IsInt,
  IsOptional,
  IsString,
  Max,
  MaxLength,
  Min,
} from 'class-validator';
import { CycleUnit } from 'generated/prisma/enums';
import { CHU_KY_TOI_DA } from './create-prevention.dto';

// Một lần đã làm của hạng mục
export class CreateDoseDto {
  @ApiProperty({ example: '2026-03-12T00:00:00.000Z' })
  @IsDateString({}, { message: 'Ngày thực hiện không hợp lệ' })
  doneAt!: string;

  @ApiPropertyOptional({
    example: 12,
    description: 'Bỏ trống là không nhắc lại',
  })
  @IsOptional()
  @IsInt({ message: 'Chu kỳ không hợp lệ' })
  @Min(1, { message: 'Chu kỳ phải lớn hơn 0' })
  @Max(CHU_KY_TOI_DA, { message: 'Chu kỳ quá lớn' })
  cycleValue?: number;

  @ApiPropertyOptional({ enum: CycleUnit, example: CycleUnit.MONTH })
  @IsOptional()
  @IsEnum(CycleUnit, { message: 'Đơn vị chu kỳ không hợp lệ' })
  cycleUnit?: CycleUnit;

  @ApiPropertyOptional({ example: 'Phòng khám thú y Pet Home' })
  @IsOptional()
  @IsString({ message: 'Nơi thực hiện không hợp lệ' })
  @MaxLength(255, { message: 'Nơi thực hiện quá dài' })
  place?: string;
}
