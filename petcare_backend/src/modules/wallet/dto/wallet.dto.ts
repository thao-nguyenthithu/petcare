import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import {
  IsIn,
  IsInt,
  IsOptional,
  IsPositive,
  IsString,
  Length,
  Matches,
  MaxLength,
} from 'class-validator';

export class WithdrawDto {
  @ApiProperty({ description: 'Số tiền rút, đồng' })
  @IsInt()
  @IsPositive()
  amount!: number;
}

export class BankAccountDto {
  @ApiProperty({ example: 'Vietcombank' })
  @IsString()
  @Length(2, 60)
  bankName!: string;

  @ApiProperty({ example: '0123456789' })
  @IsString()
  @Matches(/^\d{6,19}$/, { message: 'Số tài khoản chỉ gồm 6-19 chữ số' })
  accountNumber!: string;

  @ApiProperty({ example: 'NGUYEN THI THU THAO' })
  @IsString()
  @Length(2, 80)
  accountHolder!: string;
}

export const SO_ANH_MO_KHIEU_NAI = 6;
export const SO_ANH_PHAN_HOI_KHIEU_NAI = 3;

export class OpenDisputeDto {
  @ApiProperty({ description: 'Nội dung phản ánh' })
  @IsString()
  @Length(10, 2000)
  description!: string;
}

export class DisputeReplyDto {
  @ApiProperty({ description: 'Phản hồi của người chăm' })
  @IsString()
  @Length(10, 2000)
  content!: string;
}

export class ListTransactionsDto {
  @ApiPropertyOptional({ enum: ['TIEN_VAO', 'RUT_RA', 'DIEU_CHINH'] })
  @IsOptional()
  @IsIn(['TIEN_VAO', 'RUT_RA', 'DIEU_CHINH'])
  loai?: 'TIEN_VAO' | 'RUT_RA' | 'DIEU_CHINH';

  @ApiPropertyOptional({ description: 'Con trỏ thời gian, ISO' })
  @IsOptional()
  @IsString()
  @MaxLength(40)
  truoc?: string;
}
