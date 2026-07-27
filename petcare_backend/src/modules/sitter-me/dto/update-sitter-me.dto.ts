import {
  IsNotEmpty,
  IsOptional,
  IsString,
  Matches,
  MaxLength,
} from 'class-validator';

// Cập nhật trang cá nhân NCC
export class UpdateSitterMeDto {
  @IsString({ message: 'Họ và tên không hợp lệ' })
  @IsNotEmpty({ message: 'Vui lòng nhập họ và tên' })
  @MaxLength(100, { message: 'Họ và tên quá dài' })
  fullName!: string;

  @IsOptional()
  @IsString({ message: 'Giới thiệu không hợp lệ' })
  @MaxLength(500, { message: 'Giới thiệu quá dài' })
  bio?: string;

  @IsOptional()
  @Matches(/^(\d{9,11})?$/, { message: 'Số điện thoại không hợp lệ' })
  phone?: string;
}
