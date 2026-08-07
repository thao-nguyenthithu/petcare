import 'dart:async';

import 'package:petcare_app/features/booking/data/owner_booking.dart';
import 'package:petcare_app/features/booking/services/bookings_api_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'owner_bookings_provider.g.dart';

// Danh sách đơn của chủ nuôi theo từng tab
@riverpod
class OwnerBookings extends _$OwnerBookings {
  final _service = BookingsApiService();

  static const int _moiTrang = 20;

  @override
  Future<TrangDonCuaToi> build(
    BookingStatus tab,
    PetServiceType? loai,
    String tuKhoa,
  ) {
    final giuCache = ref.keepAlive();
    final hen = Timer(const Duration(seconds: 60), giuCache.close);
    ref.onDispose(() {
      hen.cancel();
      giuCache.close();
    });
    return _goi(1);
  }

  Future<TrangDonCuaToi> _goi(int trang) => _service.danhSachCuaToi(
    tab: tab,
    loai: loai,
    tuKhoa: tuKhoa,
    page: trang,
    limit: _moiTrang,
  );

  Future<void> taiThem() async {
    final hienTai = state.asData?.value;
    if (hienTai == null || !hienTai.conTrangSau || hienTai.dangTaiThem) return;
    state = AsyncData(hienTai.copyWith(dangTaiThem: true));
    try {
      final tiep = await _goi(hienTai.page + 1);
      state = AsyncData(hienTai.noiThem(tiep));
    } catch (_) {
      state = AsyncData(hienTai.copyWith(dangTaiThem: false));
    }
  }
}
