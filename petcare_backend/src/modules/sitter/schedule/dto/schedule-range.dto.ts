import { Matches } from 'class-validator';
import { MAU_NGAY } from '../../../../common/thoi-gian-vn';

export { MAU_NGAY };

export class ScheduleRangeDto {
  @Matches(MAU_NGAY, { message: 'from phải dạng YYYY-MM-DD' })
  from!: string;

  @Matches(MAU_NGAY, { message: 'to phải dạng YYYY-MM-DD' })
  to!: string;
}
