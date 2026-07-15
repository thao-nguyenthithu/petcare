import { Injectable } from '@nestjs/common';
import { InjectQueue } from '@nestjs/bullmq';
import { Queue } from 'bullmq';

export const MAIL_QUEUE = 'mail';

export type OtpPurpose = 'verify' | 'reset';

export interface OtpMailJob {
  to: string;
  otp: string;
  purpose: OtpPurpose;
}

@Injectable()
export class MailService {
  constructor(@InjectQueue(MAIL_QUEUE) private readonly mailQueue: Queue) {}

  // Đẩy job gửi OTP vào queue, server không gửi email ngay trong luồng request, một tiến trình worker chạy nền mới lấy job ra và gửi email thật.
  async queueOtpEmail(to: string, otp: string, purpose: OtpPurpose) {
    await this.mailQueue.add(
      'send-otp',
      { to, otp, purpose } satisfies OtpMailJob,
      {
        attempts: 3,
        backoff: { type: 'exponential', delay: 3000 },
        removeOnComplete: true,
        removeOnFail: true,
      },
    );
  }
}
