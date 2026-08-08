import { Body, Controller, Get, Param, Patch, Query } from '@nestjs/common';
import { ApiOperation, ApiTags } from '@nestjs/swagger';
import { CurrentUser } from '../../../common/decorators/current-user.decorator';
import { QuanTri } from '../chung/quan-tri.decorator';
import type { QuanTriVien } from '../chung/quan-tri.decorator';
import { AdminGpsReportsService } from './admin-gps-reports.service';
import { LocGpsDto, SoatGpsDto } from './dto/loc-gps.dto';

// Hàng chờ soát lộ trình đáng ngờ của màn 09b
@ApiTags('admin')
@QuanTri()
@Controller('admin/gps-reports')
export class AdminGpsReportsController {
  constructor(private readonly service: AdminGpsReportsService) {}

  @Get()
  @ApiOperation({ summary: 'Danh sách phiên dắt có số liệu lộ trình đáng ngờ' })
  danhSach(@Query() loc: LocGpsDto) {
    return this.service.danhSach(loc);
  }

  // Khai TRƯỚC :code để counts không rơi vào lối chi tiết
  @Get('counts')
  @ApiOperation({ summary: 'Số đếm bốn tab của hàng chờ' })
  demTab() {
    return this.service.demTab();
  }

  @Patch(':code/review')
  @ApiOperation({ summary: 'Gỡ cờ hoặc giữ cờ sau khi soát, không đụng tiền' })
  soat(
    @CurrentUser() admin: QuanTriVien,
    @Param('code') code: string,
    @Body() dto: SoatGpsDto,
  ) {
    return this.service.soat(code, dto.cleared, dto.note, admin.id);
  }
}
