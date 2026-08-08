import { Injectable } from '@nestjs/common';
import { maGiaoDichGia } from './ma-giao-dich-gia';
import { dinhDangMocVnpay } from './vnpay.gateway';
import {
  KetQuaCong,
  PaymentGateway,
  PhienTraTien,
} from './payment-gateway.interface';

const NGAN_HANG = 'NCB';
const LOAI_THE = 'ATM';

@Injectable()
export class AutoGateway implements PaymentGateway {
  readonly ten = 'auto';
  readonly tuDongChot = true;

  taoPhien(): PhienTraTien {
    return { payUrl: '' };
  }

  docKetQua(query: Record<string, string>): KetQuaCong {
    return {
      txnRef: query.txnRef ?? '',
      thanhCong: true,
      soTien: Number(query.soTien ?? '0'),
      maGiaoDich: maGiaoDichGia(query.txnRef ?? ''),
      ngayTraCong: dinhDangMocVnpay(new Date()),
      bankCode: NGAN_HANG,
      cardType: LOAI_THE,
      maPhanHoi: '00',
      duLieuGoc: query,
    };
  }
}
