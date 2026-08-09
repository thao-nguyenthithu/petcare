import { Injectable, Logger, OnApplicationBootstrap } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { SystemSettingsService } from '../../admin/system-settings.service';
import { AutoGateway } from './auto.gateway';
import { MockGateway } from './mock.gateway';
import { PaymentGateway } from './payment-gateway.interface';
import { VnpayGateway } from './vnpay.gateway';

@Injectable()
export class PaymentGatewayResolver implements OnApplicationBootstrap {
  private readonly logger = new Logger(PaymentGatewayResolver.name);
  private readonly congKhiBat: PaymentGateway;

  constructor(
    config: ConfigService,
    private readonly settings: SystemSettingsService,
    private readonly auto: AutoGateway,
    mock: MockGateway,
    vnpay: VnpayGateway,
  ) {
    this.congKhiBat =
      config.get<string>('payment.gateway') === 'mock' ? mock : vnpay;
  }

  async onApplicationBootstrap() {
    const cong = await this.cong();
    if (process.env.NODE_ENV === 'production' && cong.ten === 'auto') {
      this.logger.warn(
        'Công tắc payment.vnpay.enabled đang TẮT nên mọi đơn tự chốt là đã trả tiền, bật ở màn quản trị 15',
      );
    }
  }

  async cong(): Promise<PaymentGateway> {
    return this.settings.batVnpay() ? this.congKhiBat : this.auto;
  }

  // Route giả lập chỉ được sống khi cổng đang là mock, không thì nó là cửa hậu
  async dangGiaLap(): Promise<boolean> {
    const cong = await this.cong();
    return cong.ten === 'mock';
  }
}
