import { Type } from 'class-transformer';
import {
  ArrayMaxSize,
  ArrayMinSize,
  IsBoolean,
  IsISO8601,
  IsNumber,
  IsOptional,
  IsUUID,
  Max,
  Min,
  ValidateNested,
} from 'class-validator';
import { TRAN_WAYPOINT_MOI_BATCH } from '../gps.constants';

export class GpsWaypointDto {
  @IsNumber()
  @Min(-90)
  @Max(90)
  lat!: number;

  @IsNumber()
  @Min(-180)
  @Max(180)
  lng!: number;

  @IsISO8601()
  clientTs!: string;

  @IsOptional()
  @IsBoolean()
  isMocked?: boolean;
}

export class GpsBatchDto {
  @IsUUID()
  bookingId!: string;

  @ArrayMinSize(1)
  @ArrayMaxSize(TRAN_WAYPOINT_MOI_BATCH, {
    message: `Mỗi batch tối đa ${TRAN_WAYPOINT_MOI_BATCH} điểm`,
  })
  @ValidateNested({ each: true })
  @Type(() => GpsWaypointDto)
  waypoints!: GpsWaypointDto[];
}
