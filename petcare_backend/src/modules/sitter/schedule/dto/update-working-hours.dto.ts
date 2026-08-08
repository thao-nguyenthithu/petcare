import {
  ArrayMaxSize,
  ArrayUnique,
  IsInt,
  Matches,
  Max,
  Min,
} from 'class-validator';

import { MAU_GIO } from '../../../../common/thoi-gian-vn';

export { MAU_GIO };

// Giờ làm việc mặc định của NCC
export class UpdateWorkingHoursDto {
  @Matches(MAU_GIO, { message: 'workStart phải dạng HH:mm' })
  workStart!: string;

  @Matches(MAU_GIO, { message: 'workEnd phải dạng HH:mm' })
  workEnd!: string;

  @ArrayMaxSize(7)
  @ArrayUnique()
  @IsInt({ each: true })
  @Min(1, { each: true })
  @Max(7, { each: true })
  workDays!: number[];
}
