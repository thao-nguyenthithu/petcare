import { Controller, Get, Headers, Res } from '@nestjs/common';
import { ApiOperation, ApiTags } from '@nestjs/swagger';
import type { Response } from 'express';
import { DanhMucDichVuService } from './danh-muc-dich-vu.service';
import { SystemSettingsService } from './system-settings.service';

// Không đặt sau JwtAuthGuard, màn đăng ký cần số này trước khi có tài khoản
@ApiTags('config')
@Controller('config')
export class CauHinhCongKhaiController {
  constructor(
    private readonly service: SystemSettingsService,
    private readonly danhMuc: DanhMucDichVuService,
  ) {}

  @Get('dich-vu')
  @ApiOperation({ summary: 'Tên và mô tả ba dịch vụ, quản trị sửa ở màn 07' })
  dichVu() {
    return this.danhMuc.congKhai();
  }

  @Get('nghiep-vu')
  @ApiOperation({
    summary:
      'Tham số nghiệp vụ công khai, có ETag để khách biết khi nào nạp lại',
  })
  nghiepVu(
    @Headers('if-none-match') etagCu: string | undefined,
    @Res({ passthrough: true }) res: Response,
  ) {
    const moc = this.service.capNhatLuc();
    const etag = `W/"${moc ? moc.getTime() : 0}"`;
    res.setHeader('ETag', etag);
    // Bắt khách hỏi lại mỗi lần chứ không giữ bản cũ im lặng
    res.setHeader('Cache-Control', 'no-cache');
    if (etagCu === etag) {
      res.status(304);
      return;
    }
    return { capNhatLuc: moc, thamSo: this.service.congKhai() };
  }
}
