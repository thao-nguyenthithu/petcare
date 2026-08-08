import { Controller, Get } from '@nestjs/common';
import { ApiOperation, ApiTags } from '@nestjs/swagger';
import { QuanTri } from '../chung/quan-tri.decorator';
import { AdminDashboardService } from './admin-dashboard.service';
import { AdminQueueService } from './admin-queue.service';

@ApiTags('admin')
@QuanTri()
@Controller('admin')
export class AdminDashboardController {
  constructor(
    private readonly tongQuan: AdminDashboardService,
    private readonly hangCho: AdminQueueService,
  ) {}

  @Get('dashboard')
  @ApiOperation({
    summary: 'Bốn chỉ số, hai biểu đồ và năm đơn gần đây của màn tổng quan',
  })
  soLieu() {
    return this.tongQuan.tongQuan();
  }

  @Get('queue')
  @ApiOperation({ summary: 'Bốn dòng việc chỉ quản trị viên xử lý được' })
  hangChoViec() {
    return this.hangCho.danhSach();
  }
}
