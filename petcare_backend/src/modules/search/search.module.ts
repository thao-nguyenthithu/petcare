import { Module } from '@nestjs/common';
import { PrismaModule } from '../../prisma/prisma.module';
import { SearchHistoryService } from './search-history.service';
import { SearchSittersController } from './search-sitters.controller';
import { SearchController } from './search.controller';
import { SitterScoreService } from './sitter-score.service';
import { SitterSearchService } from './sitter-search.service';

@Module({
  imports: [PrismaModule],
  controllers: [SearchController, SearchSittersController],
  providers: [SearchHistoryService, SitterSearchService, SitterScoreService],
  exports: [SitterScoreService],
})
export class SearchModule {}
