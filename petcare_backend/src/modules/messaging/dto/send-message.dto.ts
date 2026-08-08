import { ApiPropertyOptional } from '@nestjs/swagger';
import {
  IsLatitude,
  IsLongitude,
  IsOptional,
  IsString,
  MaxLength,
} from 'class-validator';

export class SendMessageDto {
  @ApiPropertyOptional({ description: 'Nội dung chữ' })
  @IsOptional()
  @IsString()
  @MaxLength(2000, { message: 'Tin nhắn quá dài' })
  text?: string;

  @ApiPropertyOptional({ description: 'Ghi chú dưới khối ảnh hoặc vị trí' })
  @IsOptional()
  @IsString()
  @MaxLength(500)
  caption?: string;

  @ApiPropertyOptional({ description: 'Vĩ độ của tin vị trí' })
  @IsOptional()
  @IsLatitude()
  lat?: number;

  @ApiPropertyOptional({ description: 'Kinh độ của tin vị trí' })
  @IsOptional()
  @IsLongitude()
  lng?: number;
}
