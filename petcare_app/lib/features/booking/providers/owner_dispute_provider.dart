import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petcare_app/features/booking/data/owner_dispute.dart';
import 'package:petcare_app/features/booking/services/bookings_api_service.dart';

final hoSoKhieuNaiChuNuoiProvider = FutureProvider.autoDispose
    .family<HoSoKhieuNaiChuNuoi, String>(
      (ref, ma) => BookingsApiService().hoSoKhieuNai(ma),
    );
