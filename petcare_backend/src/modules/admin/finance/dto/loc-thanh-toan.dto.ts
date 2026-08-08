import { ApiPropertyOptional } from '@nestjs/swagger';
import { Transform } from 'class-transformer';
import {
  IsIn,
  IsISO8601,
  IsOptional,
  IsString,
  MaxLength,
} from 'class-validator';
import { PaymentStatus } from '../../../../../generated/prisma/enums';
import { catKhoangTrang } from '../../chung/dto/chuyen-doi';
import { PhanTrangDto } from '../../chung/dto/phan-trang.dto';

// Đúng ba giá trị cột gateway đang ghi, xem thuộc tính ten ở modules/payments/gateways
export const TEN_CONG = ['vnpay', 'mock', 'auto'];

// Một tab phủ hai trạng thái nên khoá này nhận nhiều giá trị, lặp khoá hoặc ngăn bằng dấu phẩy
function raDanhSach({ value }: { value: unknown }): unknown {
  const tho = Array.isArray(value) ? value : [value];
  const ds = tho
    .filter((v): v is string => typeof v === 'string')
    .flatMap((v) => v.split(','))
    .map((v) => v.trim())
    .filter((v) => v.length > 0);
  return ds.length ? ds : undefined;
}

export class LocThanhToanDto extends PhanTrangDto {
  @ApiPropertyOptional({ enum: PaymentStatus, isArray: true })
  @IsOptional()
  @Transform(raDanhSach)
  @IsIn(Object.values(PaymentStatus), { each: true })
  status?: PaymentStatus[];

  @ApiPropertyOptional({ enum: TEN_CONG })
  @IsOptional()
  @IsIn(TEN_CONG)
  gateway?: string;

  @ApiPropertyOptional({ description: 'Mã ngân hàng cổng trả về' })
  @IsOptional()
  @Transform(({ value }) => catKhoangTrang(value))
  @IsString()
  @MaxLength(30)
  bankCode?: string;

  @ApiPropertyOptional({
    description: 'Mã đơn, tên chủ nuôi hoặc mã giao dịch',
  })
  @IsOptional()
  @Transform(({ value }) => catKhoangTrang(value))
  @IsString()
  @MaxLength(100)
  q?: string;

  @ApiPropertyOptional({ description: 'Lọc theo lúc mở phiên, từ ngày' })
  @IsOptional()
  @IsISO8601()
  from?: string;

  @ApiPropertyOptional({ description: 'Lọc theo lúc mở phiên, tới ngày' })
  @IsOptional()
  @IsISO8601()
  to?: string;
}
