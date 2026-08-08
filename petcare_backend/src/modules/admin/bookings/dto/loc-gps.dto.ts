import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { Transform, Type } from 'class-transformer';
import {
  IsBoolean,
  IsIn,
  IsISO8601,
  IsNumber,
  IsOptional,
  IsString,
  Max,
  MaxLength,
  Min,
  MinLength,
} from 'class-validator';
import { catKhoangTrang, veBoolean } from '../../chung/dto/chuyen-doi';
import { PhanTrangDto } from '../../chung/dto/phan-trang.dto';
import { TAB_GPS } from '../tra-soat-gps';
import type { TabGps } from '../tra-soat-gps';

export const COT_SAP_XEP_GPS = ['createdAt', 'suspicionScore'] as const;

// Trần lý do dùng chung với can thiệp huỷ đơn, cùng vai ghi vào nhật ký quản trị
export const DAI_TOI_DA_GHI_CHU = 300;

export class LocGpsDto extends PhanTrangDto {
  @ApiPropertyOptional({ description: 'Mã đơn hoặc tên người chăm' })
  @IsOptional()
  @Transform(({ value }) => catKhoangTrang(value))
  @IsString()
  @MaxLength(100)
  q?: string;

  @ApiPropertyOptional({
    enum: TAB_GPS,
    description: 'Điều kiện từng tab do máy chủ giữ, web chỉ gửi tên tab',
  })
  @IsOptional()
  @IsIn(TAB_GPS)
  tab?: TabGps;

  @ApiPropertyOptional({ description: 'Còn gắn cờ hay đã soát xong' })
  @IsOptional()
  @Transform(({ value }) => veBoolean(value))
  @IsBoolean()
  flagged?: boolean;

  @ApiPropertyOptional({
    description: 'Điểm nghi ngờ từ mức này trở lên, đơn chưa có điểm bị loại',
  })
  @IsOptional()
  @Type(() => Number)
  @IsNumber()
  @Min(0)
  @Max(1)
  minScore?: number;

  @ApiPropertyOptional({ description: 'Lọc theo lúc chốt báo cáo, từ ngày' })
  @IsOptional()
  @IsISO8601()
  from?: string;

  @ApiPropertyOptional({ description: 'Lọc theo lúc chốt báo cáo, tới ngày' })
  @IsOptional()
  @IsISO8601()
  to?: string;

  @ApiPropertyOptional({ enum: COT_SAP_XEP_GPS })
  @IsOptional()
  @IsIn(COT_SAP_XEP_GPS)
  sort?: (typeof COT_SAP_XEP_GPS)[number];

  @ApiPropertyOptional({ enum: ['asc', 'desc'] })
  @IsOptional()
  @IsIn(['asc', 'desc'])
  dir?: 'asc' | 'desc';
}

export class SoatGpsDto {
  @ApiProperty({ description: 'Gỡ cờ khi đã xem xong, giữ cờ thì để false' })
  @Transform(({ value }) => veBoolean(value))
  @IsBoolean()
  cleared!: boolean;

  @ApiProperty({
    description: 'Ghi chú của người soát, dùng lại khi có khiếu nại',
  })
  @Transform(({ value }) => catKhoangTrang(value))
  @IsString()
  @MinLength(3)
  @MaxLength(DAI_TOI_DA_GHI_CHU)
  note!: string;
}
