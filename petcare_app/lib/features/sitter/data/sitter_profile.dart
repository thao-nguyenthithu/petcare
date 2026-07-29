import 'package:petcare_app/features/sitter/data/sitter_service_area.dart';
import 'package:petcare_app/features/sitter/data/sitter_services.dart';

// Số ảnh tối đa trong thư viện NCC
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
    ngayThem: DateTime.tryParse(j['createdAt'] as String? ?? ''),
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
  }) => SitterProfile(
    id: id,
    fullName: fullName ?? this.fullName,
    email: email,
    phone: phone ?? this.phone,
    avatarUrl: avatarUrl ?? this.avatarUrl,
    bio: bio ?? this.bio,
    dateOfBirth: dateOfBirth,
    gender: gender,
    ratingAvg: ratingAvg,
    totalReviews: totalReviews,
    completedOrders: completedOrders,
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
    dateOfBirth: j['dateOfBirth'] == null
        ? null
        : DateTime.tryParse(j['dateOfBirth'] as String),
    gender: j['gender'] as String?,
    ratingAvg: (j['ratingAvg'] as num?)?.toDouble() ?? 0,
    totalReviews: (j['totalReviews'] as num?)?.toInt() ?? 0,
    completedOrders: (j['completedOrders'] as num?)?.toInt() ?? 0,
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
