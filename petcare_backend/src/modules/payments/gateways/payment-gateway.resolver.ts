import { Injectable } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { SystemSettingsService } from '../../admin/system-settings.service';
import { AutoGateway } from './auto.gateway';
import { MockGateway } from './mock.gateway';
import { PaymentGateway } from './payment-gateway.interface';
import { VnpayGateway } from './vnpay.gateway';

@Injectable()
export class PaymentGatewayResolver {
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

  async cong(): Promise<PaymentGateway> {
    return this.settings.batVnpay() ? this.congKhiBat : this.auto;
  }

  // Route giả lập chỉ được sống khi cổng đang là mock, không thì nó là cửa hậu
  async dangGiaLap(): Promise<boolean> {
    const cong = await this.cong();
    return cong.ten === 'mock';
  }
}
