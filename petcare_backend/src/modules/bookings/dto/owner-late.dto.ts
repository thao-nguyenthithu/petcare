import { ApiProperty } from '@nestjs/swagger';
import { Type } from 'class-transformer';
import { IsInt, Max, Min } from 'class-validator';

export class OwnerLateDto {
  @ApiProperty({ description: 'Số phút tới muộn so với giờ hẹn' })
  @Type(() => Number)
  @IsInt()
  @Min(1)
  @Max(120)
  minutes!: number;
}
