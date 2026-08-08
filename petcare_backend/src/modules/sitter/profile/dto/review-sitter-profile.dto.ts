import { ApiProperty } from '@nestjs/swagger';
import { IsIn } from 'class-validator';

export class ReviewSitterProfileDto {
  @ApiProperty({ enum: ['APPROVED', 'REJECTED'], example: 'APPROVED' })
  @IsIn(['APPROVED', 'REJECTED'], { message: 'Kết quả duyệt không hợp lệ' })
  status!: 'APPROVED' | 'REJECTED';
}
