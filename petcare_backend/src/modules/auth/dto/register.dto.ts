import { ApiProperty } from '@nestjs/swagger';
import {
  IsEmail,
  IsNotEmpty,
  IsString,
  Matches,
  MaxLength,
  MinLength,
} from 'class-validator';
import { MAT_KHAU_TOI_THIEU } from '../auth.constants';

export class RegisterDto {
  @ApiProperty({ example: 'Nguyễn Văn An' })
  @IsString({ message: 'Họ và tên không hợp lệ' })
  @IsNotEmpty({ message: 'Vui lòng nhập họ và tên' })
  @MaxLength(80, { message: 'Họ và tên quá dài' })
  fullName!: string;

  @ApiProperty({ example: 'user@example.com' })
  @IsEmail({}, { message: 'Email không hợp lệ' })
  email!: string;

  @ApiProperty({ example: '0912345678' })
  @Matches(/^(0|\+84)[35789]\d{8}$/, { message: 'Số điện thoại không hợp lệ' })
  phone!: string;

  @ApiProperty({ example: 'password123', minLength: MAT_KHAU_TOI_THIEU })
  @IsString({ message: 'Mật khẩu không hợp lệ' })
  @MinLength(MAT_KHAU_TOI_THIEU, {
    message: `Mật khẩu tối thiểu ${MAT_KHAU_TOI_THIEU} ký tự`,
  })
  password!: string;
}
