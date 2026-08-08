import { Controller, Get, Query, UseGuards } from '@nestjs/common';
import { ApiBearerAuth, ApiOperation, ApiTags } from '@nestjs/swagger';
import { CurrentUser } from '../../common/decorators/current-user.decorator';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { SearchSittersDto } from './dto/search-sitters.dto';
import { SitterSearchService } from './sitter-search.service';
@ApiTags('search')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller('search/sitters')
export class SearchSittersController {
  constructor(private readonly service: SitterSearchService) {}

  @Get()
  @ApiOperation({
    summary: 'Tìm người chăm theo dịch vụ, khu vực, ngày, giá, đánh giá',
  })
  search(@CurrentUser() user: { id: string }, @Query() dto: SearchSittersDto) {
    return this.service.search(dto, user.id);
  }
}
