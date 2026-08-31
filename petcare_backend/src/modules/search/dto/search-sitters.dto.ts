import { Transform, Type } from 'class-transformer';
import {
  IsDateString,
  IsIn,
  IsInt,
  IsNumber,
  IsOptional,
  IsString,
  Max,
  MaxLength,
  Min,
} from 'class-validator';
import { TRAN_CUNG_BAN_KINH_KM } from '../../admin/tham-so.dinh-nghia';

export const SERVICE_TYPES = ['walking', 'boarding', 'grooming'] as const;
// Gói của dịch vụ tắm cắt tỉa; NCC có thể chỉ nhận tắm mà không cắt tỉa
export const GROOMING_PACKAGES = ['bath', 'bathAndTrim'] as const;
export const SORT_KEYS = [
  'recommended',
  'nearest',
  'rating',
  'completed',
  'price',
  'cancelRate',
  // Khối trang chủ, kèm cửa vào riêng chứ không chỉ đổi thứ tự (bộ luật mục 9)
  'topRated',
] as const;

const toBool = ({ value }: { value: unknown }) =>
  value === true || value === 'true' || value === '1';

export class SearchSittersDto {
  @IsOptional()
  @IsString()
  @MaxLength(100)
  @Transform(({ value }) => (value as string)?.trim())
  q?: string;

  @IsOptional()
  @IsIn(SERVICE_TYPES)
  service?: (typeof SERVICE_TYPES)[number];

  @IsOptional()
  @IsIn(GROOMING_PACKAGES)
  package?: (typeof GROOMING_PACKAGES)[number];

  @IsOptional()
  @Type(() => Number)
  @IsNumber()
  @Min(-90)
  @Max(90)
  lat?: number;

  @IsOptional()
  @Type(() => Number)
  @IsNumber()
  @Min(-180)
  @Max(180)
  lng?: number;

  @IsOptional()
  @Type(() => Number)
  @IsNumber()
  @Min(1)
  @Max(TRAN_CUNG_BAN_KINH_KM)
  radiusKm?: number;

  @IsOptional()
  @IsIn(['dog', 'cat'])
  species?: 'dog' | 'cat';

  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(1)
  @Max(20)
  petCount?: number;

  @IsOptional()
  @IsDateString()
  dateFrom?: string;

  @IsOptional()
  @IsDateString()
  dateTo?: string;

  @IsOptional()
  @Type(() => Number)
  @IsNumber()
  @Min(0)
  @Max(5)
  minRating?: number;

  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(0)
  priceMin?: number;

  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(0)
  priceMax?: number;

  @IsOptional()
  @Transform(toBool)
  trusted?: boolean;

  @IsOptional()
  @IsIn(SORT_KEYS)
  sort?: (typeof SORT_KEYS)[number];

  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(1)
  @Max(50)
  page?: number;

  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(1)
  @Max(50)
  limit?: number;
}
