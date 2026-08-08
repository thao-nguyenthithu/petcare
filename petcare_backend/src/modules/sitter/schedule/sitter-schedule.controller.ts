import {
  Body,
  Controller,
  Get,
  Param,
  Post,
  Put,
  Query,
  UseGuards,
} from '@nestjs/common';
import { ApiBearerAuth, ApiOperation, ApiTags } from '@nestjs/swagger';
import { CurrentUser } from '../../../common/decorators/current-user.decorator';
import { JwtAuthGuard } from '../../auth/guards/jwt-auth.guard';
import { SitterGuard } from '../../auth/guards/sitter.guard';
import { BlockDaysOffDto } from './dto/block-days-off.dto';
import { CancelBookingDto } from './dto/cancel-booking.dto';
import { ScheduleRangeDto } from './dto/schedule-range.dto';
import { UpdateDayAvailabilityDto } from './dto/update-day-availability.dto';
import { UpdateWorkingHoursDto } from './dto/update-working-hours.dto';
import { ScheduleSettingsService } from './schedule-settings.service';
import { ScheduleViewService } from './schedule-view.service';
import { SitterScheduleService } from './sitter-schedule.service';

@ApiTags('sitter-schedule')
@ApiBearerAuth()
// Lịch làm việc chỉ có nghĩa với hồ sơ ĐÃ DUYỆT.
@UseGuards(JwtAuthGuard, SitterGuard)
@Controller('sitter/schedule')
export class SitterScheduleController {
  constructor(
    private readonly service: SitterScheduleService,
    private readonly xem: ScheduleViewService,
    private readonly caiDat: ScheduleSettingsService,
  ) {}

  @Get()
  @ApiOperation({
    summary: 'Lịch đơn và giờ rảnh của NCC trong một khoảng ngày',
  })
  xemLich(@CurrentUser() user: { id: string }, @Query() dto: ScheduleRangeDto) {
    return this.xem.xemLich(user.id, dto.from, dto.to);
  }

  @Put('working-hours')
  @ApiOperation({ summary: 'Đặt giờ làm việc mặc định và thứ nhận đơn' })
  luuGioLamViec(
    @CurrentUser() user: { id: string },
    @Body() dto: UpdateWorkingHoursDto,
  ) {
    return this.caiDat.luuGioLamViec(user.id, dto);
  }

  @Put('day')
  @ApiOperation({ summary: 'Chỉnh riêng một ngày: giờ riêng, nghỉ, số chỗ' })
  luuNgay(
    @CurrentUser() user: { id: string },
    @Body() dto: UpdateDayAvailabilityDto,
  ) {
    return this.caiDat.luuNgay(user.id, dto);
  }

  @Post('block')
  @ApiOperation({ summary: 'Chặn cả một khoảng ngày nghỉ' })
  datNghiKhoang(
    @CurrentUser() user: { id: string },
    @Body() dto: BlockDaysOffDto,
  ) {
    return this.caiDat.datNghiKhoang(user.id, dto);
  }

  @Post('bookings/:id/cancel')
  @ApiOperation({ summary: 'NCC huỷ một đơn đã xác nhận' })
  huyDon(
    @CurrentUser() user: { id: string },
    @Param('id') id: string,
    @Body() dto: CancelBookingDto,
  ) {
    return this.service.huyDon(user.id, id, dto);
  }
}
