import { Controller, Get, UseGuards } from '@nestjs/common';
import { ApiBearerAuth, ApiOperation, ApiTags } from '@nestjs/swagger';
import { CurrentUser } from '../../../common/decorators/current-user.decorator';
import { JwtAuthGuard } from '../../auth/guards/jwt-auth.guard';
import { SitterGuard } from '../../auth/guards/sitter.guard';
import { OwnerHomeService } from './owner-home.service';
import { SitterHomeService } from './sitter-home.service';

@ApiTags('sitter-home')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard, SitterGuard)
@Controller('sitter/home')
export class SitterHomeController {
  constructor(private readonly service: SitterHomeService) {}

  @Get()
  @ApiOperation({ summary: 'Số liệu đầu tab Công việc của người chăm' })
  dashboard(@CurrentUser() user: { id: string }) {
    return this.service.dashboard(user.id);
  }
}

// Home của CHỦ NUÔI
@ApiTags('home')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller('home')
export class OwnerHomeController {
  constructor(private readonly service: OwnerHomeService) {}

  @Get()
  @ApiOperation({ summary: 'Đơn đang chạy và người chăm từng đặt' })
  trangChu(@CurrentUser() user: { id: string }) {
    return this.service.trangChu(user.id);
  }
}
