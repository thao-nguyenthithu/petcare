import { Injectable } from '@nestjs/common';
import {
  KetQuaCong,
  PaymentGateway,
  PhienTraTien,
} from './payment-gateway.interface';
import { maGiaoDichGia } from './ma-giao-dich-gia';
import { dinhDangMocVnpay } from './vnpay.gateway';

@Injectable()
export class MockGateway implements PaymentGateway {
  readonly ten = 'mock';

  taoPhien(p: { txnRef: string; soTien: number }): PhienTraTien {
    return {
      payUrl: `mock://payment?txnRef=${encodeURIComponent(p.txnRef)}&soTien=${p.soTien}`,
    };
  }

  docKetQua(query: Record<string, string>): KetQuaCong {
    const thanhCong = query.ketQua === 'success';
    return {
      txnRef: query.txnRef ?? '',
      thanhCong,
      soTien: Number(query.soTien ?? '0'),
      maGiaoDich: thanhCong ? maGiaoDichGia(query.txnRef ?? '') : null,
      ngayTraCong: thanhCong ? dinhDangMocVnpay(new Date()) : null,
      bankCode: thanhCong ? 'NCB' : null,
      cardType: thanhCong ? 'ATM' : null,
      maPhanHoi: thanhCong ? '00' : '24',
      duLieuGoc: query,
    };
  }
}
