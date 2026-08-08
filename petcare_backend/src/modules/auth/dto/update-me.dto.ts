import { ApiPropertyOptional } from '@nestjs/swagger';
import {
  IsNotEmpty,
  IsOptional,
  IsString,
  Matches,
  MaxLength,
} from 'class-validator';

export class UpdateMeDto {
  @ApiPropertyOptional({ example: 'Nguyễn Văn An' })
  @IsOptional()
  @IsString({ message: 'Họ và tên không hợp lệ' })
  @IsNotEmpty({ message: 'Vui lòng nhập họ và tên' })
  @MaxLength(80, { message: 'Họ và tên quá dài' })
  fullName?: string;

  @ApiPropertyOptional({ example: '0912345678' })
  @IsOptional()
  @Matches(/^(0|\+84)[35789]\d{8}$/, { message: 'Số điện thoại không hợp lệ' })
  phone?: string;

  @ApiPropertyOptional({ example: '1999-08-24' })
  @IsOptional()
  @Matches(/^(\d{4}-\d{2}-\d{2})?$/, { message: 'Ngày sinh không hợp lệ' })
  dateOfBirth?: string;
}
