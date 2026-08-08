import { Controller, Get } from '@nestjs/common';
import { ApiOperation, ApiTags } from '@nestjs/swagger';
import { QuanTri } from '../chung/quan-tri.decorator';
import { GioiHanService } from './gioi-han.service';

// Bản kê CHỈ ĐỌC của màn 15b, không có lối ghi nào nên cũng không ghi nhật ký
@ApiTags('admin')
@QuanTri()
@Controller('admin/limits')
export class GioiHanController {
  constructor(private readonly service: GioiHanService) {}

  @Get()
  @ApiOperation({
    summary:
      'Giới hạn và hạn mức đang chạy, đọc thẳng từ hằng số của từng module',
  })
  danhSach() {
    return this.service.danhSach();
  }
}
