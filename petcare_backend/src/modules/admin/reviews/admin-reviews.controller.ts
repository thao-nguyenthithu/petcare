import { Controller, Get, Query } from '@nestjs/common';
import { ApiOperation, ApiTags } from '@nestjs/swagger';
import { QuanTri } from '../chung/quan-tri.decorator';
import { AdminReviewsReadService } from './admin-reviews-read.service';
import { LocDanhGiaDto } from './dto/loc-danh-gia.dto';

// Màn chỉ đọc: Review không có cột nào để ẩn nên cụm này không có lối ghi
@ApiTags('admin')
@QuanTri()
@Controller('admin')
export class AdminReviewsController {
  constructor(private readonly doc: AdminReviewsReadService) {}

  @Get('reviews')
  @ApiOperation({ summary: 'Danh sách đánh giá toàn nền tảng' })
  danhSach(@Query() loc: LocDanhGiaDto) {
    return this.doc.danhSach(loc);
  }

  @Get('reviews/counts')
  @ApiOperation({ summary: 'Số đếm bốn tab đánh giá' })
  demTab() {
    return this.doc.demTab();
  }
}
