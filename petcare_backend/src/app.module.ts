import { Module } from '@nestjs/common';
import { ConfigModule, ConfigService } from '@nestjs/config';
import { BullModule } from '@nestjs/bullmq';
import { ScheduleModule } from '@nestjs/schedule';
import configuration from './config/configuration';
import { PrismaModule } from './prisma/prisma.module';
import { RedisModule } from './common/redis/redis.module';
import { tuyChonRedis } from './common/redis/redis-ket-noi';
import { MailModule } from './modules/mail/mail.module';
import { AuthModule } from './modules/auth/auth.module';
import { MediaModule } from './modules/media/media.module';
import { SitterProfileModule } from './modules/sitter/profile/sitter-profile.module';
import { SitterServicesModule } from './modules/sitter/services/sitter-services.module';
import { SitterMeModule } from './modules/sitter/me/sitter-me.module';
import { SitterScheduleModule } from './modules/sitter/schedule/sitter-schedule.module';
import { SearchModule } from './modules/search/search.module';
import { SittersModule } from './modules/sitter/public/sitters.module';
import { AddressesModule } from './modules/addresses/addresses.module';
import { PetsModule } from './modules/pets/pets.module';
import { BookingsModule } from './modules/bookings/bookings.module';
import { SitterOrdersModule } from './modules/sitter/orders/sitter-orders.module';
import { GpsModule } from './modules/gps/gps.module';
import { NotificationsModule } from './modules/notifications/notifications.module';
import { ReviewsModule } from './modules/reviews/reviews.module';
import { AdminModule } from './modules/admin/admin.module';
import { ThamSoModule } from './modules/admin/tham-so.module';
import { PaymentsModule } from './modules/payments/payments.module';
import { MessagingModule } from './modules/messaging/messaging.module';
import { WalletModule } from './modules/wallet/wallet.module';
import { SitterHomeModule } from './modules/sitter/home/sitter-home.module';
import { AiModule } from './modules/ai/ai.module';

@Module({
  imports: [
    ConfigModule.forRoot({
      isGlobal: true,
      load: [configuration],
      envFilePath: '.env',
    }),
    ScheduleModule.forRoot(),
    BullModule.forRootAsync({
      inject: [ConfigService],
      useFactory: (config: ConfigService) => ({
        connection: tuyChonRedis(config),
      }),
    }),
    PrismaModule,
    RedisModule,
    ThamSoModule,
    MailModule,
    AuthModule,
    MediaModule,
    SitterProfileModule,
    SitterServicesModule,
    SitterMeModule,
    SitterScheduleModule,
    SittersModule,
    SearchModule,
    AddressesModule,
    PetsModule,
    BookingsModule,
    SitterOrdersModule,
    GpsModule,
    NotificationsModule,
    ReviewsModule,
    PaymentsModule,
    AdminModule,
    MessagingModule,
    WalletModule,
    SitterHomeModule,
    AiModule,
  ],
})
export class AppModule {}
