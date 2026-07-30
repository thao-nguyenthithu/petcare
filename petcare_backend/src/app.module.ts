import { Module } from '@nestjs/common';
import { ConfigModule, ConfigService } from '@nestjs/config';
import { BullModule } from '@nestjs/bullmq';
import { ScheduleModule } from '@nestjs/schedule';
import { AppController } from './app.controller';
import { AppService } from './app.service';
import configuration from './config/configuration';
import { PrismaModule } from './prisma/prisma.module';
import { RedisModule } from './common/redis/redis.module';
import { MailModule } from './modules/mail/mail.module';
import { AuthModule } from './modules/auth/auth.module';
import { MediaModule } from './modules/media/media.module';
import { SitterProfileModule } from './modules/sitter-profile/sitter-profile.module';
import { SitterServicesModule } from './modules/sitter-services/sitter-services.module';
import { SitterMeModule } from './modules/sitter-me/sitter-me.module';
import { SittersModule } from './modules/sitters/sitters.module';
import { AddressesModule } from './modules/addresses/addresses.module';
import { PetsModule } from './modules/pets/pets.module';

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
        connection: {
          host: config.get<string>('redis.host'),
          port: config.get<number>('redis.port'),
        },
      }),
    }),
    PrismaModule,
    RedisModule,
    MailModule,
    AuthModule,
    MediaModule,
    SitterProfileModule,
    SitterServicesModule,
    SitterMeModule,
    SittersModule,
    AddressesModule,
    PetsModule,
  ],
  controllers: [AppController],
  providers: [AppService],
})
export class AppModule {}
