import 'package:petcare_app/features/booking/data/owner_booking_detail_api.dart';
import 'package:petcare_app/features/booking/providers/booking_refresh.dart';
import 'package:petcare_app/features/booking/services/bookings_api_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'owner_booking_detail_provider.g.dart';

// Chi tiết một đơn của chủ nuôi
@riverpod
class BookingDetail extends _$BookingDetail {
  final _service = BookingsApiService();

  @override
  Future<ChiTietDonApi> build(String bookingId) => _service.chiTiet(bookingId);

  Future<ChiTietDonApi> huy({required String lyDo, String moTa = ''}) async {
    final daHuy = await _service.huyDon(bookingId, lyDo: lyDo, moTa: moTa);
    state = AsyncData(daHuy);
    ref.refreshBookingData(boQua: [bookingDetailProvider]);
    return daHuy;
  }

  Future<void> xuatPhat() async {
    await _service.xuatPhat(bookingId);
    state = AsyncData(await _service.chiTiet(bookingId));
    ref.refreshBookingData(boQua: [bookingDetailProvider]);
  }

  Future<void> xacNhanHoanThanh() async {
    state = AsyncData(await _service.xacNhanHoanThanh(bookingId));
    ref.refreshBookingData(boQua: [bookingDetailProvider]);
  }
}
