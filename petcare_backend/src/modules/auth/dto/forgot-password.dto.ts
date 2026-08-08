import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { IsEmail, IsIn, IsOptional } from 'class-validator';

export class ForgotPasswordDto {
  @ApiProperty({ example: 'user@example.com' })
  @IsEmail({}, { message: 'Email không hợp lệ' })
  email!: string;

  @ApiPropertyOptional({
    enum: ['app', 'admin'],
    default: 'app',
    description:
      'Nơi gọi. app là ứng dụng di động, admin là web quản trị và chỉ nhận tài khoản vai trò ADMIN',
  })
  @IsOptional()
  @IsIn(['app', 'admin'], { message: 'Phạm vi không hợp lệ' })
  scope?: 'app' | 'admin';
}
