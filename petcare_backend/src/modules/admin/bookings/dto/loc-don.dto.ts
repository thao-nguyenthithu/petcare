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
import { ServiceType } from '../../../../../generated/prisma/enums';
import { catKhoangTrang } from '../../chung/dto/chuyen-doi';
import { PhanTrangDto } from '../../chung/dto/phan-trang.dto';

// Tab gộp nhiều trạng thái nên lọc theo tab, một mình status không dựng nổi màn
export const TAB_DON = [
  'all',
  'awaitingPayment',
  'pending',
  'confirmed',
  'running',
  'awaitingConfirm',
  'completed',
  'cancelled',
  'disputed',
] as const;
export type TabDon = (typeof TAB_DON)[number];

export const COT_SAP_XEP_DON = [
  'createdAt',
  'scheduledAt',
  'totalPrice',
] as const;

export class LocDonDto extends PhanTrangDto {
  @ApiPropertyOptional({
    description: 'Mã đơn, tên chủ nuôi hoặc tên người chăm',
  })
  @IsOptional()
  @Transform(({ value }) => catKhoangTrang(value))
  @IsString()
  @MaxLength(100)
  q?: string;

  @ApiPropertyOptional({ enum: TAB_DON })
  @IsOptional()
  @IsIn(TAB_DON)
  tab?: TabDon;

  @ApiPropertyOptional({ enum: ServiceType })
  @IsOptional()
  @IsIn(Object.values(ServiceType))
  serviceType?: ServiceType;

  @ApiPropertyOptional({ description: 'Lọc theo lịch hẹn, từ ngày' })
  @IsOptional()
  @IsISO8601()
  from?: string;

  @ApiPropertyOptional({ description: 'Lọc theo lịch hẹn, tới ngày' })
  @IsOptional()
  @IsISO8601()
  to?: string;

  @ApiPropertyOptional({ enum: COT_SAP_XEP_DON })
  @IsOptional()
  @IsIn(COT_SAP_XEP_DON)
  sort?: (typeof COT_SAP_XEP_DON)[number];

  @ApiPropertyOptional({ enum: ['asc', 'desc'] })
  @IsOptional()
  @IsIn(['asc', 'desc'])
  dir?: 'asc' | 'desc';
}

export class CanThiepHuyDonDto {
  @ApiProperty({ description: 'Lý do, ghi vào nhật ký và gửi cho hai bên' })
  @Transform(({ value }) => catKhoangTrang(value))
  @IsString()
  @MinLength(3)
  @MaxLength(300)
  reason!: string;
}
