import { Controller, Get, Param, Query } from '@nestjs/common';
import { ApiOperation, ApiTags } from '@nestjs/swagger';
import { QuanTri } from '../chung/quan-tri.decorator';
import { AdminPaymentsReadService } from './admin-payments-read.service';
import { LocThanhToanDto } from './dto/loc-thanh-toan.dto';

// Không có lối đổi trạng thái Payment ở đây, muốn hoàn thì sang cụm refunds
@ApiTags('admin')
@QuanTri()
@Controller('admin')
export class AdminPaymentsController {
  constructor(private readonly doc: AdminPaymentsReadService) {}

  @Get('payments')
  @ApiOperation({ summary: 'Danh sách giao dịch thanh toán để đối soát' })
  danhSach(@Query() loc: LocThanhToanDto) {
    return this.doc.danhSach(loc);
  }

  // Khai TRƯỚC payments/:txnRef để counts không rơi vào lối chi tiết
  @Get('payments/counts')
  @ApiOperation({ summary: 'Số đếm bốn tab giao dịch' })
  demTab() {
    return this.doc.demTab();
  }

  @Get('payments/:txnRef/raw')
  @ApiOperation({ summary: 'Payload nguyên văn cổng gửi về của một giao dịch' })
  payloadTho(@Param('txnRef') txnRef: string) {
    return this.doc.payloadTho(txnRef);
  }
}
