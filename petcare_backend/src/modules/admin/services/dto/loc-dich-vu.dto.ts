import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { Transform } from 'class-transformer';
import {
  IsBoolean,
  IsIn,
  IsOptional,
  IsString,
  MaxLength,
  MinLength,
} from 'class-validator';
import { ServiceType } from '../../../../../generated/prisma/enums';
import { catKhoangTrang, veBoolean } from '../../chung/dto/chuyen-doi';
import { PhanTrangDto } from '../../chung/dto/phan-trang.dto';

export const TEN_DICH_VU_TOI_DA = 60;
export const MO_TA_DICH_VU_TOI_DA = 300;
export const LY_DO_TOI_THIEU = 3;
export const LY_DO_TOI_DA = 300;

export class LocCauHinhDto extends PhanTrangDto {
  @ApiPropertyOptional({ description: 'Tìm theo tên người chăm' })
  @IsOptional()
  @Transform(({ value }) => catKhoangTrang(value))
  @IsString()
  @MaxLength(100)
  q?: string;

  @ApiPropertyOptional({ enum: ServiceType })
  @IsOptional()
  @IsIn(Object.values(ServiceType))
  type?: ServiceType;

  @ApiPropertyOptional({ description: 'true là đang bật, false là đang tắt' })
  @IsOptional()
  @Transform(({ value }) => veBoolean(value))
  @IsBoolean()
  enabled?: boolean;
}

// Không có giá và thời lượng: hai thứ đó đóng băng theo từng đơn (bộ luật mục 2)
export class SuaDichVuDto {
  @ApiProperty({ description: 'Tên hiện trên đơn của cả hai vai' })
  @Transform(({ value }) => catKhoangTrang(value))
  @IsString()
  @MinLength(2)
  @MaxLength(TEN_DICH_VU_TOI_DA)
  name!: string;

  @ApiPropertyOptional({ description: 'Mô tả nội bộ, để trống là xoá' })
  @IsOptional()
  @Transform(({ value }) => catKhoangTrang(value))
  @IsString()
  @MaxLength(MO_TA_DICH_VU_TOI_DA)
  description?: string;
}

export class DatBatCauHinhDto {
  @ApiProperty({ description: 'true là mở lại, false là khoá' })
  @IsBoolean()
  enabled!: boolean;

  @ApiProperty({ description: 'Lý do, ghi vào nhật ký thao tác' })
  @Transform(({ value }) => catKhoangTrang(value))
  @IsString()
  @MinLength(LY_DO_TOI_THIEU)
  @MaxLength(LY_DO_TOI_DA)
  reason!: string;
}
