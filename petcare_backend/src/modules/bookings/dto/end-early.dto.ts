import { ApiProperty } from '@nestjs/swagger';
import { Matches } from 'class-validator';
import { MAU_GIO, MAU_NGAY } from '../../../common/thoi-gian-vn';

export class EndEarlyDto {
  @ApiProperty({ example: '2026-08-12' })
  @Matches(MAU_NGAY, { message: 'endDate phải dạng YYYY-MM-DD' })
  endDate!: string;

  @ApiProperty({ example: '17:00' })
  @Matches(MAU_GIO, { message: 'endTime phải dạng HH:mm' })
  endTime!: string;
}
