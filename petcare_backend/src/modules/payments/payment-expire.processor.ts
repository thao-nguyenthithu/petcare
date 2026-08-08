import { OnWorkerEvent, Processor, WorkerHost } from '@nestjs/bullmq';
import { Logger } from '@nestjs/common';
import { Job } from 'bullmq';
import { PaymentsService } from './payments.service';
import {
  PAYMENT_QUEUE,
  VIEC_HET_HAN_GIU_CHO,
  ViecHetHanGiuCho,
} from './payments.constants';

@Processor(PAYMENT_QUEUE)
export class PaymentExpireProcessor extends WorkerHost {
  private readonly logger = new Logger(PaymentExpireProcessor.name);

  constructor(private readonly payments: PaymentsService) {
    super();
  }

  async process(job: Job<ViecHetHanGiuCho>) {
    if (job.name !== VIEC_HET_HAN_GIU_CHO) return;
    await this.payments.huyGiuCho(job.data.bookingId);
  }

  @OnWorkerEvent('failed')
  onFailed(job: Job<ViecHetHanGiuCho>, error: Error) {
    if (job.attemptsMade >= (job.opts.attempts ?? 1)) {
      this.logger.error(
        `Không dọn được đơn giữ chỗ ${job.data.bookingId}: ${error.message}`,
      );
    }
  }
}
