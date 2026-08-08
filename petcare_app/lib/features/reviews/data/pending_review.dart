import 'package:petcare_app/shared/data/pet_brief.dart';
import 'package:petcare_app/shared/data/sitter_services.dart';

// Một đơn đã xong mà chủ nuôi chưa đánh giá
class DonChoDanhGia {
  const DonChoDanhGia({
    required this.bookingId,
    required this.maDon,
    required this.tenNcc,
    required this.loai,
    required this.pets,
    required this.xongNgay,
    required this.xongGio,
    required this.soNgayCon,
    this.anhNcc,
  });

  factory DonChoDanhGia.fromJson(Map<String, dynamic> j) => DonChoDanhGia(
    bookingId: (j['id'] as String?) ?? '',
    maDon: (j['code'] as String?) ?? '',
    tenNcc: (j['sitterName'] as String?) ?? '',
    anhNcc: j['sitterAvatarUrl'] as String?,
    loai: serviceTypeTuMa(j['serviceType'] as String?),
    pets: [
      for (final e in (j['pets'] as List? ?? const []))
        PetBrief(
          name: (e as Map)['name'] as String? ?? '',
          species: e['species'] as String? ?? '',
          avatar: e['avatarUrl'] as String?,
        ),
    ],
    xongNgay: (j['endedAtDateLabel'] as String?) ?? '',
    xongGio: (j['endedAtTimeLabel'] as String?) ?? '',
    soNgayCon: (j['daysLeftToReview'] as num?)?.toInt() ?? 0,
  );

  final String bookingId;
  final String maDon;
  final String tenNcc;
  final String? anhNcc;
  final ServiceType loai;
  final List<PetBrief> pets;

  final String xongNgay;
  final String xongGio;

  final int soNgayCon;
  String get tenCacBe => pets.map((p) => p.name).join(', ');
}

ServiceType serviceTypeTuMa(String? ma) => switch (ma) {
  'boarding' => ServiceType.boarding,
  'grooming' => ServiceType.grooming,
  _ => ServiceType.walking,
};
