import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { Transform, Type } from 'class-transformer';
import {
  ArrayMaxSize,
  IsArray,
  IsInt,
  IsOptional,
  IsString,
  Max,
  MaxLength,
  Min,
} from 'class-validator';
import { chuoiThanhMang } from '../../../common/multipart';

export const SO_ANH_DANH_GIA = 6;
export const SO_CHIP_KHEN = 5;

// Ảnh đi ở phần multipart nên DTO chỉ giữ phần chữ và số
export class CreateReviewDto {
  @ApiProperty({ minimum: 1, maximum: 5, example: 5 })
  @Type(() => Number)
  @IsInt({ message: 'Số sao không hợp lệ' })
  @Min(1, { message: 'Chọn ít nhất 1 sao' })
  @Max(5, { message: 'Số sao tối đa là 5' })
  rating!: number;

  @ApiPropertyOptional({ example: 'Bé về nhà vui vẻ, người chăm rất chu đáo' })
  @IsOptional()
  @IsString({ message: 'Nhận xét không hợp lệ' })
  @MaxLength(1000, { message: 'Nhận xét tối đa 1000 ký tự' })
  comment?: string;

  @ApiPropertyOptional({
    type: [String],
    description: 'Mã chip khen, app tự dịch sang chữ hiển thị',
  })
  @IsOptional()
  @IsArray({ message: 'Danh sách chip khen không hợp lệ' })
  @ArrayMaxSize(SO_CHIP_KHEN, {
    message: `Chọn tối đa ${SO_CHIP_KHEN} chip khen`,
  })
  @IsString({ each: true, message: 'Mã chip khen không hợp lệ' })
  @MaxLength(40, { each: true })
  @Transform(({ value }) => chuoiThanhMang(value))
  praiseTags?: string[];
}
