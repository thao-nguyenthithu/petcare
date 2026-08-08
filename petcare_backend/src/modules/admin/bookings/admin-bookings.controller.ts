import { Body, Controller, Get, Param, Post, Query, Res } from '@nestjs/common';
import { ApiOperation, ApiTags } from '@nestjs/swagger';
import type { Response } from 'express';
import { CurrentUser } from '../../../common/decorators/current-user.decorator';
import { QuanTri } from '../chung/quan-tri.decorator';
import type { QuanTriVien } from '../chung/quan-tri.decorator';
import { AdminBookingCancelService } from './admin-booking-cancel.service';
import { AdminBookingConversationService } from './admin-booking-conversation.service';
import { AdminBookingDetailService } from './admin-booking-detail.service';
import { AdminBookingsReadService } from './admin-bookings-read.service';
import { AdminTrackCsvService } from './admin-track-csv.service';
import { CanThiepHuyDonDto, LocDonDto } from './dto/loc-don.dto';

@ApiTags('admin')
@QuanTri()
@Controller('admin')
export class AdminBookingsController {
  constructor(
    private readonly doc: AdminBookingsReadService,
    private readonly chiTietDon: AdminBookingDetailService,
    private readonly csv: AdminTrackCsvService,
    private readonly huy: AdminBookingCancelService,
    private readonly hoiThoaiDon: AdminBookingConversationService,
  ) {}

  @Get('bookings')
  @ApiOperation({ summary: 'Danh sách đơn theo chín tab' })
  danhSach(@Query() loc: LocDonDto) {
    return this.doc.danhSach(loc);
  }

  // Khai TRƯỚC bookings/:code để counts không rơi vào lối chi tiết
  @Get('bookings/counts')
  @ApiOperation({ summary: 'Số đếm các tab đơn' })
  demTab() {
    return this.doc.demTab();
  }

  // Khai TRƯỚC bookings/:code, không thì đuôi .csv bị nuốt thành một mã đơn
  @Get('bookings/:code/track.csv')
  @ApiOperation({ summary: 'Tải log lộ trình dạng CSV' })
  async taiTrack(
    @Param('code') code: string,
    @Res({ passthrough: true }) res: Response,
  ) {
    const { ten, noiDung } = await this.csv.csvLoTrinh(code);
    res.setHeader('Content-Type', 'text/csv; charset=utf-8');
    res.setHeader('Content-Disposition', `attachment; filename="${ten}"`);
    return noiDung;
  }

  @Get('bookings/:code/conversation')
  @ApiOperation({ summary: 'Nhật ký hội thoại của đơn, quản trị viên chỉ đọc' })
  hoiThoai(@Param('code') code: string) {
    return this.hoiThoaiDon.hoiThoai(code);
  }

  @Get('bookings/:code')
  @ApiOperation({ summary: 'Chi tiết một đơn để tra soát' })
  chiTiet(@Param('code') code: string) {
    return this.chiTietDon.chiTiet(code);
  }

  @Post('bookings/:code/cancel')
  @ApiOperation({ summary: 'Can thiệp huỷ đơn, hoàn đủ tiền cho chủ nuôi' })
  canThiepHuy(
    @CurrentUser() admin: QuanTriVien,
    @Param('code') code: string,
    @Body() dto: CanThiepHuyDonDto,
  ) {
    return this.huy.canThiepHuy(code, dto.reason, admin.id);
  }
}
