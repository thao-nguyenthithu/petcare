import { Module } from '@nestjs/common';
import { AuthModule } from '../auth/auth.module';
import { MediaModule } from '../media/media.module';
import { ChatPhotoService } from './chat-photo.service';
import { BookingChatService } from './booking-chat.service';
import { MessagingController } from './messaging.controller';
import { MessagingGateway } from './messaging.gateway';
import { MessagingService } from './messaging.service';
import { SystemMessageService } from './system-message.service';

@Module({
  imports: [AuthModule, MediaModule],
  controllers: [MessagingController],
  providers: [
    MessagingService,
    ChatPhotoService,
    MessagingGateway,
    SystemMessageService,
    BookingChatService,
  ],
  exports: [MessagingService, BookingChatService],
})
export class MessagingModule {}
