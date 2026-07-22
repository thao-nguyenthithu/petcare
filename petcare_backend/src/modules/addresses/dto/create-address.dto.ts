import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import {
  IsEnum,
  IsNotEmpty,
  IsNumber,
  IsOptional,
  IsString,
  Max,
  MaxLength,
  Min,
} from 'class-validator';
import { AddressLabel } from 'generated/prisma/client';

export class CreateAddressDto {
  @ApiProperty({ enum: AddressLabel, example: AddressLabel.HOME })
  @IsEnum(AddressLabel, { message: 'Nhãn địa chỉ không hợp lệ' })
  label!: AddressLabel;

  @ApiPropertyOptional({ example: 'Nhà bạn gái' })
  @IsOptional()
  @IsString({ message: 'Tên nhãn không hợp lệ' })
  @MaxLength(50, { message: 'Tên nhãn quá dài' })
  customLabel?: string;

  @ApiProperty({ example: 'Hà Nội' })
  @IsString({ message: 'Tỉnh/thành không hợp lệ' })
  @IsNotEmpty({ message: 'Thiếu tỉnh/thành' })
  province!: string;

  @ApiProperty({ example: 'Phường Khương Đình' })
  @IsString({ message: 'Phường/xã không hợp lệ' })
  @IsNotEmpty({ message: 'Thiếu phường/xã' })
  ward!: string;

  @ApiProperty({ example: 'Viện vật liệu xây dựng, 235, Đường Nguyễn Trãi' })
  @IsString({ message: 'Số nhà/đường không hợp lệ' })
  @MaxLength(255, { message: 'Số nhà/đường quá dài' })
  street!: string;

  @ApiPropertyOptional({ example: 'Tầng 3, toà A, gần thang máy' })
  @IsOptional()
  @IsString({ message: 'Ghi chú không hợp lệ' })
  @MaxLength(255, { message: 'Ghi chú quá dài' })
  note?: string;

  @ApiProperty({ example: 20.9955 })
  @IsNumber({}, { message: 'Vĩ độ không hợp lệ' })
  @Min(-90, { message: 'Vĩ độ không hợp lệ' })
  @Max(90, { message: 'Vĩ độ không hợp lệ' })
  lat!: number;

  @ApiProperty({ example: 105.8006 })
  @IsNumber({}, { message: 'Kinh độ không hợp lệ' })
  @Min(-180, { message: 'Kinh độ không hợp lệ' })
  @Max(180, { message: 'Kinh độ không hợp lệ' })
  lng!: number;
}
