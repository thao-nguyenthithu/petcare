import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import {
  IsBoolean,
  IsDateString,
  IsEnum,
  IsNotEmpty,
  IsNumber,
  IsOptional,
  IsString,
  Max,
  MaxLength,
  Min,
} from 'class-validator';
import { PetGender, PetSpecies } from 'generated/prisma/enums';

export const CAN_NANG_TOI_DA = 100;
export const TUOI_BE_TOI_DA = 30;

export class CreatePetDto {
  @ApiProperty({ example: 'Bông' })
  @IsString({ message: 'Tên bé không hợp lệ' })
  @IsNotEmpty({ message: 'Thiếu tên bé' })
  @MaxLength(50, { message: 'Tên bé quá dài' })
  name!: string;

  @ApiProperty({ enum: PetSpecies, example: PetSpecies.DOG })
  @IsEnum(PetSpecies, { message: 'Loài không hợp lệ' })
  species!: PetSpecies;

  @ApiProperty({
    example: 'poodle',
    description: 'Mã giống trong danh mục app',
  })
  @IsString({ message: 'Giống không hợp lệ' })
  @IsNotEmpty({ message: 'Thiếu giống của bé' })
  @MaxLength(50, { message: 'Mã giống quá dài' })
  breed!: string;

  @ApiProperty({ enum: PetGender, example: PetGender.MALE })
  @IsEnum(PetGender, { message: 'Giới tính không hợp lệ' })
  gender!: PetGender;

  @ApiPropertyOptional({ example: '2024-03-12T00:00:00.000Z' })
  @IsOptional()
  @IsDateString({}, { message: 'Ngày sinh không hợp lệ' })
  birthDate?: string;

  @ApiProperty({ example: 5.2 })
  @IsNumber({}, { message: 'Cân nặng không hợp lệ' })
  @Min(0.1, { message: 'Cân nặng phải lớn hơn 0' })
  @Max(CAN_NANG_TOI_DA, { message: 'Cân nặng quá lớn' })
  weightKg!: number;

  @ApiPropertyOptional({ example: false })
  @IsOptional()
  @IsBoolean({ message: 'Trạng thái triệt sản không hợp lệ' })
  isNeutered?: boolean;

  @ApiPropertyOptional({ example: false })
  @IsOptional()
  @IsBoolean({ message: 'Tình trạng sức khoẻ không hợp lệ' })
  underTreatment?: boolean;

  @ApiPropertyOptional({ example: 'Dị ứng thịt gà' })
  @IsOptional()
  @IsString({ message: 'Bệnh nền không hợp lệ' })
  @MaxLength(255, { message: 'Bệnh nền quá dài' })
  chronicDisease?: string;

  @ApiPropertyOptional({ example: 'Thuốc da liễu, uống sáng' })
  @IsOptional()
  @IsString({ message: 'Thuốc đang dùng không hợp lệ' })
  @MaxLength(255, { message: 'Thuốc đang dùng quá dài' })
  medication?: string;

  @ApiPropertyOptional({ example: 'Ăn 2 bữa sáng và tối, nhát người lạ' })
  @IsOptional()
  @IsString({ message: 'Lưu ý chăm sóc không hợp lệ' })
  @MaxLength(1000, { message: 'Lưu ý chăm sóc quá dài' })
  careNote?: string;
}
