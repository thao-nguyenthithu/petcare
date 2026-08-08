import {
  Body,
  Controller,
  Delete,
  Get,
  Param,
  Post,
  Query,
} from '@nestjs/common';
import { ApiOperation, ApiTags } from '@nestjs/swagger';
import { CurrentUser } from '../../../common/decorators/current-user.decorator';
import { QuanTri } from '../chung/quan-tri.decorator';
import type { QuanTriVien } from '../chung/quan-tri.decorator';
import { AdminNotificationsReadService } from './admin-notifications-read.service';
import { AdminNotificationsWriteService } from './admin-notifications-write.service';
import {
  DemNguoiNhanDto,
  GuiThongBaoDto,
  LocLuotGuiDto,
} from './dto/thong-bao-quan-tri.dto';

@ApiTags('admin')
@QuanTri()
@Controller('admin/notifications')
export class AdminNotificationsController {
  constructor(
    private readonly doc: AdminNotificationsReadService,
    private readonly ghi: AdminNotificationsWriteService,
  ) {}

  @Get('campaigns')
  @ApiOperation({ summary: 'Lịch sử các lượt gửi tay, mới nhất trước' })
  danhSach(@Query() loc: LocLuotGuiDto) {
    return this.doc.danhSachLuot(loc);
  }

  @Get('audience')
  @ApiOperation({ summary: 'Số tài khoản của một nhóm nhận' })
  async demNguoiNhan(@Query() loc: DemNguoiNhanDto) {
    const count = await this.doc.demNguoiNhan(loc.kind, loc.value);
    return { kind: loc.kind, value: loc.value ?? null, count };
  }

  @Post('broadcast')
  @ApiOperation({ summary: 'Xếp hàng gửi thông báo hệ thống, không lùi được' })
  gui(@CurrentUser() admin: QuanTriVien, @Body() dto: GuiThongBaoDto) {
    return this.ghi.gui(dto, admin.id);
  }

  @Delete('campaigns/:id')
  @ApiOperation({ summary: 'Huỷ một lượt gửi còn đang hẹn giờ' })
  huyLich(@CurrentUser() admin: QuanTriVien, @Param('id') id: string) {
    return this.ghi.huyLich(id, admin.id);
  }
}
