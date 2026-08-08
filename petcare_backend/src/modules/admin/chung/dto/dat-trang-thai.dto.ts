import { ApiProperty } from '@nestjs/swagger';
import { Transform } from 'class-transformer';
import { IsBoolean, IsString, MaxLength, MinLength } from 'class-validator';
import { catKhoangTrang } from './chuyen-doi';

// Lý do BẮT BUỘC vì bản ghi nhật ký không có lý do thì tra lại cũng vô dụng
export class DatTrangThaiDto {
  @ApiProperty({ description: 'true là mở lại, false là khoá' })
  @IsBoolean()
  isActive!: boolean;

  @ApiProperty({ description: 'Lý do, ghi vào nhật ký thao tác' })
  @Transform(({ value }) => catKhoangTrang(value))
  @IsString()
  @MinLength(3)
  @MaxLength(300)
  reason!: string;
}
