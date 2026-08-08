import { Body, Controller, Get, Param, Put } from '@nestjs/common';
import { ApiOperation, ApiTags } from '@nestjs/swagger';
import { CurrentUser } from '../../common/decorators/current-user.decorator';
import { QuanTri } from './chung/quan-tri.decorator';
import type { QuanTriVien } from './chung/quan-tri.decorator';
import { DatThamSoDto } from './dto/dat-tham-so.dto';
import { SystemSettingsService } from './system-settings.service';

// Tham số vận hành của trang quản trị
@ApiTags('admin')
@QuanTri()
@Controller('admin/settings')
export class AdminSettingsController {
  constructor(private readonly service: SystemSettingsService) {}

  @Get()
  @ApiOperation({
    summary: 'Danh sách tham số vận hành kèm khoảng cho phép và người đổi cuối',
  })
  danhSach() {
    return this.service.danhSachChoQuanTri();
  }

  @Put(':key')
  @ApiOperation({ summary: 'Đổi một tham số vận hành, chặn theo khoảng' })
  dat(
    @CurrentUser() user: QuanTriVien,
    @Param('key') key: string,
    @Body() dto: DatThamSoDto,
  ) {
    return this.service.dat(key, dto.giaTri, user.id, dto.lyDo);
  }
}
