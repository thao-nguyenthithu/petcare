import { ApiProperty } from '@nestjs/swagger';
import { IsEmail, IsString, MinLength } from 'class-validator';
import { MAT_KHAU_TOI_THIEU } from '../auth.constants';

export class LoginDto {
  @ApiProperty({ example: 'user@example.com' })
  @IsEmail({}, { message: 'Email không hợp lệ' })
  email!: string;

  @ApiProperty({ example: 'password123' })
  @IsString({ message: 'Mật khẩu không hợp lệ' })
  @MinLength(MAT_KHAU_TOI_THIEU, {
    message: `Mật khẩu tối thiểu ${MAT_KHAU_TOI_THIEU} ký tự`,
  })
  password!: string;
}
