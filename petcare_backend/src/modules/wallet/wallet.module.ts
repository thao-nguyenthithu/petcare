import { Module } from '@nestjs/common';
import { MediaModule } from '../media/media.module';
import { MessagingModule } from '../messaging/messaging.module';
import { DisputeService } from './dispute.service';
import { DisputesController } from './disputes.controller';
import { EarningsService } from './earnings.service';
import { EscrowReleaseJob } from './escrow-release.job';
import { WalletController, EarningsController } from './wallet.controller';
import { WalletLedgerService } from './wallet-ledger.service';
import { WalletTransactionsService } from './wallet-transactions.service';
import { WalletService } from './wallet.service';
import { WithdrawalService } from './withdrawal.service';

@Module({
  imports: [MessagingModule, MediaModule],
  controllers: [WalletController, EarningsController, DisputesController],
  providers: [
    WalletService,
    WalletLedgerService,
    WalletTransactionsService,
    WithdrawalService,
    EarningsService,
    DisputeService,
    EscrowReleaseJob,
  ],
  exports: [WalletLedgerService, DisputeService],
})
export class WalletModule {}
