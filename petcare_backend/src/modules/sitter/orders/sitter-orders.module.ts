import { Module } from '@nestjs/common';
import { BookingsModule } from '../../bookings/bookings.module';
import { NotificationsModule } from '../../notifications/notifications.module';
import { GpsModule } from '../../gps/gps.module';
import { MediaModule } from '../../media/media.module';
import { MessagingModule } from '../../messaging/messaging.module';
import { BullModule } from '@nestjs/bullmq';
import { AuthModule } from '../../auth/auth.module';
import { SearchModule } from '../../search/search.module';
import { AiModule } from '../../ai/ai.module';
import { WalletModule } from '../../wallet/wallet.module';
import { CHECKIN_SCAN_QUEUE } from './checkin-scan.constants';
import { CheckinScanGateway } from './checkin-scan.gateway';
import { CheckinScanProcessor } from './checkin-scan.processor';
import { PetSafetyScanReadService } from './pet-safety-scan-read.service';
import { PetSafetyScanService } from './pet-safety-scan.service';
import { SitterActionsService } from './sitter-actions.service';
import { SitterBookingsService } from './sitter-bookings.service';
import { SitterCancelService } from './sitter-cancel.service';
import { SitterLichService } from './sitter-lich.service';
import { SitterOrderStore } from './sitter-order-store.service';
import { SitterOrdersController } from './sitter-orders.controller';
import { SitterSessionService } from './sitter-session.service';

// Vòng đời đơn phía người chăm
@Module({
  imports: [
    NotificationsModule,
    MediaModule,
    GpsModule,
    MessagingModule,
    SearchModule,
    BookingsModule,
    AiModule,
    WalletModule,
    BullModule.registerQueue({ name: CHECKIN_SCAN_QUEUE }),
    AuthModule,
  ],
  controllers: [SitterOrdersController],
  providers: [
    SitterBookingsService,
    SitterOrderStore,
    SitterLichService,
    SitterActionsService,
    SitterSessionService,
    SitterCancelService,
    PetSafetyScanService,
    PetSafetyScanReadService,
    CheckinScanGateway,
    CheckinScanProcessor,
  ],
  exports: [SitterActionsService, SitterCancelService],
})
export class SitterOrdersModule {}
