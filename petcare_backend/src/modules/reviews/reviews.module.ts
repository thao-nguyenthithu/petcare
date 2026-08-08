import { Module } from '@nestjs/common';
import { MediaModule } from '../media/media.module';
import { NotificationsModule } from '../notifications/notifications.module';
import { SearchModule } from '../search/search.module';
import {
  ReviewsController,
  SitterReviewsController,
} from './reviews.controller';
import { ReviewsService } from './reviews.service';

// Hai controller vì hai vai đi qua hai guard khác nhau
@Module({
  imports: [NotificationsModule, SearchModule, MediaModule],
  controllers: [ReviewsController, SitterReviewsController],
  providers: [ReviewsService],
})
export class ReviewsModule {}
