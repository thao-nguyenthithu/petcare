import {
  Body,
  Controller,
  Get,
  Param,
  ParseUUIDPipe,
  Post,
  Query,
  UseGuards,
} from '@nestjs/common';
import { ApiBearerAuth, ApiOperation, ApiTags } from '@nestjs/swagger';
import { CurrentUser } from '../../common/decorators/current-user.decorator';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { BookingsService } from './bookings.service';
import { CancelBookingDto } from './dto/cancel-booking.dto';
import { CreateBookingDto } from './dto/create-booking.dto';
import { EndEarlyDto } from './dto/end-early.dto';
import { ListBookingsDto } from './dto/list-bookings.dto';
import { OwnerBookingDetailService } from './owner-booking-detail.service';
import { OwnerBookingsService } from './owner-bookings.service';

@ApiTags('bookings')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller('bookings')
export class BookingsController {
  constructor(
    private readonly service: BookingsService,
    private readonly ownerBookings: OwnerBookingsService,
    private readonly ownerDetail: OwnerBookingDetailService,
  ) {}

  @Post()
  @ApiOperation({ summary: 'Chủ nuôi tạo đơn từ luồng đặt lịch' })
  taoDon(@CurrentUser() user: { id: string }, @Body() dto: CreateBookingDto) {
    return this.service.taoDon(user.id, dto);
  }

  @Get()
  @ApiOperation({
    summary: 'Danh sách đơn của chính chủ nuôi, lọc theo tab và dịch vụ',
  })
  danhSachCuaToi(
    @CurrentUser() user: { id: string },
    @Query() dto: ListBookingsDto,
  ) {
    return this.ownerBookings.danhSachCuaToi(user.id, dto);
  }

  @Get(':id')
  @ApiOperation({ summary: 'Chi tiết một đơn của chính chủ nuôi' })
  chiTiet(
    @CurrentUser() user: { id: string },
    @Param('id', ParseUUIDPipe) id: string,
  ) {
    return this.ownerDetail.chiTiet(user.id, id);
  }

  @Post(':id/cancel')
  @ApiOperation({
    summary: 'Chủ nuôi huỷ đơn, phí tính theo chính sách huỷ của nền tảng',
  })
  huyDon(
    @CurrentUser() user: { id: string },
    @Param('id', ParseUUIDPipe) id: string,
    @Body() dto: CancelBookingDto,
  ) {
    return this.ownerDetail.huy(user.id, id, dto);
  }

  @Post(':id/confirm')
  @ApiOperation({
    summary: 'Chủ nuôi xác nhận đơn đã xong, quá hạn hệ thống tự chốt',
  })
  xacNhanHoanThanh(
    @CurrentUser() user: { id: string },
    @Param('id', ParseUUIDPipe) id: string,
  ) {
    return this.ownerDetail.xacNhanHoanThanh(user.id, id);
  }

  @Post(':id/depart')
  @ApiOperation({
    summary:
      'Chủ nuôi bấm xuất phát ở đơn trông giữ, cả lượt đi và lượt đón về',
  })
  xuatPhat(
    @CurrentUser() user: { id: string },
    @Param('id', ParseUUIDPipe) id: string,
  ) {
    return this.ownerDetail.xuatPhat(user.id, id);
  }

  @Post(':id/end-early')
  @ApiOperation({
    summary: 'Chủ nuôi kết thúc sớm kỳ trông giữ, cắt bớt số đêm còn lại',
  })
  ketThucSom(
    @CurrentUser() user: { id: string },
    @Param('id', ParseUUIDPipe) id: string,
    @Body() dto: EndEarlyDto,
  ) {
    return this.ownerDetail.ketThucSom(user.id, id, dto);
  }
}
