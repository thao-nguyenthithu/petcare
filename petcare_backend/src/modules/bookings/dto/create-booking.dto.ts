import { Type } from 'class-transformer';
import {
  ArrayMaxSize,
  ArrayMinSize,
  ArrayUnique,
  IsBoolean,
  IsIn,
  IsInt,
  IsOptional,
  IsString,
  IsUUID,
  Matches,
  MaxLength,
  ValidateNested,
} from 'class-validator';
import { MAU_GIO, MAU_NGAY } from '../../../common/thoi-gian-vn';

export const LOAI_DICH_VU = ['walking', 'boarding', 'grooming'] as const;
export type LoaiDichVuDto = (typeof LOAI_DICH_VU)[number];

export const GOI_GROOMING = ['bath', 'bathAndTrim'] as const;
export type GoiGroomingDto = (typeof GOI_GROOMING)[number];

export const WALKING_DURATIONS = [30, 60];
const TRAN_BE_MOI_DON = 10;

export class GoiCuaBeDto {
  @IsUUID()
  petId!: string;

  @IsIn(GOI_GROOMING)
  packageCode!: GoiGroomingDto;
}

export class CreateBookingDto {
  @IsUUID()
  sitterId!: string;

  @IsIn(LOAI_DICH_VU)
  serviceType!: LoaiDichVuDto;

  @ArrayMinSize(1)
  @ArrayMaxSize(TRAN_BE_MOI_DON)
  @ArrayUnique()
  @IsUUID(undefined, { each: true })
  petIds!: string[];

  @IsUUID()
  addressId!: string;

  @Matches(MAU_NGAY, { message: 'startDate phải dạng YYYY-MM-DD' })
  startDate!: string;

  @Matches(MAU_GIO, { message: 'startTime phải dạng HH:mm' })
  startTime!: string;

  @IsOptional()
  @Matches(MAU_NGAY, { message: 'endDate phải dạng YYYY-MM-DD' })
  endDate?: string;

  @IsOptional()
  @Matches(MAU_GIO, { message: 'endTime phải dạng HH:mm' })
  endTime?: string;

  @IsOptional()
  @IsInt()
  @IsIn(WALKING_DURATIONS)
  durationMinutes?: number;

  @IsOptional()
  @ArrayMaxSize(TRAN_BE_MOI_DON)
  @ValidateNested({ each: true })
  @Type(() => GoiCuaBeDto)
  packages?: GoiCuaBeDto[];

  @IsOptional()
  @IsString()
  @MaxLength(500)
  note?: string;

  @IsOptional()
  @IsBoolean()
  gearCommitted?: boolean;
}
