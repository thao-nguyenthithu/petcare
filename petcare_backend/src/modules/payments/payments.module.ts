import { Module } from '@nestjs/common';
import { BullModule } from '@nestjs/bullmq';
import { AdminModule } from '../admin/admin.module';
import { NotificationsModule } from '../notifications/notifications.module';
import { AutoGateway } from './gateways/auto.gateway';
import { MockGateway } from './gateways/mock.gateway';
import { PaymentGatewayResolver } from './gateways/payment-gateway.resolver';
import { OwnerPaymentsController } from './owner-payments.controller';
import { OwnerPaymentsService } from './owner-payments.service';
import { PaymentExpireProcessor } from './payment-expire.processor';
import { PAYMENT_QUEUE } from './payments.constants';
import {
  BookingPaymentsController,
  PaymentsGatewayController,
} from './payments.controller';
import { PaymentsService } from './payments.service';
import { VnpayGateway } from './gateways/vnpay.gateway';

@Module({
  imports: [
    BullModule.registerQueue({ name: PAYMENT_QUEUE }),
    NotificationsModule,
    AdminModule,
  ],
  controllers: [
    BookingPaymentsController,
    PaymentsGatewayController,
    OwnerPaymentsController,
  ],
  providers: [
    PaymentsService,
    OwnerPaymentsService,
    PaymentExpireProcessor,
    PaymentGatewayResolver,
    AutoGateway,
    MockGateway,
    VnpayGateway,
  ],
  exports: [PaymentsService],
})
export class PaymentsModule {}
