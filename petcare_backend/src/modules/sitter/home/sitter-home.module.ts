import { Module } from '@nestjs/common';
import { BookingsModule } from '../../bookings/bookings.module';
import { WalletModule } from '../../wallet/wallet.module';
import {
  OwnerHomeController,
  SitterHomeController,
} from './sitter-home.controller';
import { OwnerHomeService } from './owner-home.service';
import { SitterHomeService } from './sitter-home.service';

@Module({
  imports: [WalletModule, BookingsModule],
  controllers: [SitterHomeController, OwnerHomeController],
  providers: [SitterHomeService, OwnerHomeService],
})
export class SitterHomeModule {}
