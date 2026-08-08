import { ApiProperty } from '@nestjs/swagger';
import { IsNotEmpty, IsString, MaxLength } from 'class-validator';

export class ReplyReviewDto {
  @ApiProperty({ example: 'Cảm ơn anh chị đã tin tưởng ạ' })
  @IsString({ message: 'Nội dung phản hồi không hợp lệ' })
  @IsNotEmpty({ message: 'Vui lòng nhập nội dung phản hồi' })
  @MaxLength(500, { message: 'Phản hồi tối đa 500 ký tự' })
  content!: string;
}
