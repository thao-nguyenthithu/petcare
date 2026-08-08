import { ApiPropertyOptional } from '@nestjs/swagger';
import { Transform } from 'class-transformer';
import {
  IsEnum,
  IsIn,
  IsOptional,
  IsString,
  Matches,
  MaxLength,
} from 'class-validator';
import { UserRole } from '../../../../../generated/prisma/enums';
import { MAU_NGAY } from '../../../../common/thoi-gian-vn';
import { catKhoangTrang, veBoolean } from '../../chung/dto/chuyen-doi';
import { PhanTrangDto } from '../../chung/dto/phan-trang.dto';

// Whitelist cột sắp xếp của màn 03, tên khác rơi về cột mặc định
export const COT_SAP_XEP_NGUOI_DUNG = [
  'createdAt',
  'fullName',
  'email',
] as const;

export class LocNguoiDungDto extends PhanTrangDto {
  @ApiPropertyOptional({
    description: 'Tìm theo tên, email hoặc số điện thoại',
  })
  @IsOptional()
  @Transform(({ value }) => catKhoangTrang(value))
  @IsString()
  @MaxLength(100)
  q?: string;

  @ApiPropertyOptional({ enum: UserRole })
  @IsOptional()
  @IsEnum(UserRole)
  role?: UserRole;

  @ApiPropertyOptional({
    description: 'true là đang hoạt động, false là bị khoá',
  })
  @IsOptional()
  @Transform(({ value }) => veBoolean(value))
  active?: boolean;

  @ApiPropertyOptional({ description: 'Tỉnh hoặc thành của địa chỉ mặc định' })
  @IsOptional()
  @Transform(({ value }) => catKhoangTrang(value))
  @IsString()
  @MaxLength(100)
  province?: string;

  @ApiPropertyOptional({ description: 'Ngày tạo từ, dạng YYYY-MM-DD' })
  @IsOptional()
  @Matches(MAU_NGAY)
  from?: string;

  @ApiPropertyOptional({ description: 'Ngày tạo đến, dạng YYYY-MM-DD' })
  @IsOptional()
  @Matches(MAU_NGAY)
  to?: string;

  @ApiPropertyOptional({ enum: COT_SAP_XEP_NGUOI_DUNG })
  @IsOptional()
  @IsIn(COT_SAP_XEP_NGUOI_DUNG)
  sort?: (typeof COT_SAP_XEP_NGUOI_DUNG)[number];

  @ApiPropertyOptional({ enum: ['asc', 'desc'] })
  @IsOptional()
  @IsIn(['asc', 'desc'])
  dir?: 'asc' | 'desc';
}
