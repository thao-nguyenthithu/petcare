import { Body, Controller, Get, Post, Query, UseGuards } from '@nestjs/common';
import { ApiBearerAuth, ApiOperation, ApiTags } from '@nestjs/swagger';
import { CurrentUser } from '../../common/decorators/current-user.decorator';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { CreateProviderProfileDto } from './dto/create-provider-profile.dto';
import { ProviderProfileService } from './provider-profile.service';

@ApiTags('provider-profile')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller('provider-profile')
export class ProviderProfileController {
  constructor(private readonly service: ProviderProfileService) {}

  @Post()
  @ApiOperation({ summary: 'Gửi hồ sơ đăng ký nhà cung cấp, chờ duyệt 24h' })
  submit(
    @CurrentUser() user: { id: string },
    @Body() dto: CreateProviderProfileDto,
  ) {
    return this.service.submit(user.id, dto);
  }

  @Get('check-cccd')
  @ApiOperation({ summary: 'Kiểm tra số CCCD đã có ở hồ sơ người khác chưa' })
  checkCccd(
    @CurrentUser() user: { id: string },
    @Query('nationalId') nationalId: string,
  ) {
    return this.service.checkCccd(user.id, nationalId);
  }

  @Get('me')
  @ApiOperation({ summary: 'Xem trạng thái hồ sơ NCC của tôi' })
  getMine(@CurrentUser() user: { id: string }) {
    return this.service.getMine(user.id);
  }
}
