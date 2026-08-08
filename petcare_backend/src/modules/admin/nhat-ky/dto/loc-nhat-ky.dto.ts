import { ApiPropertyOptional } from '@nestjs/swagger';
import { IsIn, IsOptional } from 'class-validator';
import {
  HANH_DONG_NHAT_KY,
  LOAI_DOI_TUONG_NHAT_KY,
} from '../../chung/hanh-dong-nhat-ky';
import type {
  HanhDongNhatKy,
  LoaiDoiTuong,
} from '../../chung/hanh-dong-nhat-ky';
import { PhanTrangDto } from '../../chung/dto/phan-trang.dto';

export class LocNhatKyDto extends PhanTrangDto {
  @ApiPropertyOptional({ enum: HANH_DONG_NHAT_KY })
  @IsOptional()
  @IsIn(HANH_DONG_NHAT_KY)
  action?: HanhDongNhatKy;

  @ApiPropertyOptional({ enum: LOAI_DOI_TUONG_NHAT_KY })
  @IsOptional()
  @IsIn(LOAI_DOI_TUONG_NHAT_KY)
  targetType?: LoaiDoiTuong;
}
