import 'package:petcare_app/core/utils/vn_date.dart';
import 'package:petcare_app/shared/data/pet_brief.dart';
import 'package:petcare_app/shared/data/service_catalog.dart';

class DonChoTraLoi {
  const DonChoTraLoi({
    required this.id,
    required this.bookingCode,
    required this.ownerName,
    required this.ownerAvatar,
    required this.ownerArea,
    required this.serviceName,
    required this.serviceType,
    required this.pets,
    required this.startAt,
    required this.sentAt,
    required this.hanTraLoi,
    required this.price,
    required this.note,
    this.durationMinutes,
    this.distanceKm,
    this.ownerSince,
  });

  factory DonChoTraLoi.fromJson(Map<String, dynamic> j) => DonChoTraLoi(
    id: j['id'] as String,
    bookingCode: j['bookingCode'] as String? ?? '',
    ownerName: j['ownerName'] as String? ?? '',
    ownerAvatar: j['ownerAvatar'] as String? ?? '',
    ownerArea: j['ownerArea'] as String? ?? '',
    ownerSince: docMocVn(j['ownerSince'] as String?),
    serviceName: j['serviceName'] as String? ?? '',
    serviceType: switch (j['serviceType'] as String?) {
      'boarding' => LoaiDichVu.trongGiu,
      'grooming' => LoaiDichVu.catTia,
      _ => LoaiDichVu.datDiDao,
    },
    durationMinutes: (j['durationMinutes'] as num?)?.toInt(),
    distanceKm: (j['distanceKm'] as num?)?.toDouble(),
    pets: [
      for (final e in (j['pets'] as List? ?? const []))
        PetBrief(
          name: (e as Map)['name'] as String? ?? '',
          species: e['species'] as String? ?? '',
        ),
    ],
    startAt: docMocVn(j['startAt'] as String?) ?? nowVn(),
    sentAt: docMocVn(j['sentAt'] as String?) ?? nowVn(),
    hanTraLoi: docMocVn(j['respondDeadline'] as String?) ?? nowVn(),
    price: ((j['price'] as num?) ?? 0).round(),
    note: j['note'] as String? ?? '',
  );

  final String id;
  final String bookingCode;
  final String ownerName;
  final String ownerAvatar;

  final String ownerArea;
  final DateTime? ownerSince;
  final String serviceName;
  final LoaiDichVu serviceType;
  final int? durationMinutes;
  final double? distanceKm;
  final List<PetBrief> pets;
  final DateTime startAt;

  final DateTime sentAt;

  final DateTime hanTraLoi;
  final int price;
  final String note;
}

class SitterDashboard {
  const SitterDashboard({
    required this.location,
    required this.weekEarnings,
    required this.ordersThisWeek,
    required this.workedThisWeek,
    required this.rating,
    required this.acceptRate,
    required this.completedThisMonth,
    required this.pendingOrders,
    this.pendingTotal = 0,
    this.earningsChangePercent,
  });

  factory SitterDashboard.fromJson(Map<String, dynamic> j) => SitterDashboard(
    location: j['location'] as String? ?? '',
    weekEarnings: ((j['weekEarnings'] as num?) ?? 0).round(),
    earningsChangePercent: (j['earningsChangePercent'] as num?)?.toInt(),
    ordersThisWeek: (j['ordersThisWeek'] as num?)?.toInt() ?? 0,
    workedThisWeek: (j['workedThisWeek'] as num?)?.toInt() ?? 0,
    rating: ((j['rating'] as num?) ?? 0).toDouble(),
    acceptRate: (j['acceptRate'] as num?)?.toInt() ?? 100,
    completedThisMonth: (j['completedThisMonth'] as num?)?.toInt() ?? 0,
    pendingOrders: [
      for (final e in (j['pendingOrders'] as List? ?? const []))
        DonChoTraLoi.fromJson(Map<String, dynamic>.from(e as Map)),
    ],
    pendingTotal: (j['pendingTotal'] as num?)?.toInt() ?? 0,
  );

  final String location;
  final int weekEarnings;

  final int? earningsChangePercent;
  final int ordersThisWeek;

  final int workedThisWeek;
  final double rating;
  final int acceptRate;
  final int completedThisMonth;
  final List<DonChoTraLoi> pendingOrders;

  final int pendingTotal;
}
