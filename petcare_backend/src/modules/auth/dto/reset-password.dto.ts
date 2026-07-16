import { ApiProperty } from '@nestjs/swagger';
import { IsString, MinLength } from 'class-validator';

export class ResetPasswordDto {
  @ApiProperty({ description: 'Token đặt lại mật khẩu dùng một lần' })
  @IsString({ message: 'Token không hợp lệ' })
  resetToken!: string;

  @ApiProperty({ example: 'newpassword123' })
  @IsString({ message: 'Mật khẩu không hợp lệ' })
  @MinLength(6, { message: 'Mật khẩu tối thiểu 6 ký tự' })
  newPassword!: string;
}
