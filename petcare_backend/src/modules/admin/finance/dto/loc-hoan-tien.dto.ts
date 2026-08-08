import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { Transform } from 'class-transformer';
import {
  IsIn,
  IsISO8601,
  IsOptional,
  IsString,
  MaxLength,
  MinLength,
} from 'class-validator';
import { PaymentStatus } from '../../../../../generated/prisma/enums';
import { catKhoangTrang } from '../../chung/dto/chuyen-doi';
import { PhanTrangDto } from '../../chung/dto/phan-trang.dto';
import { LY_DO_HOAN, TRANG_THAI_HOAN } from '../hoan-tien-chung';
import type { LyDoHoan } from '../hoan-tien-chung';

export class LocHoanTienDto extends PhanTrangDto {
  @ApiPropertyOptional({ enum: TRANG_THAI_HOAN })
  @IsOptional()
  @IsIn(TRANG_THAI_HOAN)
  status?: PaymentStatus;

  @ApiPropertyOptional({ enum: LY_DO_HOAN })
  @IsOptional()
  @IsIn(LY_DO_HOAN)
  reason?: LyDoHoan;

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

  @ApiPropertyOptional({
    description: 'Lọc theo mốc lệnh hoàn phát sinh, từ ngày',
  })
  @IsOptional()
  @IsISO8601()
  from?: string;

  @ApiPropertyOptional({
    description: 'Lọc theo mốc lệnh hoàn phát sinh, tới ngày',
  })
  @IsOptional()
  @IsISO8601()
  to?: string;
}

export class DanhDauHoanDto {
  @ApiProperty({ description: 'Mã tham chiếu lượt hoàn tay ở cổng merchant' })
  @Transform(({ value }) => catKhoangTrang(value))
  @IsString()
  @MinLength(3)
  @MaxLength(100)
  reference!: string;

  @ApiPropertyOptional({ description: 'Ghi chú quản trị viên' })
  @IsOptional()
  @Transform(({ value }) => catKhoangTrang(value))
  @IsString()
  @MaxLength(300)
  note?: string;
}
