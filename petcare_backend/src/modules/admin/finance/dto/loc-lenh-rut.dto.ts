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
import { WithdrawalStatus } from '../../../../../generated/prisma/enums';
import { catKhoangTrang } from '../../chung/dto/chuyen-doi';
import { PhanTrangDto } from '../../chung/dto/phan-trang.dto';

export class LocLenhRutDto extends PhanTrangDto {
  @ApiPropertyOptional({ enum: WithdrawalStatus })
  @IsOptional()
  @IsIn(Object.values(WithdrawalStatus))
  status?: WithdrawalStatus;

  @ApiPropertyOptional({
    description:
      'Tên người chăm, tên chủ tài khoản, số tài khoản hoặc mã tham chiếu',
  })
  @IsOptional()
  @Transform(({ value }) => catKhoangTrang(value))
  @IsString()
  @MaxLength(100)
  q?: string;

  @ApiPropertyOptional({ description: 'Lọc theo lúc tạo lệnh, từ ngày' })
  @IsOptional()
  @IsISO8601()
  from?: string;

  @ApiPropertyOptional({ description: 'Lọc theo lúc tạo lệnh, tới ngày' })
  @IsOptional()
  @IsISO8601()
  to?: string;
}

// Ba lối duy nhất, không lối nào lùi được vì tiền đã rời ngân hàng
export const CHUYEN_LENH_RUT = ['SENT', 'DONE', 'REJECTED'] as const;
export type ChuyenLenhRut = (typeof CHUYEN_LENH_RUT)[number];

export class DoiLenhRutDto {
  @ApiProperty({ enum: CHUYEN_LENH_RUT })
  @IsIn(CHUYEN_LENH_RUT)
  status!: ChuyenLenhRut;

  @ApiPropertyOptional({ description: 'Mã tham chiếu lượt chuyển khoản tay' })
  @IsOptional()
  @Transform(({ value }) => catKhoangTrang(value))
  @IsString()
  @MinLength(3)
  @MaxLength(100)
  reference?: string;

  @ApiPropertyOptional({ description: 'Lý do từ chối lệnh rút' })
  @IsOptional()
  @Transform(({ value }) => catKhoangTrang(value))
  @IsString()
  @MinLength(3)
  @MaxLength(300)
  rejectReason?: string;
}
