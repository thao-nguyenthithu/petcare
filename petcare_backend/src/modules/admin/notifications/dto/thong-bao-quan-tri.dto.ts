import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { Transform } from 'class-transformer';
import {
  IsBoolean,
  IsIn,
  IsISO8601,
  IsOptional,
  IsString,
  Length,
  MaxLength,
} from 'class-validator';
import { PhanTrangDto } from '../../chung/dto/phan-trang.dto';
import { NHOM_NGUOI_NHAN } from '../nguoi-nhan';
import type { NhomNguoiNhan } from '../nguoi-nhan';

export const TIEU_DE_TOI_THIEU = 6;
export const TIEU_DE_TOI_DA = 120;
export const NOI_DUNG_TOI_THIEU = 10;
export const NOI_DUNG_TOI_DA = 500;

// Câu chữ quản trị nhập được lưu cứng rồi hiện lại ở nhiều nơi, gỡ thẻ trước khi lưu
export function boTheHtml(gia: unknown): string | undefined {
  if (typeof gia !== 'string') return undefined;
  return gia.replace(/<[^>]*>/g, '').trim();
}

export class GuiThongBaoDto {
  @ApiProperty({ example: 'Bảo trì hệ thống 02:00 tới 03:00 ngày 08/08' })
  @Transform(({ value }) => boTheHtml(value))
  @IsString()
  @Length(TIEU_DE_TOI_THIEU, TIEU_DE_TOI_DA)
  title!: string;

  @ApiProperty()
  @Transform(({ value }) => boTheHtml(value))
  @IsString()
  @Length(NOI_DUNG_TOI_THIEU, NOI_DUNG_TOI_DA)
  body!: string;

  @ApiProperty({ enum: NHOM_NGUOI_NHAN })
  @IsIn(NHOM_NGUOI_NHAN)
  audienceKind!: NhomNguoiNhan;

  @ApiPropertyOptional({ description: 'Tên tỉnh hoặc userId, tuỳ nhóm nhận' })
  @IsOptional()
  @Transform(({ value }) => boTheHtml(value))
  @IsString()
  @MaxLength(100)
  audienceValue?: string;

  @ApiPropertyOptional({ default: false })
  @IsOptional()
  @IsBoolean()
  urgent?: boolean;

  @ApiPropertyOptional({ description: 'Bỏ trống là gửi ngay' })
  @IsOptional()
  @IsISO8601()
  scheduledAt?: string;
}

export class LocLuotGuiDto extends PhanTrangDto {}

export class DemNguoiNhanDto {
  @ApiProperty({ enum: NHOM_NGUOI_NHAN })
  @IsIn(NHOM_NGUOI_NHAN)
  kind!: NhomNguoiNhan;

  @ApiPropertyOptional()
  @IsOptional()
  @Transform(({ value }) => boTheHtml(value))
  @IsString()
  @MaxLength(100)
  value?: string;
}
