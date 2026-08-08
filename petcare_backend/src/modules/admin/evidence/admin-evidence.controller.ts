import { Controller, Get, Param, Query } from '@nestjs/common';
import { ApiOperation, ApiTags } from '@nestjs/swagger';
import { QuanTri } from '../chung/quan-tri.decorator';
import { AdminBookingEvidenceService } from './admin-booking-evidence.service';
import { AdminEvidenceReadService } from './admin-evidence-read.service';
import { LocAnhDto } from './dto/loc-anh.dto';

// Chỉ có lối ĐỌC: quản trị viên không duyệt, không gắn cờ, không xoá ảnh bằng chứng
@ApiTags('admin')
@QuanTri()
@Controller('admin')
export class AdminEvidenceController {
  constructor(
    private readonly doc: AdminEvidenceReadService,
    private readonly album: AdminBookingEvidenceService,
  ) {}

  @Get('evidence')
  @ApiOperation({ summary: 'Thư viện ảnh bằng chứng, mỗi lượt đọc một nguồn' })
  danhSach(@Query() loc: LocAnhDto) {
    return this.doc.danhSach(loc);
  }

  // Khai TRƯỚC mọi lối có tham số để counts không rơi vào nhánh chi tiết
  @Get('evidence/counts')
  @ApiOperation({ summary: 'Số đếm bốn tab của thư viện ảnh' })
  demNguon() {
    return this.doc.demNguon();
  }

  @Get('bookings/:code/evidence')
  @ApiOperation({
    summary: 'Album ảnh của một đơn, gom theo ngày hoặc theo pha',
  })
  albumCuaDon(@Param('code') code: string) {
    return this.album.album(code);
  }
}
