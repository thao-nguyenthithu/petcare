import { ApiPropertyOptional } from '@nestjs/swagger';
import { IsIn, IsOptional } from 'class-validator';
import { PhanTrangDto } from '../../chung/dto/phan-trang.dto';

// Ba nguồn nằm ở ba bảng khác nhau, gộp một lượt hỏi là không phân trang nổi
export const NGUON_ANH = ['session', 'boarding', 'noShow'] as const;

export type NguonAnh = (typeof NGUON_ANH)[number];

export class LocAnhDto extends PhanTrangDto {
  @ApiPropertyOptional({ enum: NGUON_ANH, default: 'session' })
  @IsOptional()
  @IsIn(NGUON_ANH)
  source?: NguonAnh;
}
