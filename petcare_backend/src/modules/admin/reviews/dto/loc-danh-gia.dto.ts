import { ApiPropertyOptional } from '@nestjs/swagger';
import { Transform, Type } from 'class-transformer';
import {
  IsBoolean,
  IsIn,
  IsISO8601,
  IsInt,
  IsOptional,
  IsString,
  Max,
  MaxLength,
  Min,
} from 'class-validator';
import { ServiceType } from '../../../../../generated/prisma/enums';
import { catKhoangTrang } from '../../chung/dto/chuyen-doi';
import { PhanTrangDto } from '../../chung/dto/phan-trang.dto';

function raBoolean({ value }: { value: unknown }): unknown {
  if (value === 'true' || value === true) return true;
  if (value === 'false' || value === false) return false;
  return value;
}

export class LocDanhGiaDto extends PhanTrangDto {
  @ApiPropertyOptional({ description: 'Nội dung, tên người chăm hoặc mã đơn' })
  @IsOptional()
  @Transform(({ value }) => catKhoangTrang(value))
  @IsString()
  @MaxLength(100)
  q?: string;

  @ApiPropertyOptional({
    description: 'Số sao thấp nhất, tab 1-2 sao gửi khoảng',
  })
  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(1)
  @Max(5)
  ratingFrom?: number;

  @ApiPropertyOptional({ description: 'Số sao cao nhất' })
  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(1)
  @Max(5)
  ratingTo?: number;

  @ApiPropertyOptional({ enum: ServiceType })
  @IsOptional()
  @IsIn(Object.values(ServiceType))
  serviceType?: ServiceType;

  @ApiPropertyOptional({ description: 'Chỉ đánh giá có ảnh kèm' })
  @IsOptional()
  @Transform(raBoolean)
  @IsBoolean()
  hasPhotos?: boolean;

  @ApiPropertyOptional({
    description: 'Đã có phản hồi của người chăm hay chưa',
  })
  @IsOptional()
  @Transform(raBoolean)
  @IsBoolean()
  replied?: boolean;

  @ApiPropertyOptional({ description: 'Lọc theo lúc gửi đánh giá, từ ngày' })
  @IsOptional()
  @IsISO8601()
  from?: string;

  @ApiPropertyOptional({ description: 'Lọc theo lúc gửi đánh giá, tới ngày' })
  @IsOptional()
  @IsISO8601()
  to?: string;
}
