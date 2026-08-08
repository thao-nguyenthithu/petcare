import { ApiPropertyOptional } from '@nestjs/swagger';
import { IsISO8601, IsOptional } from 'class-validator';

// Bỏ trống thì lấy 30 ngày gần nhất, kỳ so sánh là quãng cùng độ dài liền trước
export class KyDoanhThuDto {
  @ApiPropertyOptional({ description: 'Đầu kỳ thống kê' })
  @IsOptional()
  @IsISO8601()
  from?: string;

  @ApiPropertyOptional({ description: 'Cuối kỳ thống kê' })
  @IsOptional()
  @IsISO8601()
  to?: string;
}
