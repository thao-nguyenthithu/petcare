import { ApiProperty } from '@nestjs/swagger';
import { IsString, MinLength } from 'class-validator';
import { MAT_KHAU_TOI_THIEU } from '../auth.constants';

export class ResetPasswordDto {
  @ApiProperty({ description: 'Token đặt lại mật khẩu dùng một lần' })
  @IsString({ message: 'Token không hợp lệ' })
  resetToken!: string;

  @ApiProperty({ example: 'newpassword123' })
  @IsString({ message: 'Mật khẩu không hợp lệ' })
  @MinLength(MAT_KHAU_TOI_THIEU, {
    message: `Mật khẩu tối thiểu ${MAT_KHAU_TOI_THIEU} ký tự`,
  })
  newPassword!: string;
}
