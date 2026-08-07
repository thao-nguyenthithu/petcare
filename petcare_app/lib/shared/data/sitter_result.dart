import 'package:latlong2/latlong.dart';
import 'package:petcare_app/shared/data/service_catalog.dart';

// Một người chăm trong danh sách trả về từ GET /search/sitters
class SitterResult {
  const SitterResult({
    required this.id,
    required this.name,
    required this.loai,
    required this.rating,
    required this.soDanhGia,
    required this.soDonHoanThanh,
    this.avatarUrl,
    this.anhDichVu,
    this.khuVuc,
    this.gia,
    this.khoangCachKm,
    this.viTri,
    this.tinCay = false,
    this.soNgayNhan = 0,
  });

  factory SitterResult.fromJson(Map<String, dynamic> json) {
    final lat = (json['lat'] as num?)?.toDouble();
    final lng = (json['lng'] as num?)?.toDouble();
    final loaiDs = (json['serviceTypes'] as List?)?.cast<String>() ?? const [];
    return SitterResult(
      id: json['id'] as String,
      name: (json['fullName'] as String?) ?? '',
      avatarUrl: json['avatarUrl'] as String?,
      anhDichVu: json['photoUrl'] as String?,
      loai: _loaiTuMa(loaiDs.isEmpty ? null : loaiDs.first),
      khuVuc: json['area'] as String?,
      rating: (json['ratingAvg'] as num?)?.toDouble() ?? 0,
      soDanhGia: (json['totalReviews'] as num?)?.toInt() ?? 0,
      soDonHoanThanh: (json['completedOrders'] as num?)?.toInt() ?? 0,
      gia: (json['priceFrom'] as num?)?.toInt(),
      khoangCachKm: (json['distanceKm'] as num?)?.toDouble(),
      viTri: lat != null && lng != null ? LatLng(lat, lng) : null,
      tinCay: (json['trusted'] as bool?) ?? false,
      soNgayNhan: (json['availableDays'] as num?)?.toInt() ?? 0,
    );
  }

  final String id;
  final String name;
  final String? avatarUrl;
  final String? anhDichVu;
  final LoaiDichVu loai;
  final String? khuVuc;
  final double rating;
  final int soDanhGia;
  final int soDonHoanThanh;
  final int? gia;
  final double? khoangCachKm;
  final LatLng? viTri;
  final bool tinCay;
  final int soNgayNhan;

  static LoaiDichVu _loaiTuMa(String? ma) => switch (ma) {
    'boarding' => LoaiDichVu.trongGiu,
    'grooming' => LoaiDichVu.catTia,
    _ => LoaiDichVu.datDiDao,
  };
}

// Một trang kết quả
class TrangKetQuaTim {
  const TrangKetQuaTim({
    required this.items,
    required this.total,
    required this.page,
    required this.limit,
    this.dangTaiThem = false,
  });

  factory TrangKetQuaTim.fromJson(Map<String, dynamic> json) => TrangKetQuaTim(
    items: [
      for (final e in (json['items'] as List? ?? const []))
        SitterResult.fromJson(Map<String, dynamic>.from(e as Map)),
    ],
    total: (json['total'] as num?)?.toInt() ?? 0,
    page: (json['page'] as num?)?.toInt() ?? 1,
    limit: (json['limit'] as num?)?.toInt() ?? 20,
  );

  final List<SitterResult> items;
  final int total;
  final int page;
  final int limit;
  final bool dangTaiThem;

  bool get conTrangSau => page * limit < total;

  TrangKetQuaTim copyWith({bool? dangTaiThem}) => TrangKetQuaTim(
    items: items,
    total: total,
    page: page,
    limit: limit,
    dangTaiThem: dangTaiThem ?? this.dangTaiThem,
  );

  TrangKetQuaTim noiThem(TrangKetQuaTim tiep) => TrangKetQuaTim(
    items: [...items, ...tiep.items],
    total: tiep.total,
    page: tiep.page,
    limit: tiep.limit,
  );
}
