import { Module } from '@nestjs/common';
import { MediaModule } from '../media/media.module';
import { NotificationsModule } from '../notifications/notifications.module';
import { PetsController } from './pets.controller';
import { PetsService } from './pets.service';
import { PreventionReminderJob } from './prevention-reminder.job';
import { PreventionsService } from './preventions.service';

@Module({
  imports: [MediaModule, NotificationsModule],
  controllers: [PetsController],
  providers: [PetsService, PreventionsService, PreventionReminderJob],
})
export class PetsModule {}
