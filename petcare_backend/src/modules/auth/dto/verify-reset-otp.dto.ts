import { ApiProperty } from '@nestjs/swagger';
import { IsEmail, Matches } from 'class-validator';

export class VerifyResetOtpDto {
  @ApiProperty({ example: 'user@example.com' })
  @IsEmail({}, { message: 'Email không hợp lệ' })
  email!: string;

  @ApiProperty({ example: '123456', description: 'Mã OTP 6 số nhận qua email' })
  @Matches(/^\d{6}$/, { message: 'Mã xác minh phải gồm 6 chữ số' })
  otp!: string;
}
