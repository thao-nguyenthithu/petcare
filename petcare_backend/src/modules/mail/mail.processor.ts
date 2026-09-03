import { OnWorkerEvent, Processor, WorkerHost } from '@nestjs/bullmq';
import { Logger, OnModuleInit } from '@nestjs/common';
import { Job } from 'bullmq';
import { MAIL_QUEUE, OtpMailJob } from './mail.service';
import { ConfigService } from '@nestjs/config';

const BREVO_API = 'https://api.brevo.com/v3/smtp/email';

// Worker BullMQ gửi email OTP qua Brevo, Railway chặn mọi cổng SMTP nên không dùng được Gmail trực tiếp
@Processor(MAIL_QUEUE)
export class MailProcessor extends WorkerHost implements OnModuleInit {
  private readonly logger = new Logger(MailProcessor.name);
  private readonly mailUser: string;
  private readonly apiKey: string;

  constructor(config: ConfigService) {
    super();
    this.mailUser = config.get<string>('mail.user') ?? '';
    this.apiKey = config.get<string>('mail.brevoApiKey') ?? '';
  }

  async onModuleInit() {
    if (!this.mailUser || !this.apiKey) {
      this.logger.warn(
        'Thiếu MAIL_USER hoặc BREVO_API_KEY, tính năng gửi email OTP sẽ không hoạt động',
      );
      return;
    }
    try {
      const phanHoi = await fetch('https://api.brevo.com/v3/account', {
        headers: { 'api-key': this.apiKey },
      });
      if (!phanHoi.ok) {
        throw new Error(`HTTP ${phanHoi.status} ${await phanHoi.text()}`);
      }
      this.logger.log(`Brevo sẵn sàng, gửi dưới tên ${this.mailUser}`);
    } catch (error) {
      this.logger.error(
        `Không dùng được API Brevo: ${(error as Error).message}. Kiểm tra BREVO_API_KEY và trạng thái sender ${this.mailUser}`,
      );
    }
  }

  async process(job: Job<OtpMailJob>) {
    const { to, otp, purpose } = job.data;
    const subject =
      purpose === 'verify'
        ? 'Smart Pet Care - Mã xác minh email'
        : 'Smart Pet Care - Mã đặt lại mật khẩu';
    const dongMoTa =
      purpose === 'verify'
        ? 'Dùng mã dưới đây để xác minh email đăng ký tài khoản Smart Pet Care:'
        : 'Dùng mã dưới đây để đặt lại mật khẩu tài khoản Smart Pet Care:';

    const phanHoi = await fetch(BREVO_API, {
      method: 'POST',
      headers: {
        'api-key': this.apiKey,
        'content-type': 'application/json',
      },
      body: JSON.stringify({
        sender: { name: 'Smart Pet Care', email: this.mailUser },
        to: [{ email: to }],
        subject,
        htmlContent: `
        <div style="font-family:Arial,sans-serif;max-width:480px;margin:0 auto">
          <h2 style="color:#2D8A6E">Smart Pet Care</h2>
          <p>${dongMoTa}</p>
          <p style="font-size:32px;font-weight:bold;letter-spacing:8px;color:#1A1A1A">${otp}</p>
          <p style="color:#6B7280">Mã có hiệu lực trong 5 phút. Nếu không phải bạn yêu cầu, hãy bỏ qua email này.</p>
        </div>
      `,
      }),
    });

    if (!phanHoi.ok) {
      throw new Error(`Brevo trả ${phanHoi.status}: ${await phanHoi.text()}`);
    }
    this.logger.log(`Đã gửi email OTP (${purpose}) tới ${to}`);
  }

  // Job hết 3 lần retry
  @OnWorkerEvent('failed')
  onFailed(job: Job<OtpMailJob>, error: Error) {
    if (job.attemptsMade >= (job.opts.attempts ?? 1)) {
      this.logger.error(
        `Gửi email OTP tới ${job.data.to} thất bại: ${error.message}`,
      );
    }
  }
}
