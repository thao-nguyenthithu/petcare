import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { Transform } from 'class-transformer';
import {
  IsIn,
  IsISO8601,
  IsInt,
  IsOptional,
  IsString,
  MaxLength,
  Min,
  MinLength,
} from 'class-validator';
import {
  PenaltyKind,
  ReportStatus,
  ServiceType,
} from '../../../../../generated/prisma/enums';
import { catKhoangTrang } from '../../chung/dto/chuyen-doi';
import { PhanTrangDto } from '../../chung/dto/phan-trang.dto';

// Ba tình trạng suy ra từ dữ liệu, máy chủ dựng điều kiện vì danh sách phân trang ở đây
export const TAB_KHIEU_NAI = [
  'waitingSitter',
  'waitingSupport',
  'resolved',
] as const;
export type TabKhieuNai = (typeof TAB_KHIEU_NAI)[number];

export const SAP_XEP_KHIEU_NAI = ['hanKetLuan', 'moiNhat'] as const;

export class LocKhieuNaiDto extends PhanTrangDto {
  @ApiPropertyOptional({ description: 'Mã hồ sơ, mã đơn hoặc tên hai bên' })
  @IsOptional()
  @Transform(({ value }) => catKhoangTrang(value))
  @IsString()
  @MaxLength(100)
  q?: string;

  @ApiPropertyOptional({ enum: TAB_KHIEU_NAI })
  @IsOptional()
  @IsIn(TAB_KHIEU_NAI)
  tab?: TabKhieuNai;

  @ApiPropertyOptional({ enum: ReportStatus })
  @IsOptional()
  @IsIn(Object.values(ReportStatus))
  status?: ReportStatus;

  @ApiPropertyOptional({ enum: ServiceType })
  @IsOptional()
  @IsIn(Object.values(ServiceType))
  serviceType?: ServiceType;

  @ApiPropertyOptional({ description: 'Lọc theo lúc mở hồ sơ, từ ngày' })
  @IsOptional()
  @IsISO8601()
  from?: string;

  @ApiPropertyOptional({ description: 'Lọc theo lúc mở hồ sơ, tới ngày' })
  @IsOptional()
  @IsISO8601()
  to?: string;

  @ApiPropertyOptional({ enum: SAP_XEP_KHIEU_NAI })
  @IsOptional()
  @IsIn(SAP_XEP_KHIEU_NAI)
  sort?: (typeof SAP_XEP_KHIEU_NAI)[number];
}

export class KetLuanKhieuNaiDto {
  @ApiProperty({ description: 'Nội dung kết luận, ghi vào hồ sơ' })
  @Transform(({ value }) => catKhoangTrang(value))
  @IsString()
  @MinLength(3)
  @MaxLength(300)
  resolution!: string;

  @ApiProperty({
    description: 'Hoàn 0 đồng là bác khiếu nại, vẫn phải ghi lý do',
  })
  @Transform(({ value }) => catKhoangTrang(value))
  @IsString()
  @MinLength(3)
  @MaxLength(1000)
  resolutionReason!: string;

  @ApiProperty({ description: 'Khoản hoàn cho chủ nuôi, trần là giá trị đơn' })
  @IsInt()
  @Min(0)
  refundAmount!: number;

  @ApiPropertyOptional({ enum: PenaltyKind })
  @IsOptional()
  @IsIn(Object.values(PenaltyKind))
  penalty?: PenaltyKind;

  @ApiPropertyOptional({ description: 'Bắn thông báo kết luận cho cả hai vai' })
  @IsOptional()
  @Transform(({ value }) => value === true || value === 'true')
  notifyBoth?: boolean;
}
