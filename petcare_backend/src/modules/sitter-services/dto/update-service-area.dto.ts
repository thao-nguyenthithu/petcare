import {
  IsInt,
  IsNumber,
  IsOptional,
  IsString,
  Max,
  Min,
} from 'class-validator';

// Khu vực phục vụ của NCC một địa chỉ gốc, bán kính
export class UpdateServiceAreaDto {
  @IsOptional()
  @IsString()
  address?: string;

  @IsNumber()
  lat!: number;

  @IsNumber()
  lng!: number;

  @IsOptional()
  @IsString()
  addressNote?: string;

  @IsInt()
  @Min(1)
  @Max(20)
  radiusKm!: number;
}
