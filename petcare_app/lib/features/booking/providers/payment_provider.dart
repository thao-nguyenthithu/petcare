import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petcare_app/features/booking/data/payment_session.dart';
import 'package:petcare_app/features/booking/providers/sitter_slots_provider.dart';
import 'package:petcare_app/features/booking/services/payments_api_service.dart';

// Thanh toán một đơn đang giữ chỗ
class PaymentNotifier extends Notifier<void> {
  final _api = PaymentsApiService();

  @override
  void build() {}

  Future<PaymentSession> moPhien(String bookingId) => _api.moPhien(bookingId);

  Future<PaymentStatus> trangThai(String bookingId) =>
      _api.trangThai(bookingId);

  Future<void> banCongGiaLap({
    required String txnRef,
    required bool thanhCong,
    required int soTien,
  }) =>
      _api.banCongGiaLap(txnRef: txnRef, thanhCong: thanhCong, soTien: soTien);

  // Bỏ giữ chỗ là nhả khung giờ ngay nên lịch đang giữ đã cũ
  Future<void> boGiuCho(
    String bookingId,
    String? sitterId,
    List<String> petIds,
  ) async {
    await _api.boGiuCho(bookingId);
    ref.invalidate(sitterSlotsProvider(khoaLichTrong(sitterId, petIds)));
  }
}

final paymentProvider = NotifierProvider<PaymentNotifier, void>(
  PaymentNotifier.new,
);
