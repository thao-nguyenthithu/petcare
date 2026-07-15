import { ApiProperty } from '@nestjs/swagger';
import {
  IsEmail,
  IsNotEmpty,
  IsString,
  Matches,
  MinLength,
} from 'class-validator';

export class RegisterDto {
  @ApiProperty({ example: 'Nguyễn Văn An' })
  @IsString({ message: 'Họ và tên không hợp lệ' })
  @IsNotEmpty({ message: 'Vui lòng nhập họ và tên' })
  fullName!: string;

  @ApiProperty({ example: 'user@example.com' })
  @IsEmail({}, { message: 'Email không hợp lệ' })
  email!: string;

  @ApiProperty({ example: '0912345678' })
  @Matches(/^(0|\+84)[35789]\d{8}$/, { message: 'Số điện thoại không hợp lệ' })
  phone!: string;

  @ApiProperty({ example: 'password123', minLength: 6 })
  @IsString({ message: 'Mật khẩu không hợp lệ' })
  @MinLength(6, { message: 'Mật khẩu tối thiểu 6 ký tự' })
  password!: string;
}
