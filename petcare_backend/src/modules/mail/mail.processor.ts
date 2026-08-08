import { OnWorkerEvent, Processor, WorkerHost } from '@nestjs/bullmq';
import { Logger, OnModuleInit } from '@nestjs/common';
import { Job } from 'bullmq';
import * as nodemailer from 'nodemailer';
import { MAIL_QUEUE, OtpMailJob } from './mail.service';
import { ConfigService } from '@nestjs/config';

// Worker BullMQ gửi email OTP qua Gmail SMTP
@Processor(MAIL_QUEUE)
export class MailProcessor extends WorkerHost implements OnModuleInit {
  private readonly logger = new Logger(MailProcessor.name);
  private readonly transporter: nodemailer.Transporter;
  private readonly mailUser: string;
  private readonly mailAppPassword: string;

  constructor(config: ConfigService) {
    super();
    this.mailUser = config.get<string>('mail.user') ?? '';
    this.mailAppPassword = config.get<string>('mail.appPassword') ?? '';
    this.transporter = nodemailer.createTransport({
      service: 'gmail',
      auth: {
        user: this.mailUser,
        pass: this.mailAppPassword,
      },
    });
  }

  async onModuleInit() {
    if (!this.mailUser || !this.mailAppPassword) {
      this.logger.warn(
        'Thiếu MAIL_USER hoặc MAIL_APP_PASSWORD, tính năng gửi email OTP sẽ không hoạt động',
      );
      return;
    }
    try {
      await this.transporter.verify();
      this.logger.log(`Gmail SMTP sẵn sàng với tài khoản ${this.mailUser}`);
    } catch (error) {
      this.logger.error(
        `Không đăng nhập được Gmail SMTP với ${this.mailUser}: ${(error as Error).message}. Tạo lại App Password tại https://myaccount.google.com/apppasswords rồi cập nhật MAIL_APP_PASSWORD trong .env`,
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

    await this.transporter.sendMail({
      from: `"Smart Pet Care" <${this.mailUser}>`,
      to,
      subject,
      html: `
        <div style="font-family:Arial,sans-serif;max-width:480px;margin:0 auto">
          <h2 style="color:#2D8A6E">Smart Pet Care</h2>
          <p>${dongMoTa}</p>
          <p style="font-size:32px;font-weight:bold;letter-spacing:8px;color:#1A1A1A">${otp}</p>
          <p style="color:#6B7280">Mã có hiệu lực trong 5 phút. Nếu không phải bạn yêu cầu, hãy bỏ qua email này.</p>
        </div>
      `,
    });
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
