import {
  Body,
  Controller,
  Delete,
  Get,
  Param,
  Patch,
  Post,
  Query,
  UseGuards,
} from '@nestjs/common';
import { ApiBearerAuth, ApiOperation, ApiTags } from '@nestjs/swagger';
import type { NotificationRole } from 'generated/prisma/enums';
import { CurrentUser } from '../../common/decorators/current-user.decorator';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { DeviceTokenDto } from './dto/device-token.dto';
import { NotificationsService } from './notifications.service';

@ApiTags('notifications')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller('notifications')
export class NotificationsController {
  constructor(private readonly service: NotificationsService) {}

  @Get()
  @ApiOperation({ summary: 'Danh sách thông báo, cuộn theo con trỏ thời gian' })
  danhSach(
    @CurrentUser() user: { id: string },
    @Query('truoc') truoc?: string,
    @Query('role') role?: NotificationRole,
  ) {
    return this.service.danhSach(user.id, { truoc, role });
  }

  @Get('unread-count')
  @ApiOperation({
    summary: 'Số thông báo chưa đọc, dùng cho chấm đỏ trên chuông',
  })
  soChuaDoc(@CurrentUser() user: { id: string }) {
    return this.service.soChuaDoc(user.id);
  }

  @Patch(':id/read')
  @ApiOperation({ summary: 'Đánh dấu một thông báo đã đọc' })
  danhDauDaDoc(@CurrentUser() user: { id: string }, @Param('id') id: string) {
    return this.service.danhDauDaDoc(user.id, id);
  }

  @Post('read-all')
  @ApiOperation({ summary: 'Đánh dấu tất cả đã đọc' })
  danhDauDocHet(@CurrentUser() user: { id: string }) {
    return this.service.danhDauDocHet(user.id);
  }

  @Post('device-token')
  @ApiOperation({ summary: 'Đăng ký thiết bị nhận push' })
  luuThietBi(@CurrentUser() user: { id: string }, @Body() dto: DeviceTokenDto) {
    return this.service.luuThietBi(
      user.id,
      dto.token,
      dto.platform,
      dto.locale,
    );
  }

  @Delete('device-token/:token')
  @ApiOperation({ summary: 'Gỡ thiết bị khỏi danh sách nhận push' })
  xoaThietBi(@Param('token') token: string) {
    return this.service.xoaThietBi(token);
  }
}
