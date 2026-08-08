import 'package:petcare_app/shared/data/sitter_profile.dart';
import 'package:petcare_app/shared/data/sitter_services.dart';

// Tham số mở một trang đặt lịch
class BookingArgs {
  const BookingArgs({required this.sitter, required this.loai});

  final SitterProfile sitter;
  final ServiceType loai;
}
