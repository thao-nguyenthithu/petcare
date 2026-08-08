import { Body, Controller, Get, Param, Post, Query } from '@nestjs/common';
import { ApiOperation, ApiTags } from '@nestjs/swagger';
import { CurrentUser } from '../../../common/decorators/current-user.decorator';
import { QuanTri } from '../chung/quan-tri.decorator';
import type { QuanTriVien } from '../chung/quan-tri.decorator';
import { AdminRefundsReadService } from './admin-refunds-read.service';
import { AdminRefundsWriteService } from './admin-refunds-write.service';
import { DanhDauHoanDto, LocHoanTienDto } from './dto/loc-hoan-tien.dto';

@ApiTags('admin')
@QuanTri()
@Controller('admin')
export class AdminRefundsController {
  constructor(
    private readonly doc: AdminRefundsReadService,
    private readonly ghi: AdminRefundsWriteService,
  ) {}

  @Get('refunds')
  @ApiOperation({ summary: 'Danh sách khoản hoàn theo hai tab' })
  danhSach(@Query() loc: LocHoanTienDto) {
    return this.doc.danhSach(loc);
  }

  // Khai TRƯỚC refunds/:txnRef để counts không rơi vào lối chi tiết
  @Get('refunds/counts')
  @ApiOperation({ summary: 'Số đếm hai tab khoản hoàn' })
  demTab() {
    return this.doc.demTab();
  }

  @Post('refunds/:txnRef/mark-manual')
  @ApiOperation({
    summary: 'Đánh dấu đã hoàn tay ở cổng, thao tác không lùi được',
  })
  danhDau(
    @CurrentUser() admin: QuanTriVien,
    @Param('txnRef') txnRef: string,
    @Body() dto: DanhDauHoanDto,
  ) {
    return this.ghi.danhDauHoanTay(txnRef, dto, admin.id);
  }
}
