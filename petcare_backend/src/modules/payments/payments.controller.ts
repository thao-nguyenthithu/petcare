import {
  Body,
  Controller,
  Delete,
  Get,
  Ip,
  NotFoundException,
  Param,
  ParseUUIDPipe,
  Post,
  Query,
  UseGuards,
} from '@nestjs/common';
import { ApiBearerAuth, ApiOperation, ApiTags } from '@nestjs/swagger';
import { CurrentUser } from '../../common/decorators/current-user.decorator';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { MockPayDto } from './dto/mock-pay.dto';
import { MockGateway } from './gateways/mock.gateway';
import type { KetQuaCong } from './gateways/payment-gateway.interface';
import { PaymentGatewayResolver } from './gateways/payment-gateway.resolver';
import { PaymentsService } from './payments.service';
import { VnpayGateway } from './gateways/vnpay.gateway';

@ApiTags('payments')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller('bookings')
export class BookingPaymentsController {
  constructor(private readonly service: PaymentsService) {}

  @Post(':id/payment')
  @ApiOperation({ summary: 'Mở phiên trả tiền cho đơn đang giữ chỗ' })
  taoPhien(
    @CurrentUser() user: { id: string },
    @Param('id', ParseUUIDPipe) id: string,
    @Ip() ip: string,
  ) {
    return this.service.taoPhien(user.id, id, ip);
  }

  @Get(':id/payment')
  @ApiOperation({ summary: 'Trạng thái trả tiền của đơn, cho app hỏi lại' })
  trangThai(
    @CurrentUser() user: { id: string },
    @Param('id', ParseUUIDPipe) id: string,
  ) {
    return this.service.trangThai(user.id, id);
  }

  @Delete(':id/payment')
  @ApiOperation({ summary: 'Chủ nuôi bỏ ngang, nhả chỗ đang giữ ngay' })
  boGiuCho(
    @CurrentUser() user: { id: string },
    @Param('id', ParseUUIDPipe) id: string,
  ) {
    return this.service.boGiuCho(user.id, id);
  }
}

@ApiTags('payments')
@Controller('payments')
export class PaymentsGatewayController {
  constructor(
    private readonly service: PaymentsService,
    private readonly chonCong: PaymentGatewayResolver,
    private readonly vnpay: VnpayGateway,
    private readonly congGiaLap: MockGateway,
  ) {}

  @Get('vnpay/ipn')
  @ApiOperation({ summary: 'VNPay báo kết quả giao dịch (server tới server)' })
  async ipn(@Query() query: Record<string, string>) {
    let ketQua: KetQuaCong;
    try {
      ketQua = this.vnpay.docKetQua(query);
    } catch {
      return { RspCode: '97', Message: 'Invalid signature' };
    }
    try {
      const ket = await this.service.xacNhanTra(ketQua);
      switch (ket.ma) {
        case 'KHONG_TIM_THAY':
          return { RspCode: '01', Message: 'Order not found' };
        case 'DA_XU_LY':
          return { RspCode: '02', Message: 'Order already confirmed' };
        case 'LECH_TIEN':
          return { RspCode: '04', Message: 'Invalid amount' };
        default:
          return { RspCode: '00', Message: 'Confirm Success' };
      }
    } catch {
      return { RspCode: '99', Message: 'Unknown error' };
    }
  }

  @Get('vnpay/return')
  @ApiOperation({ summary: 'Trang cổng đẩy trình duyệt về sau khi trả xong' })
  quayLai() {
    return {
      message: 'Đã nhận kết quả thanh toán, bạn quay lại ứng dụng để xem đơn',
    };
  }

  @Post('mock/:txnRef')
  @ApiOperation({ summary: 'Cổng giả lập báo kết quả (chỉ khi bật mock)' })
  async mock(@Param('txnRef') txnRef: string, @Body() dto: MockPayDto) {
    if (!(await this.chonCong.dangGiaLap())) {
      throw new NotFoundException({
        code: 'KHONG_BAT_CONG_GIA_LAP',
        message: 'Hệ thống đang chạy cổng thật',
      });
    }
    const ketQua = this.congGiaLap.docKetQua({
      txnRef,
      ketQua: dto.ketQua,
      soTien: String(dto.soTien),
    });
    const ket = await this.service.xacNhanTra(ketQua);
    return { ma: ket.ma };
  }
}
