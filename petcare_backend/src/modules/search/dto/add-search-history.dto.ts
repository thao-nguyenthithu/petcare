import { Transform } from 'class-transformer';
import { IsString, MaxLength, MinLength } from 'class-validator';

// Một từ khoá vừa tìm
export class AddSearchHistoryDto {
  @IsString()
  @MinLength(1)
  @MaxLength(100)
  @Transform(({ value }) => (value as string)?.trim())
  keyword!: string;
}
