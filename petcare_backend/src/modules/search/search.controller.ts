import { Body, Controller, Delete, Get, Post, UseGuards } from '@nestjs/common';
import { ApiBearerAuth, ApiOperation, ApiTags } from '@nestjs/swagger';
import { CurrentUser } from '../../common/decorators/current-user.decorator';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { AddSearchHistoryDto } from './dto/add-search-history.dto';
import { SearchHistoryService } from './search-history.service';

// Lịch sử từ khoá của chính người dùng.
@ApiTags('search')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller('search/history')
export class SearchController {
  constructor(private readonly service: SearchHistoryService) {}

  @Get()
  @ApiOperation({ summary: 'Lịch sử tìm kiếm của chính mình' })
  danhSach(@CurrentUser() user: { id: string }) {
    return this.service.danhSach(user.id);
  }

  @Post()
  @ApiOperation({ summary: 'Ghi một từ khoá vừa tìm vào lịch sử' })
  them(@CurrentUser() user: { id: string }, @Body() dto: AddSearchHistoryDto) {
    return this.service.them(user.id, dto.keyword);
  }

  @Delete()
  @ApiOperation({ summary: 'Xoá toàn bộ lịch sử tìm kiếm của chính mình' })
  xoaHet(@CurrentUser() user: { id: string }) {
    return this.service.xoaHet(user.id);
  }
}
