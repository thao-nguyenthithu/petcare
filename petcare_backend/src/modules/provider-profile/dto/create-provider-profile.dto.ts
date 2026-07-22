import { ApiProperty } from '@nestjs/swagger';
import {
  IsDateString,
  IsEnum,
  IsNotEmpty,
  IsString,
  Matches,
  MaxLength,
} from 'class-validator';
import { Gender } from 'generated/prisma/client';

export class CreateProviderProfileDto {
  @ApiProperty({ example: 'Nguyễn Văn An' })
  @IsString({ message: 'Họ tên không hợp lệ' })
  @IsNotEmpty({ message: 'Vui lòng nhập họ tên' })
  legalName!: string;

  @ApiProperty({ enum: Gender, example: Gender.MALE })
  @IsEnum(Gender, { message: 'Giới tính không hợp lệ' })
  gender!: Gender;

  @ApiProperty({ example: '2000-01-24', description: 'Ngày sinh yyyy-mm-dd' })
  @IsDateString({}, { message: 'Ngày sinh không hợp lệ' })
  dateOfBirth!: string;

  @ApiProperty({ example: '012345678901' })
  @Matches(/^\d{12}$/, { message: 'Số CCCD phải đủ 12 chữ số' })
  nationalId!: string;

  @ApiProperty({ example: 'Cục CSQLHC về TTXH' })
  @IsString({ message: 'Nơi cấp không hợp lệ' })
  @IsNotEmpty({ message: 'Vui lòng nhập nơi cấp' })
  idIssuedPlace!: string;

  @ApiProperty({ example: '2021-05-20', description: 'Ngày cấp yyyy-mm-dd' })
  @IsDateString({}, { message: 'Ngày cấp không hợp lệ' })
  idIssuedDate!: string;

  @ApiProperty({ example: 'Hà Nội' })
  @IsString({ message: 'Tỉnh/thành không hợp lệ' })
  @IsNotEmpty({ message: 'Vui lòng chọn tỉnh/thành' })
  province!: string;

  @ApiProperty({ example: 'Số 9, đường Quang Trung, phường Láng Hạ' })
  @IsString({ message: 'Địa chỉ không hợp lệ' })
  @IsNotEmpty({ message: 'Vui lòng nhập địa chỉ' })
  @MaxLength(255, { message: 'Địa chỉ quá dài' })
  addressDetail!: string;

  @ApiProperty({ example: 'uuid_front.jpg', description: 'Path trong Storage' })
  @IsString({ message: 'Ảnh mặt trước không hợp lệ' })
  @IsNotEmpty({ message: 'Thiếu ảnh mặt trước CCCD' })
  cccdFrontPath!: string;

  @ApiProperty({ example: 'uuid_back.jpg', description: 'Path trong Storage' })
  @IsString({ message: 'Ảnh mặt sau không hợp lệ' })
  @IsNotEmpty({ message: 'Thiếu ảnh mặt sau CCCD' })
  cccdBackPath!: string;
}
