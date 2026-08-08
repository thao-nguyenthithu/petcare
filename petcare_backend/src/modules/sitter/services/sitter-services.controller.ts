import { Body, Controller, Get, Post, Put, UseGuards } from '@nestjs/common';
import { ApiBearerAuth, ApiOperation, ApiTags } from '@nestjs/swagger';
import { CurrentUser } from '../../../common/decorators/current-user.decorator';
import { JwtAuthGuard } from '../../auth/guards/jwt-auth.guard';
import { SitterGuard } from '../../auth/guards/sitter.guard';
import { UpdateServiceAreaDto } from './dto/update-service-area.dto';
import { UpdateServicesDto } from './dto/update-services.dto';
import { SitterServicesService } from './sitter-services.service';

@ApiTags('sitter-services')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard, SitterGuard)
@Controller('sitter')
export class SitterServicesController {
  constructor(private readonly service: SitterServicesService) {}

  @Get('services')
  @ApiOperation({ summary: 'Lấy cấu hình 3 loại dịch vụ của NCC' })
  getServices(@CurrentUser() user: { id: string }) {
    return this.service.getServices(user.id);
  }

  @Put('services')
  @ApiOperation({ summary: 'Lưu cấu hình 3 loại dịch vụ của NCC' })
  updateServices(
    @CurrentUser() user: { id: string },
    @Body() dto: UpdateServicesDto,
  ) {
    return this.service.updateServices(user.id, dto);
  }

  @Get('service-area')
  @ApiOperation({ summary: 'Lấy khu vực phục vụ của NCC' })
  getServiceArea(@CurrentUser() user: { id: string }) {
    return this.service.getServiceArea(user.id);
  }

  @Put('service-area')
  @ApiOperation({ summary: 'Lưu khu vực phục vụ của NCC' })
  updateServiceArea(
    @CurrentUser() user: { id: string },
    @Body() dto: UpdateServiceAreaDto,
  ) {
    return this.service.updateServiceArea(user.id, dto);
  }

  @Get('onboarding')
  @ApiOperation({ summary: 'Trạng thái hoàn tất onboarding (onboardedAt)' })
  getOnboarding(@CurrentUser() user: { id: string }) {
    return this.service.getOnboarding(user.id);
  }

  @Post('onboarding/complete')
  @ApiOperation({ summary: 'Đánh dấu NCC bấm "Bắt đầu nhận đơn"' })
  completeOnboarding(@CurrentUser() user: { id: string }) {
    return this.service.completeOnboarding(user.id);
  }
}
