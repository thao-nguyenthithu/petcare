import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { IsIn, IsNotEmpty, IsOptional, IsString } from 'class-validator';

export class DeviceTokenDto {
  @ApiProperty({ description: 'Token FCM do Firebase cấp cho lượt cài app' })
  @IsString({ message: 'Token thiết bị không hợp lệ' })
  @IsNotEmpty({ message: 'Thiếu token thiết bị' })
  token!: string;

  @ApiProperty({ enum: ['android', 'ios', 'web'], example: 'android' })
  @IsIn(['android', 'ios', 'web'], { message: 'Nền tảng không hợp lệ' })
  platform!: string;

  @ApiPropertyOptional({ enum: ['vi', 'en'], default: 'vi' })
  @IsOptional()
  @IsIn(['vi', 'en'], { message: 'Ngôn ngữ không hợp lệ' })
  locale?: string;
}
