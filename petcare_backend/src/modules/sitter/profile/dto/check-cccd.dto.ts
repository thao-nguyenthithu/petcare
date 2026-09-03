import { ApiProperty } from '@nestjs/swagger';
import { Matches } from 'class-validator';

export class CheckCccdDto {
  @ApiProperty({ example: '012345678901' })
  @Matches(/^\d{12}$/, { message: 'Số CCCD phải đủ 12 chữ số' })
  nationalId!: string;
}
