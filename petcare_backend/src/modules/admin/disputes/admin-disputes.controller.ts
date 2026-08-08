import { Body, Controller, Get, Param, Patch, Query } from '@nestjs/common';
import { ApiOperation, ApiTags } from '@nestjs/swagger';
import { CurrentUser } from '../../../common/decorators/current-user.decorator';
import { QuanTri } from '../chung/quan-tri.decorator';
import type { QuanTriVien } from '../chung/quan-tri.decorator';
import { AdminDisputeDetailService } from './admin-dispute-detail.service';
import { AdminDisputeResolveService } from './admin-dispute-resolve.service';
import { AdminDisputesReadService } from './admin-disputes-read.service';
import { KetLuanKhieuNaiDto, LocKhieuNaiDto } from './dto/loc-khieu-nai.dto';

@ApiTags('admin')
@QuanTri()
@Controller('admin')
export class AdminDisputesController {
  constructor(
    private readonly doc: AdminDisputesReadService,
    private readonly chiTietHoSo: AdminDisputeDetailService,
    private readonly ketLuanHoSo: AdminDisputeResolveService,
  ) {}

  @Get('disputes')
  @ApiOperation({ summary: 'Danh sách khiếu nại theo ba tình trạng' })
  danhSach(@Query() loc: LocKhieuNaiDto) {
    return this.doc.danhSach(loc);
  }

  // Khai TRƯỚC disputes/:code để counts không rơi vào lối chi tiết
  @Get('disputes/counts')
  @ApiOperation({ summary: 'Số đếm ba tab khiếu nại' })
  demTab() {
    return this.doc.demTab();
  }

  @Get('disputes/:code')
  @ApiOperation({ summary: 'Hồ sơ một khiếu nại để ra kết luận' })
  chiTiet(@Param('code') code: string) {
    return this.chiTietHoSo.chiTiet(code);
  }

  @Patch('disputes/:code/resolve')
  @ApiOperation({ summary: 'Ghi kết luận, kết luận không lùi được' })
  ketLuan(
    @CurrentUser() admin: QuanTriVien,
    @Param('code') code: string,
    @Body() dto: KetLuanKhieuNaiDto,
  ) {
    return this.ketLuanHoSo.ketLuan(code, dto, admin.id);
  }
}
