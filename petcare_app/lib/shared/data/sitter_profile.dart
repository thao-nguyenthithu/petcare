import 'package:petcare_app/shared/data/sitter_service_area.dart';
import 'package:petcare_app/shared/data/sitter_services.dart';
import 'package:petcare_app/core/utils/vn_date.dart';

const maxSitterPhotos = 50;

// Một ảnh trong thư viện NCC
class SitterPhotoItem {
  final String id;
  final String url;
  final DateTime? ngayThem;

  const SitterPhotoItem({required this.id, required this.url, this.ngayThem});

  factory SitterPhotoItem.fromJson(Map<String, dynamic> j) => SitterPhotoItem(
    id: j['id'] as String,
    url: j['url'] as String,
    ngayThem: docMocVn(j['createdAt'] as String?),
  );
}

// Hồ sơ NCC
class SitterProfile {
  final String? id;
  final String fullName;
  final String? email;
  final String? phone;
  final String? avatarUrl;
  final String? bio;
  final DateTime? dateOfBirth;
  final String? gender;
  final double ratingAvg;
  final int totalReviews;
  final int completedOrders;

  final int? acceptRate;
  // Chỉ số uy tín
  final int? lateCancelRate;
  // Huy hiệu Người chăm tin cậ
  final bool trusted;
  final bool verified;
  final String? nationalIdMasked;
  final double? distanceKm;
  final List<SitterPhotoItem> photos;
  final SitterServices? services;
  final SitterServiceArea? serviceArea;

  const SitterProfile({
    this.id,
    required this.fullName,
    this.email,
    this.phone,
    this.avatarUrl,
    this.bio,
    this.dateOfBirth,
    this.gender,
    this.ratingAvg = 0,
    this.totalReviews = 0,
    this.completedOrders = 0,
    this.acceptRate,
    this.lateCancelRate,
    this.trusted = false,
    this.verified = false,
    this.nationalIdMasked,
    this.distanceKm,
    this.photos = const [],
    this.services,
    this.serviceArea,
  });

  SitterProfile copyWith({
    String? fullName,
    String? bio,
    String? phone,
    String? avatarUrl,
    List<SitterPhotoItem>? photos,
    SitterServices? services,
    SitterServiceArea? serviceArea,
    int? acceptRate,
    int? lateCancelRate,
    bool? trusted,
    bool? verified,
    double? distanceKm,
    double? ratingAvg,
    int? totalReviews,
  }) => SitterProfile(
    id: id,
    fullName: fullName ?? this.fullName,
    email: email,
    phone: phone ?? this.phone,
    avatarUrl: avatarUrl ?? this.avatarUrl,
    bio: bio ?? this.bio,
    dateOfBirth: dateOfBirth,
    gender: gender,
    ratingAvg: ratingAvg ?? this.ratingAvg,
    totalReviews: totalReviews ?? this.totalReviews,
    completedOrders: completedOrders,
    acceptRate: acceptRate ?? this.acceptRate,
    lateCancelRate: lateCancelRate ?? this.lateCancelRate,
    trusted: trusted ?? this.trusted,
    verified: verified ?? this.verified,
    nationalIdMasked: nationalIdMasked,
    distanceKm: distanceKm ?? this.distanceKm,
    photos: photos ?? this.photos,
    services: services ?? this.services,
    serviceArea: serviceArea ?? this.serviceArea,
  );

  factory SitterProfile.fromJson(Map<String, dynamic> j) => SitterProfile(
    id: j['id'] as String?,
    fullName: (j['fullName'] as String?) ?? '',
    email: j['email'] as String?,
    phone: j['phone'] as String?,
    avatarUrl: j['avatarUrl'] as String?,
    bio: j['bio'] as String?,
    dateOfBirth: docNgayJson(j['dateOfBirth'] as String?),
    gender: j['gender'] as String?,
    ratingAvg: (j['ratingAvg'] as num?)?.toDouble() ?? 0,
    totalReviews: (j['totalReviews'] as num?)?.toInt() ?? 0,
    completedOrders: (j['completedOrders'] as num?)?.toInt() ?? 0,
    acceptRate: (j['acceptRate'] as num?)?.toInt(),
    lateCancelRate: (j['lateCancelRate'] as num?)?.toInt(),
    trusted: j['trusted'] as bool? ?? false,
    verified: j['verified'] as bool? ?? false,
    nationalIdMasked: j['nationalIdMasked'] as String?,
    distanceKm: (j['distanceKm'] as num?)?.toDouble(),
    photos:
        (j['photos'] as List?)
            ?.map(
              (e) =>
                  SitterPhotoItem.fromJson(Map<String, dynamic>.from(e as Map)),
            )
            .toList() ??
        const [],
    services: j['services'] is Map
        ? SitterServices.fromJson(
            Map<String, dynamic>.from(j['services'] as Map),
          )
        : null,
    serviceArea: j['serviceArea'] is Map
        ? SitterServiceArea.fromJson(
            Map<String, dynamic>.from(j['serviceArea'] as Map),
          )
        : null,
  );
}
