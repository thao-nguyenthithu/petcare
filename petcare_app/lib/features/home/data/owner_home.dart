import 'package:petcare_app/core/utils/vn_date.dart';
import 'package:petcare_app/shared/data/service_catalog.dart';

LoaiDichVu _loai(String? ma) => switch (ma) {
  'boarding' => LoaiDichVu.trongGiu,
  'grooming' => LoaiDichVu.catTia,
  _ => LoaiDichVu.datDiDao,
};

class DonDangChay {
  const DonDangChay({
    required this.id,
    required this.code,
    required this.serviceName,
    required this.serviceType,
    required this.sitterName,
    required this.sitterAvatar,
    required this.petNames,
    required this.remainingMinutes,
    this.progress,
  });

  factory DonDangChay.fromJson(Map<String, dynamic> j) => DonDangChay(
    id: j['id'] as String,
    code: j['code'] as String? ?? '',
    serviceName: j['serviceName'] as String? ?? '',
    serviceType: _loai(j['serviceType'] as String?),
    sitterName: j['sitterName'] as String? ?? '',
    sitterAvatar: j['sitterAvatar'] as String? ?? '',
    petNames: [
      for (final e in (j['petNames'] as List? ?? const [])) e as String,
    ],
    remainingMinutes: (j['remainingMinutes'] as num?)?.toInt() ?? 0,
    progress: (j['progress'] as num?)?.toDouble(),
  );

  final String id;
  final String code;
  final String serviceName;
  final LoaiDichVu serviceType;
  final String sitterName;
  final String sitterAvatar;
  final List<String> petNames;
  final int remainingMinutes;
  final double? progress;
}

class NguoiChamDaDat {
  const NguoiChamDaDat({
    required this.sitterId,
    required this.name,
    required this.avatar,
    required this.serviceType,
    required this.rating,
    required this.totalReviews,
    required this.timesBooked,
  });

  factory NguoiChamDaDat.fromJson(Map<String, dynamic> j) => NguoiChamDaDat(
    sitterId: j['sitterId'] as String,
    name: j['name'] as String? ?? '',
    avatar: j['avatar'] as String? ?? '',
    serviceType: _loai(j['serviceType'] as String?),
    rating: ((j['rating'] as num?) ?? 0).toDouble(),
    totalReviews: (j['totalReviews'] as num?)?.toInt() ?? 0,
    timesBooked: (j['timesBooked'] as num?)?.toInt() ?? 0,
  );

  final String sitterId;
  final String name;
  final String avatar;
  final LoaiDichVu serviceType;
  final double rating;
  final int totalReviews;
  final int timesBooked;
}

class TrangChuChuNuoi {
  const TrangChuChuNuoi({
    required this.donDangChay,
    required this.nguoiChamDaDat,
  });

  factory TrangChuChuNuoi.fromJson(Map<String, dynamic> j) => TrangChuChuNuoi(
    donDangChay: [
      for (final e in (j['activeOrders'] as List? ?? const []))
        DonDangChay.fromJson(Map<String, dynamic>.from(e as Map)),
    ],
    nguoiChamDaDat: [
      for (final e in (j['recentSitters'] as List? ?? const []))
        NguoiChamDaDat.fromJson(Map<String, dynamic>.from(e as Map)),
    ],
  );

  final List<DonDangChay> donDangChay;
  final List<NguoiChamDaDat> nguoiChamDaDat;
}

DateTime bayGioVn() => nowVn();
