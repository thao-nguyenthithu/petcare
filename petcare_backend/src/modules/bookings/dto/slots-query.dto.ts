import { Transform } from 'class-transformer';
import { ArrayMaxSize, IsOptional, IsUUID, Matches } from 'class-validator';
import { MAU_NGAY } from '../../../common/thoi-gian-vn';

const TRAN_BE_HOI = 10;

export class SlotsQueryDto {
  @Matches(MAU_NGAY, { message: 'from phải dạng YYYY-MM-DD' })
  from!: string;

  @Matches(MAU_NGAY, { message: 'to phải dạng YYYY-MM-DD' })
  to!: string;

  @IsOptional()
  @Transform(({ value }) =>
    typeof value === 'string'
      ? value
          .split(',')
          .map((e) => e.trim())
          .filter((e) => e.length > 0)
      : [],
  )
  @ArrayMaxSize(TRAN_BE_HOI)
  @IsUUID(undefined, { each: true })
  petIds?: string[];
}
