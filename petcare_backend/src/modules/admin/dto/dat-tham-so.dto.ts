import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { IsDefined, IsOptional, IsString, MaxLength } from 'class-validator';

export class DatThamSoDto {
  @ApiProperty({
    description:
      'Số nguyên với tham số dạng số, true hoặc false với công tắc, chuỗi với tham số dạng chọn',
    example: 15,
  })
  // Khoảng và kiểu do bộ khai quyết định nên chặn ở tầng dịch vụ, không ở đây
  @IsDefined()
  giaTri!: number | boolean | string;

  @ApiPropertyOptional({ description: 'Lý do đổi, ghi vào nhật ký quản trị' })
  @IsOptional()
  @IsString()
  @MaxLength(300)
  lyDo?: string;
}
