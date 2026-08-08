import { Module } from '@nestjs/common';
import { MessagingModule } from '../messaging/messaging.module';
import { NotificationsModule } from '../notifications/notifications.module';
import { PaymentsModule } from '../payments/payments.module';
import { BookingsController } from './bookings.controller';
import { BookingsService } from './bookings.service';
import { BookingWriteService } from './booking-write.service';
import { AutoCompleteJob } from './auto-complete.job';
import { BookingSweepJob } from './booking-sweep.job';
import { OwnerBookingDetailService } from './owner-booking-detail.service';
import { OwnerBookingsService } from './owner-bookings.service';
import { SitterPenaltyService } from './sitter-penalty.service';
import { SitterSlotsService } from './sitter-slots.service';
import { SearchModule } from '../search/search.module';

@Module({
  imports: [NotificationsModule, PaymentsModule, MessagingModule, SearchModule],
  controllers: [BookingsController],
  providers: [
    BookingsService,
    BookingWriteService,
    OwnerBookingsService,
    OwnerBookingDetailService,
    SitterSlotsService,
    SitterPenaltyService,
    BookingSweepJob,
    AutoCompleteJob,
  ],
  exports: [SitterSlotsService, SitterPenaltyService],
})
export class BookingsModule {}
