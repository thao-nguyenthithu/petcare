import { BadRequestException, Injectable } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import * as crypto from 'crypto';
import { LECH_VN_MS } from '../../../common/thoi-gian-vn';
import {
  KetQuaCong,
  PaymentGateway,
  PhienTraTien,
} from './payment-gateway.interface';

const HE_SO_TIEN = 100;
const MA_THANH_CONG = '00';
@Injectable()
export class VnpayGateway implements PaymentGateway {
  readonly ten = 'vnpay';

  private readonly tmnCode: string;
  private readonly hashSecret: string;
  private readonly payUrl: string;
  private readonly returnUrl: string;

  constructor(config: ConfigService) {
    this.tmnCode = config.get<string>('payment.vnpay.tmnCode') ?? '';
    this.hashSecret = config.get<string>('payment.vnpay.hashSecret') ?? '';
    this.payUrl = config.get<string>('payment.vnpay.payUrl') ?? '';
    this.returnUrl = config.get<string>('payment.vnpay.returnUrl') ?? '';
  }

  taoPhien(p: {
    txnRef: string;
    soTien: number;
    moTa: string;
    ip: string;
    hetHan: Date;
  }): PhienTraTien {
    if (!this.tmnCode || !this.hashSecret) {
      throw new BadRequestException({
        code: 'THIEU_CAU_HINH_CONG',
        message: 'Chưa cấu hình VNPay, tạm thời chưa thanh toán được',
      });
    }
    const thamSo: Record<string, string> = {
      vnp_Version: '2.1.0',
      vnp_Command: 'pay',
      vnp_TmnCode: this.tmnCode,
      vnp_Amount: String(p.soTien * HE_SO_TIEN),
      vnp_CurrCode: 'VND',
      vnp_TxnRef: p.txnRef,
      vnp_OrderInfo: p.moTa,
      vnp_OrderType: 'other',
      vnp_Locale: 'vn',
      vnp_ReturnUrl: this.returnUrl,
      vnp_IpAddr: p.ip,
      vnp_CreateDate: dinhDangMocVnpay(new Date()),
      vnp_ExpireDate: dinhDangMocVnpay(p.hetHan),
    };
    const chuoi = chuoiDaSapXep(thamSo);
    const chuKy = this.ky(chuoi);
    return { payUrl: `${this.payUrl}?${chuoi}&vnp_SecureHash=${chuKy}` };
  }

  docKetQua(query: Record<string, string>): KetQuaCong {
    const nhan = query.vnp_SecureHash ?? '';
    const conLai: Record<string, string> = {};
    for (const [k, v] of Object.entries(query)) {
      if (k === 'vnp_SecureHash' || k === 'vnp_SecureHashType') continue;
      conLai[k] = v;
    }
    const mong = this.ky(chuoiDaSapXep(conLai));
    if (!bangNhauAnToan(nhan, mong)) {
      throw new BadRequestException({
        code: 'CHU_KY_KHONG_HOP_LE',
        message: 'Chữ ký của cổng thanh toán không hợp lệ',
      });
    }
    const maPhanHoi = query.vnp_ResponseCode ?? null;
    const trangThai = query.vnp_TransactionStatus ?? null;
    return {
      txnRef: query.vnp_TxnRef ?? '',
      thanhCong: maPhanHoi === MA_THANH_CONG && trangThai === MA_THANH_CONG,
      soTien: Number(query.vnp_Amount ?? '0') / HE_SO_TIEN,
      maGiaoDich: query.vnp_TransactionNo ?? null,
      ngayTraCong: query.vnp_PayDate ?? null,
      bankCode: query.vnp_BankCode ?? null,
      cardType: query.vnp_CardType ?? null,
      maPhanHoi,
      duLieuGoc: query,
    };
  }

  private ky(chuoi: string): string {
    return crypto
      .createHmac('sha512', this.hashSecret)
      .update(Buffer.from(chuoi, 'utf-8'))
      .digest('hex');
  }
}

function chuoiDaSapXep(thamSo: Record<string, string>): string {
  return Object.keys(thamSo)
    .filter((k) => thamSo[k] !== undefined && thamSo[k] !== '')
    .sort()
    .map((k) => `${maHoa(k)}=${maHoa(thamSo[k])}`)
    .join('&');
}

function maHoa(s: string): string {
  return encodeURIComponent(s).replace(/%20/g, '+');
}

export function dinhDangMocVnpay(d: Date): string {
  const vn = new Date(d.getTime() + LECH_VN_MS);
  const hai = (n: number) => String(n).padStart(2, '0');
  return (
    `${vn.getUTCFullYear()}${hai(vn.getUTCMonth() + 1)}${hai(vn.getUTCDate())}` +
    `${hai(vn.getUTCHours())}${hai(vn.getUTCMinutes())}${hai(vn.getUTCSeconds())}`
  );
}

function bangNhauAnToan(a: string, b: string): boolean {
  const x = Buffer.from(a, 'utf-8');
  const y = Buffer.from(b, 'utf-8');
  return x.length === y.length && crypto.timingSafeEqual(x, y);
}
