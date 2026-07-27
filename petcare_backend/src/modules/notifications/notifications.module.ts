import { Module } from '@nestjs/common';
import { BullModule } from '@nestjs/bullmq';

export const NOTIFICATION_QUEUE = 'notification';

@Module({
  imports: [BullModule.registerQueue({ name: NOTIFICATION_QUEUE })],
  exports: [BullModule],
})
export class NotificationsModule {}
