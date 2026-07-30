import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import {
  IsBoolean,
  IsEnum,
  IsInt,
  IsNotEmpty,
  IsOptional,
  IsString,
  Max,
  MaxLength,
  Min,
} from 'class-validator';
import { CycleUnit, PreventionForm } from 'generated/prisma/enums';

// Chu kỳ dài nhất cho phép khai
export const CHU_KY_TOI_DA = 999;

export class CreatePreventionDto {
  @ApiProperty({
    example: 'dai',
    description: 'Mã hạng mục trong danh mục app',
  })
  @IsString({ message: 'Mã hạng mục không hợp lệ' })
  @IsNotEmpty({ message: 'Thiếu hạng mục' })
  @MaxLength(50, { message: 'Mã hạng mục quá dài' })
  code!: string;

  @ApiPropertyOptional({
    example: 'Viêm gan truyền nhiễm',
    description: 'Bắt buộc khi code là "khac"',
  })
  @IsOptional()
  @IsString({ message: 'Tên hạng mục không hợp lệ' })
  @MaxLength(100, { message: 'Tên hạng mục quá dài' })
  customName?: string;

  @ApiProperty({ enum: PreventionForm, example: PreventionForm.VACCINE })
  @IsEnum(PreventionForm, { message: 'Cách thực hiện không hợp lệ' })
  form!: PreventionForm;

  @ApiPropertyOptional({ example: false })
  @IsOptional()
  @IsBoolean({ message: 'Cờ định kỳ không hợp lệ' })
  isPeriodic?: boolean;

  @ApiPropertyOptional({ example: 12 })
  @IsOptional()
  @IsInt({ message: 'Chu kỳ gợi ý không hợp lệ' })
  @Min(1, { message: 'Chu kỳ gợi ý phải lớn hơn 0' })
  @Max(CHU_KY_TOI_DA, { message: 'Chu kỳ gợi ý quá lớn' })
  suggestedCycleValue?: number;

  @ApiPropertyOptional({ enum: CycleUnit, example: CycleUnit.MONTH })
  @IsOptional()
  @IsEnum(CycleUnit, { message: 'Đơn vị chu kỳ không hợp lệ' })
  suggestedCycleUnit?: CycleUnit;
}
