import {
  Body,
  Controller,
  Get,
  Param,
  ParseUUIDPipe,
  Post,
  UseGuards,
} from '@nestjs/common';
import { ApiBearerAuth, ApiOperation, ApiTags } from '@nestjs/swagger';
import { CurrentUser } from '../../common/decorators/current-user.decorator';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { GpsBatchDto } from './dto/gps-batch.dto';
import { GpsService } from './gps.service';

@ApiTags('gps')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller('gps')
export class GpsController {
  constructor(private readonly service: GpsService) {}

  @Post('waypoints/batch')
  @ApiOperation({
    summary: 'NCC gửi batch lịch sử lộ trình (5 điểm hoặc 2 phút một lần)',
  })
  guiBatch(@CurrentUser() user: { id: string }, @Body() dto: GpsBatchDto) {
    return this.service.ghiBatch(user.id, dto);
  }

  @Get('bookings/:id/track')
  @ApiOperation({
    summary: 'Lịch sử lộ trình một đơn đã lọc noise, cho hai vai của đơn',
  })
  lichSu(
    @CurrentUser() user: { id: string },
    @Param('id', ParseUUIDPipe) id: string,
  ) {
    return this.service.lichSuLoTrinh(user.id, id);
  }
}
