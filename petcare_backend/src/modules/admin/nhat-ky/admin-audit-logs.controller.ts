import { Controller, Get, Query } from '@nestjs/common';
import { ApiOperation, ApiTags } from '@nestjs/swagger';
import { QuanTri } from '../chung/quan-tri.decorator';
import { AdminAuditLogsService } from './admin-audit-logs.service';
import { LocNhatKyDto } from './dto/loc-nhat-ky.dto';

@ApiTags('admin')
@QuanTri()
@Controller('admin')
export class AdminAuditLogsController {
  constructor(private readonly doc: AdminAuditLogsService) {}

  @Get('audit-logs')
  @ApiOperation({ summary: 'Nhật ký thao tác quản trị' })
  danhSach(@Query() loc: LocNhatKyDto) {
    return this.doc.danhSach(loc);
  }

  @Get('audit-logs/filters')
  @ApiOperation({ summary: 'Tập mã đã xuất hiện, dựng hai ô lọc' })
  boLoc() {
    return this.doc.boLoc();
  }
}
