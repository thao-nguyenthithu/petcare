import {
  IsInt,
  IsNumber,
  IsOptional,
  IsString,
  Max,
  Min,
} from 'class-validator';
import { TRAN_CUNG_BAN_KINH_KM } from '../../../admin/tham-so.dinh-nghia';

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
  @Max(TRAN_CUNG_BAN_KINH_KM)
  radiusKm!: number;
}
