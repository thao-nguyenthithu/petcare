import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { IsEmail, IsIn, IsOptional, Matches } from 'class-validator';

export class VerifyResetOtpDto {
  @ApiProperty({ example: 'user@example.com' })
  @IsEmail({}, { message: 'Email không hợp lệ' })
  email!: string;

  @ApiProperty({ example: '123456', description: 'Mã OTP 6 số nhận qua email' })
  @Matches(/^\d{6}$/, { message: 'Mã xác minh phải gồm 6 chữ số' })
  otp!: string;

  @ApiPropertyOptional({
    enum: ['app', 'admin'],
    default: 'app',
    description: 'Phải trùng scope đã dùng ở bước gửi mã',
  })
  @IsOptional()
  @IsIn(['app', 'admin'], { message: 'Phạm vi không hợp lệ' })
  scope?: 'app' | 'admin';
}
