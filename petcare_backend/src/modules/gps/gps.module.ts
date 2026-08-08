import { Module } from '@nestjs/common';
import { AuthModule } from '../auth/auth.module';
import { GpsController } from './gps.controller';
import { GpsGateway } from './gps.gateway';
import { GpsService } from './gps.service';

@Module({
  imports: [AuthModule],
  controllers: [GpsController],
  providers: [GpsGateway, GpsService],
  exports: [GpsService],
})
export class GpsModule {}
