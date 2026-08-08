import 'package:petcare_app/core/utils/vn_date.dart';

// Cổng giả lập trả payUrl
const String luocDoCongGiaLap = 'mock://';

class PaymentSession {
  const PaymentSession({
    required this.payUrl,
    required this.txnRef,
    required this.hetHan,
    this.tuDongThanhCong = false,
  });

  final String payUrl;
  final String txnRef;
  final bool tuDongThanhCong;
  final DateTime hetHan;

  bool get quaCongGiaLap => payUrl.startsWith(luocDoCongGiaLap);

  factory PaymentSession.fromJson(Map<String, dynamic> json) => PaymentSession(
    payUrl: (json['payUrl'] as String?) ?? '',
    txnRef: json['txnRef'] as String,
    hetHan: docMocVn(json['expiresAt'] as String?) ?? nowVn(),
    tuDongThanhCong: (json['tuDongThanhCong'] as bool?) ?? false,
  );
}

enum KetCucTraTien { conCho, thanhCong, thatBai }

class PaymentStatus {
  const PaymentStatus({
    required this.ketCuc,
    required this.hetHan,
    this.trangThaiDon,
    this.txnRef,
    this.maGiaoDich,
  });

  final KetCucTraTien ketCuc;
  final DateTime hetHan;
  final String? trangThaiDon;
  final String? txnRef;
  final String? maGiaoDich;

  bool get donDaChet => trangThaiDon == 'CANCELLED_UNPAID';

  factory PaymentStatus.fromJson(Map<String, dynamic> json) {
    final trangThaiDon = json['bookingStatus'] as String?;
    final trangThaiTra = json['paymentStatus'] as String?;
    return PaymentStatus(
      ketCuc: _ketCuc(trangThaiDon, trangThaiTra),
      hetHan: docMocVn(json['expiresAt'] as String?) ?? nowVn(),
      trangThaiDon: trangThaiDon,
      txnRef: json['txnRef'] as String?,
      maGiaoDich: json['transactionNo'] as String?,
    );
  }
}

KetCucTraTien _ketCuc(String? trangThaiDon, String? trangThaiTra) {
  if (trangThaiDon == 'PENDING') return KetCucTraTien.thanhCong;
  if (trangThaiDon == 'CANCELLED_UNPAID') return KetCucTraTien.thatBai;
  if (trangThaiTra == 'FAILED' || trangThaiTra == 'EXPIRED') {
    return KetCucTraTien.thatBai;
  }
  return KetCucTraTien.conCho;
}
