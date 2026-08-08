import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { Transform } from 'class-transformer';
import {
  IsBoolean,
  IsIn,
  IsInt,
  IsOptional,
  IsString,
  Max,
  MaxLength,
  Min,
  MinLength,
} from 'class-validator';
import { ServiceType } from '../../../../../generated/prisma/enums';
import { catKhoangTrang } from '../../chung/dto/chuyen-doi';
import { PhanTrangDto } from '../../chung/dto/phan-trang.dto';

// Bốn tab của màn 06. Hồ sơ khoá vĩnh viễn không thuộc tab nào, chỉ tra bằng tìm kiếm
export const TAB_NGUOI_CHAM = [
  'pending',
  'active',
  'rejected',
  'hidden',
] as const;
export type TabNguoiCham = (typeof TAB_NGUOI_CHAM)[number];

export const COT_SAP_XEP_NGUOI_CHAM = [
  'createdAt',
  'submittedAt',
  'ratingAvg',
] as const;

export class LocNguoiChamDto extends PhanTrangDto {
  @ApiPropertyOptional({ description: 'Tìm theo tên, email hoặc số căn cước' })
  @IsOptional()
  @Transform(({ value }) => catKhoangTrang(value))
  @IsString()
  @MaxLength(100)
  q?: string;

  @ApiPropertyOptional({ enum: TAB_NGUOI_CHAM })
  @IsOptional()
  @IsIn(TAB_NGUOI_CHAM)
  tab?: TabNguoiCham;

  @ApiPropertyOptional({ enum: ServiceType })
  @IsOptional()
  @IsIn(Object.values(ServiceType))
  service?: ServiceType;

  @ApiPropertyOptional()
  @IsOptional()
  @Transform(({ value }) => catKhoangTrang(value))
  @IsString()
  @MaxLength(100)
  province?: string;

  @ApiPropertyOptional({ enum: COT_SAP_XEP_NGUOI_CHAM })
  @IsOptional()
  @IsIn(COT_SAP_XEP_NGUOI_CHAM)
  sort?: (typeof COT_SAP_XEP_NGUOI_CHAM)[number];

  @ApiPropertyOptional({ enum: ['asc', 'desc'] })
  @IsOptional()
  @IsIn(['asc', 'desc'])
  dir?: 'asc' | 'desc';
}

// Trần ngày ẩn tay: dài hơn bậc nặng nhất của thang tự động thì dùng khoá hẳn
export const TRAN_NGAY_AN_TAY = 30;

export class TamAnDto {
  @ApiProperty({ description: 'Số ngày tạm ẩn', example: 7 })
  @IsInt()
  @Min(1)
  @Max(TRAN_NGAY_AN_TAY)
  days!: number;

  @ApiProperty({ description: 'Lý do, ghi vào nhật ký và gửi cho người chăm' })
  @Transform(({ value }) => catKhoangTrang(value))
  @IsString()
  @MinLength(3)
  @MaxLength(300)
  reason!: string;
}

export class KhoaVinhVienDto {
  @ApiProperty({ description: 'true là khoá, false là gỡ khoá' })
  @IsBoolean()
  banned!: boolean;

  @ApiProperty({ description: 'Lý do, ghi vào nhật ký và gửi cho người chăm' })
  @Transform(({ value }) => catKhoangTrang(value))
  @IsString()
  @MinLength(3)
  @MaxLength(300)
  reason!: string;
}

export class YeuCauBoSungDto {
  @ApiProperty({ description: 'Nêu rõ thiếu gì, gửi thẳng cho người chăm' })
  @Transform(({ value }) => catKhoangTrang(value))
  @IsString()
  @MinLength(3)
  @MaxLength(300)
  reason!: string;
}

export class DuyetHoSoDto {
  @ApiProperty({ enum: ['APPROVED', 'REJECTED'] })
  @IsIn(['APPROVED', 'REJECTED'])
  status!: 'APPROVED' | 'REJECTED';

  @ApiPropertyOptional({ description: 'Bắt buộc khi từ chối' })
  @IsOptional()
  @Transform(({ value }) => catKhoangTrang(value))
  @IsString()
  @MinLength(3)
  @MaxLength(300)
  reason?: string;
}
