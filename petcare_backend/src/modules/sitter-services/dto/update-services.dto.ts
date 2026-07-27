import { Type } from 'class-transformer';
import {
  IsBoolean,
  IsIn,
  IsInt,
  IsObject,
  IsOptional,
  Min,
  ValidateNested,
} from 'class-validator';

const PET_KINDS = ['dog', 'cat', 'both'];

// Cấu hình dắt chó
class WalkingConfigDto {
  @IsBoolean()
  enabled!: boolean;

  @IsIn(PET_KINDS)
  petKind!: string;

  @IsInt()
  durationMinutes!: number;

  @IsOptional()
  @IsInt()
  @Min(0)
  price?: number;

  // Phụ phí mỗi bé thêm
  @IsOptional()
  @IsInt()
  @Min(0)
  additionalPetFee?: number;

  // Số bé tối đa nhận trong một đơn
  @IsOptional()
  @IsInt()
  @Min(1)
  maxPets?: number;
}

// Cấu hình trông giữ
class BoardingConfigDto {
  @IsBoolean()
  enabled!: boolean;

  @IsIn(PET_KINDS)
  petKind!: string;

  @IsOptional()
  @IsInt()
  @Min(0)
  pricePerDay?: number;

  @IsOptional()
  @IsInt()
  @Min(0)
  capacity?: number;

  // Phụ phí mỗi bé thêm
  @IsOptional()
  @IsInt()
  @Min(0)
  additionalPetFee?: number;

  // Số bé tối đa nhận trong một đơn
  @IsOptional()
  @IsInt()
  @Min(1)
  maxPets?: number;
}

// Cấu hình grooming
class GroomingConfigDto {
  @IsBoolean()
  enabled!: boolean;

  @IsIn(PET_KINDS)
  petKind!: string;

  @IsOptional()
  @IsObject()
  priceByPackage?: Record<string, Record<string, number>>;

  // Grooming tính theo từng bé
  @IsOptional()
  @IsInt()
  @Min(1)
  maxPets?: number;
}

export class UpdateServicesDto {
  @IsOptional()
  @ValidateNested()
  @Type(() => WalkingConfigDto)
  walking?: WalkingConfigDto;

  @IsOptional()
  @ValidateNested()
  @Type(() => BoardingConfigDto)
  boarding?: BoardingConfigDto;

  @IsOptional()
  @ValidateNested()
  @Type(() => GroomingConfigDto)
  grooming?: GroomingConfigDto;
}
