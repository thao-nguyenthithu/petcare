import { Module } from '@nestjs/common';
import { PrismaModule } from '../../../prisma/prisma.module';
import { BookingsModule } from '../../bookings/bookings.module';
import { SittersController } from './sitters.controller';
import { SittersService } from './sitters.service';

@Module({
  imports: [PrismaModule, BookingsModule],
  controllers: [SittersController],
  providers: [SittersService],
})
export class SittersModule {}
