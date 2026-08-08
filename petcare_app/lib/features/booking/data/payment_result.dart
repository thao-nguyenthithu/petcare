import 'package:petcare_app/features/booking/data/booking_created.dart';
import 'package:petcare_app/features/booking/data/booking_draft.dart';

// Tham số màn chờ thanh toán và màn kết quả
class PaymentResultArgs {
  const PaymentResultArgs({
    required this.draft,
    required this.thanhCong,
    required this.thoiDiem,
    this.don,
    this.maGiaoDich,
  });

  final BookingDraft draft;
  final bool thanhCong;
  final DateTime thoiDiem;

  final BookingCreated? don;

  final String? maGiaoDich;

  String? get maDon => thanhCong ? don?.code : null;

  DateTime? get hetHanGiuCho => don?.hetHanTraTien;
}
