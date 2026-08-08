import { ApiPropertyOptional } from '@nestjs/swagger';
import { Type } from 'class-transformer';
import { IsInt, IsOptional, Min } from 'class-validator';

// Quá trần thì kẹp về trần ở phan-trang.ts, KHÔNG chặn bằng lỗi ở đây
export class PhanTrangDto {
  @ApiPropertyOptional({ description: 'Trang, đếm từ 1', example: 1 })
  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(1)
  page?: number;

  @ApiPropertyOptional({
    description: 'Số dòng mỗi trang, trần 50',
    example: 20,
  })
  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(1)
  limit?: number;
}
