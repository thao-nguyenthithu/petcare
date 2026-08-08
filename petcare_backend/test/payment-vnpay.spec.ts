import { ConfigService } from '@nestjs/config';
import * as crypto from 'crypto';
import {
  PHUT_GIU_CHO_TRA_TIEN,
  hanGiuCho,
  mocGuiNguoiCham,
} from '../src/modules/bookings/booking-time';
import { chuyenDuoc } from '../src/modules/bookings/booking-state';
import { AutoGateway } from '../src/modules/payments/gateways/auto.gateway';
import { MockGateway } from '../src/modules/payments/gateways/mock.gateway';
import { PaymentGateway } from '../src/modules/payments/gateways/payment-gateway.interface';
import {
  VnpayGateway,
  dinhDangMocVnpay,
} from '../src/modules/payments/gateways/vnpay.gateway';

// Ba chỗ dễ sai khi nối cổng: giờ VN, chuỗi đem ký, mốc giữ chỗ — cổng từ chối mà không nói lý do

const BI_MAT = 'BIMATTHUNGHIEM';

function congThuNghiem(): VnpayGateway {
  const gia = {
    get: (khoa: string) =>
      ({
        'payment.vnpay.tmnCode': 'PETCARE1',
        'payment.vnpay.hashSecret': BI_MAT,
        'payment.vnpay.payUrl': 'https://sandbox.vnpayment.vn/pay',
        'payment.vnpay.returnUrl': 'http://localhost:3000/api/v1/return',
      })[khoa],
  } as unknown as ConfigService;
  return new VnpayGateway(gia);
}

// Ký lại đúng cách cổng ký, để dựng payload giả mà không phải chép tay chuỗi
function kyNhu(thamSo: Record<string, string>): string {
  const chuoi = Object.keys(thamSo)
    .filter((k) => thamSo[k] !== '')
    .sort()
    .map(
      (k) =>
        `${encodeURIComponent(k).replace(/%20/g, '+')}=${encodeURIComponent(thamSo[k]).replace(/%20/g, '+')}`,
    )
    .join('&');
  return crypto.createHmac('sha512', BI_MAT).update(chuoi).digest('hex');
}

describe('định dạng mốc giờ gửi VNPay', () => {
  it('luôn là giờ Việt Nam, không phải giờ máy chủ', () => {
    // 03:30 UTC là 10:30 giờ VN cùng ngày
    const moc = new Date('2026-08-06T03:30:15.000Z');
    expect(dinhDangMocVnpay(moc)).toBe('20260806103015');
  });

  it('cộng lệch qua nửa đêm thì sang ngày hôm sau', () => {
    // 18:00 UTC ngày 06 là 01:00 giờ VN ngày 07
    const moc = new Date('2026-08-06T18:00:00.000Z');
    expect(dinhDangMocVnpay(moc)).toBe('20260807010000');
  });
});

describe('phiên trả tiền VNPay', () => {
  it('nhân tiền 100 lần và ký đúng chuỗi mình gửi đi', () => {
    const cong = congThuNghiem();
    const { payUrl } = cong.taoPhien({
      txnRef: 'PCABC123',
      soTien: 150000,
      moTa: 'Thanh toan don PCABC123',
      ip: '127.0.0.1',
      hetHan: new Date('2026-08-06T03:40:00.000Z'),
    });
    const url = new URL(payUrl);
    expect(url.searchParams.get('vnp_Amount')).toBe('15000000');
    expect(url.searchParams.get('vnp_TxnRef')).toBe('PCABC123');
    expect(url.searchParams.get('vnp_ExpireDate')).toBe('20260806104000');

    // Ký trên CHÍNH chuỗi nằm trên URL: lệch một dấu cách là cổng từ chối
    const chuoi = payUrl.split('?')[1];
    const viTri = chuoi.indexOf('&vnp_SecureHash=');
    const phanKy = chuoi.slice(0, viTri);
    const chuKy = chuoi.slice(viTri + '&vnp_SecureHash='.length);
    expect(
      crypto.createHmac('sha512', BI_MAT).update(phanKy).digest('hex'),
    ).toBe(chuKy);
  });

  it('mô tả có dấu cách thì mã hoá thành dấu cộng, không phải %20', () => {
    const cong = congThuNghiem();
    const { payUrl } = cong.taoPhien({
      txnRef: 'PCXYZ789',
      soTien: 1000,
      moTa: 'Thanh toan don PCXYZ789',
      ip: '127.0.0.1',
      hetHan: new Date('2026-08-06T03:40:00.000Z'),
    });
    expect(payUrl).toContain('vnp_OrderInfo=Thanh+toan+don+PCXYZ789');
    expect(payUrl).not.toContain('%20');
  });
});

describe('đọc kết quả cổng trả về', () => {
  const thamSoDung = {
    vnp_Amount: '15000000',
    vnp_BankCode: 'NCB',
    vnp_CardType: 'ATM',
    vnp_PayDate: '20260806104530',
    vnp_ResponseCode: '00',
    vnp_TmnCode: 'PETCARE1',
    vnp_TransactionNo: '14257845',
    vnp_TransactionStatus: '00',
    vnp_TxnRef: 'PCABC123',
  };

  it('giữ NGUYÊN VĂN vnp_PayDate vì lệnh hoàn tiền sau này cần đúng chuỗi đó', () => {
    const cong = congThuNghiem();
    const ket = cong.docKetQua({
      ...thamSoDung,
      vnp_SecureHash: kyNhu(thamSoDung),
    });
    expect(ket.thanhCong).toBe(true);
    expect(ket.soTien).toBe(150000);
    expect(ket.ngayTraCong).toBe('20260806104530');
    expect(ket.maGiaoDich).toBe('14257845');
  });

  it('ném lỗi khi chữ ký sai, không đọc lấy một tham số nào', () => {
    const cong = congThuNghiem();
    expect(() =>
      cong.docKetQua({ ...thamSoDung, vnp_SecureHash: 'a'.repeat(128) }),
    ).toThrow();
  });

  it('chỉ mã giao dịch đúng thôi chưa đủ, trạng thái cũng phải 00', () => {
    const cong = congThuNghiem();
    const hong = { ...thamSoDung, vnp_TransactionStatus: '02' };
    const ket = cong.docKetQua({ ...hong, vnp_SecureHash: kyNhu(hong) });
    expect(ket.thanhCong).toBe(false);
  });
});

describe('cổng giả lập', () => {
  it('sinh mã giao dịch và mốc giờ ĐÚNG ĐỊNH DẠNG cổng thật', () => {
    const cong = new MockGateway();
    const ket = cong.docKetQua({
      txnRef: 'PCABC123',
      ketQua: 'success',
      soTien: '150000',
    });
    expect(ket.thanhCong).toBe(true);
    expect(ket.soTien).toBe(150000);
    // Tầng dưới không được phép biết mình đang chạy cổng nào
    expect(ket.maGiaoDich).toMatch(/^\d{8}$/);
    expect(ket.ngayTraCong).toMatch(/^\d{14}$/);
  });

  it('nhánh thất bại không sinh mã giao dịch', () => {
    const cong = new MockGateway();
    const ket = cong.docKetQua({ txnRef: 'PCABC123', ketQua: 'fail' });
    expect(ket.thanhCong).toBe(false);
    expect(ket.maGiaoDich).toBeNull();
    expect(ket.ngayTraCong).toBeNull();
  });
});

describe('giữ chỗ chờ trả tiền', () => {
  it('hạn tính từ lúc tạo đơn nên thử lại không gia hạn thêm', () => {
    const taoLuc = new Date('2026-08-06T03:00:00.000Z');
    expect(hanGiuCho(taoLuc).toISOString()).toBe('2026-08-06T03:10:00.000Z');
    expect(PHUT_GIU_CHO_TRA_TIEN).toBe(10);
  });

  it('hạn nhận đơn đếm từ lúc trả tiền, không phải lúc bấm Thanh toán', () => {
    const taoLuc = new Date('2026-08-06T03:00:00.000Z');
    const traLuc = new Date('2026-08-06T03:07:00.000Z');
    expect(mocGuiNguoiCham({ createdAt: taoLuc, paidAt: traLuc })).toBe(traLuc);
    // Đơn cũ thiếu paidAt vẫn phải lùi về createdAt chứ không rơi vào null
    expect(mocGuiNguoiCham({ createdAt: taoLuc, paidAt: null })).toBe(taoLuc);
  });

  it('đơn giữ chỗ chỉ đi được sang chờ nhận hoặc chết vì không trả tiền', () => {
    expect(chuyenDuoc('AWAITING_PAYMENT', 'PENDING')).toBe(true);
    expect(chuyenDuoc('AWAITING_PAYMENT', 'CANCELLED_UNPAID')).toBe(true);
    // Chưa trả tiền thì người chăm không nhận được, càng không bắt đầu được
    expect(chuyenDuoc('AWAITING_PAYMENT', 'CONFIRMED')).toBe(false);
    expect(chuyenDuoc('AWAITING_PAYMENT', 'IN_PROGRESS')).toBe(false);
    expect(chuyenDuoc('CANCELLED_UNPAID', 'PENDING')).toBe(false);
  });
});

describe('công tắc thu tiền của quản trị viên', () => {
  // Bản ghi cổng tự chốt thiếu mốc trả hay mã giao dịch là màn tiền phải rẽ nhánh theo cổng
  it('cổng tự chốt báo thành công ngay và giữ đúng hình dạng dữ liệu', () => {
    const cong = new AutoGateway();
    expect(cong.tuDongChot).toBe(true);
    const ket = cong.docKetQua({ txnRef: 'PCABC123XYZ', soTien: '150000' });
    expect(ket.thanhCong).toBe(true);
    expect(ket.soTien).toBe(150000);
    expect(ket.maPhanHoi).toBe('00');
    expect(ket.ngayTraCong).toMatch(/^\d{14}$/);
  });

  // Thiếu ngân hàng là màn hoàn tiền tụt xuống câu chung chung, thiếu mã đúng dạng là lộ đơn khác loại
  it('khoản tự chốt không phân biệt được với khoản trả thật trên màn', () => {
    const auto = new AutoGateway().docKetQua({
      txnRef: 'PCABC123XYZ',
      soTien: '150000',
    });
    const that = new MockGateway().docKetQua({
      txnRef: 'PCABC123XYZ',
      ketQua: 'success',
      soTien: '150000',
    });
    expect(auto.maGiaoDich).toMatch(/^\d{8}$/);
    expect(auto.maGiaoDich).toBe(that.maGiaoDich);
    expect(auto.bankCode).toBe(that.bankCode);
    expect(auto.cardType).toBe(that.cardType);
  });

  it('hai cổng thu tiền thật KHÔNG tự chốt', () => {
    // Đọc qua kiểu interface vì `tuDongChot` tuỳ chọn, hai lớp này cố ý không khai
    const mock: PaymentGateway = new MockGateway();
    const vnpay: PaymentGateway = congThuNghiem();
    expect(mock.tuDongChot).toBeUndefined();
    expect(vnpay.tuDongChot).toBeUndefined();
  });
});
