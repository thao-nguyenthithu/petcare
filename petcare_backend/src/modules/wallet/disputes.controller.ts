import {
  Body,
  Controller,
  Get,
  Param,
  Post,
  UploadedFiles,
  UseGuards,
  UseInterceptors,
} from '@nestjs/common';
import { FilesInterceptor } from '@nestjs/platform-express';
import { ApiBearerAuth, ApiOperation, ApiTags } from '@nestjs/swagger';
import { CurrentUser } from '../../common/decorators/current-user.decorator';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import {
  CAU_HINH_ANH,
  TRAN_TEP_MOI_LUOT,
  type UploadedImage,
} from '../media/image-upload';
import { DisputeService } from './dispute.service';
import { OpenDisputeDto } from './dto/wallet.dto';

@ApiTags('disputes')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller()
export class DisputesController {
  constructor(private readonly disputes: DisputeService) {}

  @Post('bookings/:id/dispute')
  @ApiOperation({ summary: 'Chủ nuôi mở khiếu nại, tiền tiếp tục bị giữ' })
  @UseInterceptors(FilesInterceptor('photos', TRAN_TEP_MOI_LUOT, CAU_HINH_ANH))
  mo(
    @CurrentUser() user: { id: string },
    @Param('id') bookingId: string,
    @UploadedFiles() files: UploadedImage[],
    @Body() dto: OpenDisputeDto,
  ) {
    return this.disputes.mo(user.id, bookingId, dto, files ?? []);
  }

  @Get('disputes/:code')
  @ApiOperation({ summary: 'Hồ sơ khiếu nại theo mã, hai vai cùng đọc' })
  theoMa(@CurrentUser() user: { id: string }, @Param('code') code: string) {
    return this.disputes.theoMa(user.id, code);
  }
}
