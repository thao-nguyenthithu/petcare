import {
  Body,
  Controller,
  Get,
  Param,
  Post,
  Put,
  Query,
  UploadedFiles,
  UseGuards,
  UseInterceptors,
} from '@nestjs/common';
import { FilesInterceptor } from '@nestjs/platform-express';
import { ApiBearerAuth, ApiOperation, ApiTags } from '@nestjs/swagger';
import { CurrentUser } from '../../common/decorators/current-user.decorator';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { SitterGuard } from '../auth/guards/sitter.guard';
import {
  CAU_HINH_ANH,
  TRAN_TEP_MOI_LUOT,
  type UploadedImage,
} from '../media/image-upload';
import { DisputeService } from './dispute.service';
import {
  BankAccountDto,
  DisputeReplyDto,
  ListTransactionsDto,
  WithdrawDto,
} from './dto/wallet.dto';
import { EarningsService, type KyThuNhap } from './earnings.service';
import { WalletTransactionsService } from './wallet-transactions.service';
import { WalletService } from './wallet.service';
import { WithdrawalService } from './withdrawal.service';

@ApiTags('wallet')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard, SitterGuard)
@Controller('sitter/wallet')
export class WalletController {
  constructor(
    private readonly wallet: WalletService,
    private readonly transactions: WalletTransactionsService,
    private readonly withdrawal: WithdrawalService,
    private readonly disputes: DisputeService,
  ) {}

  @Get()
  @ApiOperation({ summary: 'Số dư, khoản giữ tạm và thu nhập tuần' })
  cuaToi(@CurrentUser() user: { id: string }) {
    return this.wallet.cuaToi(user.id);
  }

  @Get('transactions')
  @ApiOperation({ summary: 'Lịch sử giao dịch ví, lọc theo loại' })
  lichSu(
    @CurrentUser() user: { id: string },
    @Query() dto: ListTransactionsDto,
  ) {
    return this.transactions.danhSach(user.id, dto);
  }

  @Get('transactions/:code')
  @ApiOperation({ summary: 'Chi tiết một giao dịch ví' })
  chiTietGiaoDich(
    @CurrentUser() user: { id: string },
    @Param('code') code: string,
  ) {
    return this.transactions.chiTiet(user.id, code);
  }

  @Get('bank-account')
  @ApiOperation({ summary: 'Tài khoản nhận tiền, null là chưa liên kết' })
  taiKhoan(@CurrentUser() user: { id: string }) {
    return this.withdrawal.taiKhoan(user.id);
  }

  @Put('bank-account')
  @ApiOperation({ summary: 'Thêm hoặc đổi tài khoản nhận tiền' })
  luuTaiKhoan(
    @CurrentUser() user: { id: string },
    @Body() dto: BankAccountDto,
  ) {
    return this.withdrawal.luuTaiKhoan(user.id, dto);
  }

  @Get('withdrawals')
  @ApiOperation({ summary: 'Các lệnh rút gần đây' })
  lenhRut(@CurrentUser() user: { id: string }) {
    return this.withdrawal.danhSachLenh(user.id);
  }

  @Post('withdrawals')
  @ApiOperation({ summary: 'Tạo lệnh rút, trừ số dư ngay' })
  rut(@CurrentUser() user: { id: string }, @Body() dto: WithdrawDto) {
    return this.withdrawal.rut(user.id, dto);
  }

  @Get('disputes')
  @ApiOperation({ summary: 'Hồ sơ khiếu nại liên quan tới đơn của tôi' })
  khieuNai(@CurrentUser() user: { id: string }) {
    return this.disputes.cuaNguoiCham(user.id);
  }

  @Post('disputes/:code/reply')
  @ApiOperation({ summary: 'Người chăm đáp lại một khiếu nại, một lần' })
  @UseInterceptors(FilesInterceptor('photos', TRAN_TEP_MOI_LUOT, CAU_HINH_ANH))
  phanHoi(
    @CurrentUser() user: { id: string },
    @Param('code') code: string,
    @UploadedFiles() files: UploadedImage[],
    @Body() dto: DisputeReplyDto,
  ) {
    return this.disputes.phanHoi(user.id, code, dto, files ?? []);
  }
}

@ApiTags('wallet')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard, SitterGuard)
@Controller('provider/earnings')
export class EarningsController {
  constructor(private readonly earnings: EarningsService) {}

  @Get()
  @ApiOperation({ summary: 'Thu nhập theo kỳ tuần, tháng hoặc năm' })
  theoKy(@CurrentUser() user: { id: string }, @Query('period') ky?: string) {
    const hopLe: KyThuNhap[] = ['week', 'month', 'year'];
    const chon = hopLe.includes(ky as KyThuNhap) ? (ky as KyThuNhap) : 'week';
    return this.earnings.theoKy(user.id, chon);
  }
}
