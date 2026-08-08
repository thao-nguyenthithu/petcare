import { Controller, Get, Param, Query, UseGuards } from '@nestjs/common';
import { ApiBearerAuth, ApiOperation, ApiTags } from '@nestjs/swagger';
import { CurrentUser } from '../../common/decorators/current-user.decorator';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { OwnerPaymentsService } from './owner-payments.service';

@ApiTags('payments')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller('payments')
export class OwnerPaymentsController {
  constructor(private readonly service: OwnerPaymentsService) {}

  @Get('holding')
  @ApiOperation({ summary: 'Tiền đang tạm giữ ở nền tảng, theo từng đơn' })
  dangTamGiu(@CurrentUser() user: { id: string }) {
    return this.service.dangTamGiu(user.id);
  }

  @Get('transactions')
  @ApiOperation({ summary: 'Lịch sử thanh toán và hoàn tiền' })
  lichSu(
    @CurrentUser() user: { id: string },
    @Query('loai') loai?: 'thanhToan' | 'hoanTien',
  ) {
    return this.service.lichSu(user.id, loai);
  }

  @Get('spending')
  @ApiOperation({ summary: 'Chi tiêu theo kỳ, kèm phân bổ theo dịch vụ' })
  chiTieu(@CurrentUser() user: { id: string }, @Query('period') ky?: string) {
    const chon = ky === 'month' || ky === 'year' ? ky : 'week';
    return this.service.chiTieu(user.id, chon);
  }

  @Get('transactions/:ma')
  @ApiOperation({ summary: 'Chi tiết một giao dịch của chủ nuôi' })
  chiTiet(@CurrentUser() user: { id: string }, @Param('ma') ma: string) {
    return this.service.chiTiet(user.id, ma);
  }
}
