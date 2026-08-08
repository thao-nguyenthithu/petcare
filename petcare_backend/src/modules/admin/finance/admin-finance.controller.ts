import { Body, Controller, Get, Param, Patch, Query } from '@nestjs/common';
import { ApiOperation, ApiTags } from '@nestjs/swagger';
import { CurrentUser } from '../../../common/decorators/current-user.decorator';
import { QuanTri } from '../chung/quan-tri.decorator';
import type { QuanTriVien } from '../chung/quan-tri.decorator';
import { AdminFinanceSummaryService } from './admin-finance-summary.service';
import { AdminWithdrawalsService } from './admin-withdrawals.service';
import { KyDoanhThuDto } from './dto/ky-doanh-thu.dto';
import { DoiLenhRutDto, LocLenhRutDto } from './dto/loc-lenh-rut.dto';

@ApiTags('admin')
@QuanTri()
@Controller('admin')
export class AdminFinanceController {
  constructor(
    private readonly tongQuan: AdminFinanceSummaryService,
    private readonly lenhRut: AdminWithdrawalsService,
  ) {}

  @Get('finance/summary')
  @ApiOperation({
    summary: 'Bốn chỉ số doanh thu, biểu đồ tuần và top người chăm',
  })
  soLieu(@Query() loc: KyDoanhThuDto) {
    return this.tongQuan.tongQuan(loc);
  }

  @Get('withdrawals')
  @ApiOperation({ summary: 'Danh sách lệnh rút của người chăm' })
  danhSachLenhRut(@Query() loc: LocLenhRutDto) {
    return this.lenhRut.danhSach(loc);
  }

  @Patch('withdrawals/:id')
  @ApiOperation({
    summary: 'Chuyển lệnh rút sang đã chuyển, xong hoặc từ chối',
  })
  doiLenhRut(
    @CurrentUser() admin: QuanTriVien,
    @Param('id') id: string,
    @Body() dto: DoiLenhRutDto,
  ) {
    return this.lenhRut.doiTrangThai(id, dto, admin.id);
  }
}
