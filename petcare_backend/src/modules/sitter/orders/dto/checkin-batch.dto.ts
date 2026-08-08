import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { Type } from 'class-transformer';
import { IsLatitude, IsLongitude, IsOptional, IsString } from 'class-validator';

export class ToaDoDto {
  @ApiPropertyOptional({ example: 10.762622 })
  @IsOptional()
  @Type(() => Number)
  @IsLatitude()
  lat?: number;

  @ApiPropertyOptional({ example: 106.660172 })
  @IsOptional()
  @Type(() => Number)
  @IsLongitude()
  lng?: number;
}

export class CheckinBatchDto extends ToaDoDto {
  @ApiProperty({
    description: 'Chỗ chụp của từng ảnh theo đúng thứ tự tệp, 0 là tấm cả đàn',
    example: '0,1,2,3',
  })
  @IsString()
  slotIndexes!: string;
}
