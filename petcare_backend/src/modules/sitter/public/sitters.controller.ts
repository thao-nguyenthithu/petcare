import { Controller, Get, Param, Query, UseGuards } from '@nestjs/common';
import { ApiBearerAuth, ApiOperation, ApiTags } from '@nestjs/swagger';
import { CurrentUser } from '../../../common/decorators/current-user.decorator';
import { JwtAuthGuard } from '../../auth/guards/jwt-auth.guard';
import { SlotsQueryDto } from '../../bookings/dto/slots-query.dto';
import { SitterSlotsService } from '../../bookings/sitter-slots.service';
import { SittersService } from './sitters.service';

@ApiTags('sitters')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller('sitters')
export class SittersController {
  constructor(
    private readonly service: SittersService,
    private readonly slots: SitterSlotsService,
  ) {}

  @Get(':id/slots')
  @ApiOperation({ summary: 'Lịch trống của NCC cho trang chọn ngày và giờ' })
  layLich(
    @CurrentUser() user: { id: string },
    @Param('id') id: string,
    @Query() dto: SlotsQueryDto,
  ) {
    return this.slots.layLich(id, dto.from, dto.to, {
      petIds: dto.petIds,
      ownerId: user.id,
      xemBoiUserId: user.id,
    });
  }

  @Get(':id')
  @ApiOperation({ summary: 'Xem hồ sơ công khai của một NCC theo id' })
  getPublicProfile(
    @CurrentUser() user: { id: string },
    @Param('id') id: string,
  ) {
    return this.service.getPublicProfile(id, user.id);
  }
}
