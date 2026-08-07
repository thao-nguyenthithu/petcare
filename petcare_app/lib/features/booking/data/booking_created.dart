import 'package:petcare_app/core/utils/vn_date.dart';
import 'package:petcare_app/shared/data/sitter_services.dart';

// Đơn vừa được server tạo
class BookingCreated {
  const BookingCreated({
    required this.id,
    required this.code,
    required this.status,
    required this.loai,
    required this.batDau,
    required this.tongTien,
    this.ketThuc,
    this.thoiLuongPhut,
    this.soDem,
    this.taoLuc,
    this.hetHanTraTien,
  });

  final String id;
  final String code;
  final String status;
  final ServiceType loai;
  final DateTime batDau;
  final DateTime? ketThuc;
  final int tongTien;
  final int? thoiLuongPhut;
  final int? soDem;
  final DateTime? taoLuc;
  final DateTime? hetHanTraTien;

  factory BookingCreated.fromJson(Map<String, dynamic> json) => BookingCreated(
    id: json['id'] as String,
    code: json['code'] as String,
    status: (json['status'] as String?) ?? 'PENDING',
    loai: _loaiTuApi(json['serviceType'] as String?),
    batDau: docMocVn(json['scheduledAt'] as String?) ?? nowVn(),
    ketThuc: docMocVn(json['scheduledEndAt'] as String?),
    tongTien: ((json['totalPrice'] as num?) ?? 0).round(),
    thoiLuongPhut: (json['durationMinutes'] as num?)?.toInt(),
    soDem: (json['nights'] as num?)?.toInt(),
    taoLuc: docMocVn(json['createdAt'] as String?),
    hetHanTraTien: docMocVn(json['paymentExpiresAt'] as String?),
  );
}

ServiceType _loaiTuApi(String? s) => switch (s) {
  'boarding' => ServiceType.boarding,
  'grooming' => ServiceType.grooming,
  _ => ServiceType.walking,
};
