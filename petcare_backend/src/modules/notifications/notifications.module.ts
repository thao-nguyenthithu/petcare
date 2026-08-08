import { Module } from '@nestjs/common';
import { BullModule } from '@nestjs/bullmq';
import { AuthModule } from '../auth/auth.module';
import { FirebaseModule } from '../firebase/firebase.module';
import { BookingNotifyService } from './booking-notify.service';
import { NotificationsController } from './notifications.controller';
import { NotificationsGateway } from './notifications.gateway';
import { NotificationsService } from './notifications.service';
import { PreventionNotifyService } from './prevention-notify.service';
import { SitterWarningNotifyService } from './sitter-warning-notify.service';

export const NOTIFICATION_QUEUE = 'notification';

@Module({
  imports: [
    BullModule.registerQueue({ name: NOTIFICATION_QUEUE }),
    FirebaseModule,
    AuthModule,
  ],
  controllers: [NotificationsController],
  providers: [
    NotificationsGateway,
    NotificationsService,
    BookingNotifyService,
    SitterWarningNotifyService,
    PreventionNotifyService,
  ],
  exports: [
    NotificationsService,
    BookingNotifyService,
    SitterWarningNotifyService,
    PreventionNotifyService,
    BullModule,
  ],
})
export class NotificationsModule {}
