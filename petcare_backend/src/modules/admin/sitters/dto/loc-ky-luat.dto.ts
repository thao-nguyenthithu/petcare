import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { Transform } from 'class-transformer';
import {
  IsBoolean,
  IsIn,
  IsOptional,
  IsString,
  MaxLength,
  MinLength,
} from 'class-validator';
import {
  PenaltyKind,
  PenaltyStatus,
} from '../../../../../generated/prisma/enums';
import { catKhoangTrang } from '../../chung/dto/chuyen-doi';
import { PhanTrangDto } from '../../chung/dto/phan-trang.dto';

export class LocKyLuatDto extends PhanTrangDto {
  @ApiPropertyOptional({ enum: PenaltyStatus })
  @IsOptional()
  @IsIn(Object.values(PenaltyStatus))
  status?: PenaltyStatus;

  @ApiPropertyOptional({ enum: PenaltyKind })
  @IsOptional()
  @IsIn(Object.values(PenaltyKind))
  kind?: PenaltyKind;

  @ApiPropertyOptional({ description: 'Tìm theo tên người chăm' })
  @IsOptional()
  @Transform(({ value }) => catKhoangTrang(value))
  @IsString()
  @MaxLength(100)
  q?: string;
}

export class SoatPhatDto {
  @ApiProperty({ description: 'true là miễn, false là giữ nguyên hình phạt' })
  @IsBoolean()
  waived!: boolean;

  @ApiProperty({ description: 'Kết luận, ghi vào nhật ký thao tác' })
  @Transform(({ value }) => catKhoangTrang(value))
  @IsString()
  @MinLength(3)
  @MaxLength(300)
  note!: string;
}
