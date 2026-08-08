import 'package:petcare_app/core/network/api_client.dart';
import 'package:petcare_app/features/booking/data/payment_session.dart';

class PaymentsApiService {
  // Mở phiên trả tiền cho đơn đang giữ chỗ
  Future<PaymentSession> moPhien(String bookingId) async {
    final res = await apiClient.post('/bookings/$bookingId/payment');
    return PaymentSession.fromJson(Map<String, dynamic>.from(res.data as Map));
  }

  Future<PaymentStatus> trangThai(String bookingId) async {
    final res = await apiClient.get('/bookings/$bookingId/payment');
    return PaymentStatus.fromJson(Map<String, dynamic>.from(res.data as Map));
  }

  Future<void> boGiuCho(String bookingId) async {
    await apiClient.delete('/bookings/$bookingId/payment');
  }

  Future<void> banCongGiaLap({
    required String txnRef,
    required bool thanhCong,
    required int soTien,
  }) async {
    await apiClient.post(
      '/payments/mock/$txnRef',
      data: {'ketQua': thanhCong ? 'success' : 'fail', 'soTien': soTien},
    );
  }
}
