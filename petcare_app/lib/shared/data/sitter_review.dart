import 'package:petcare_app/shared/data/pet_brief.dart';
import 'package:petcare_app/shared/data/service_catalog.dart';

class PhanHoiDanhGia {
  const PhanHoiDanhGia({required this.thoiDiem, required this.noiDung});

  factory PhanHoiDanhGia.fromJson(Map<String, dynamic> j) => PhanHoiDanhGia(
    thoiDiem: (j['createdAtLabel'] as String?) ?? '',
    noiDung: (j['content'] as String?) ?? '',
  );

  final String thoiDiem;
  final String noiDung;
}

class SitterReview {
  const SitterReview({
    required this.name,
    required this.stars,
    required this.service,
    required this.time,
    required this.text,
    this.id = '',
    this.bookingId = '',
    this.pets = const [],
    this.loaiDichVu,
    this.anh = const [],
    this.phanHoi,
    this.soNgayConPhanHoi,
  });

  final String id;
  final String bookingId;
  final String name;
  final int stars;
  final String service;
  final LoaiDichVu? loaiDichVu;
  final String time;
  final String text;
  final List<PetBrief> pets;
  final List<String> anh;
  final PhanHoiDanhGia? phanHoi;
  final int? soNgayConPhanHoi;
  bool get coAnh => anh.isNotEmpty;

  SitterReview copyWith({PhanHoiDanhGia? phanHoi, int? soNgayConPhanHoi}) =>
      SitterReview(
        id: id,
        bookingId: bookingId,
        name: name,
        stars: stars,
        service: service,
        loaiDichVu: loaiDichVu,
        time: time,
        text: text,
        pets: pets,
        anh: anh,
        phanHoi: phanHoi ?? this.phanHoi,
        soNgayConPhanHoi: soNgayConPhanHoi ?? this.soNgayConPhanHoi,
      );

  factory SitterReview.fromJson(Map<String, dynamic> j) => SitterReview(
    id: (j['id'] as String?) ?? '',
    bookingId: (j['bookingId'] as String?) ?? '',
    soNgayConPhanHoi: (j['daysLeftToReply'] as num?)?.toInt(),
    name: (j['ownerName'] as String?) ?? '',
    stars: (j['rating'] as num?)?.toInt() ?? 0,
    service: (j['serviceName'] as String?) ?? '',
    loaiDichVu: _loaiTuMa(j['serviceType'] as String?),
    time: (j['createdAtLabel'] as String?) ?? '',
    text: (j['comment'] as String?) ?? '',
    anh: [for (final e in (j['photos'] as List? ?? const [])) e as String],
    phanHoi: j['reply'] == null
        ? null
        : PhanHoiDanhGia.fromJson(Map<String, dynamic>.from(j['reply'] as Map)),
    pets:
        (j['pets'] as List?)
            ?.map(
              (e) => PetBrief(
                name: (e as Map)['name'] as String? ?? '',
                species: e['species'] as String? ?? '',
                avatar: e['avatarUrl'] as String?,
              ),
            )
            .toList() ??
        const [],
  );
}

LoaiDichVu? _loaiTuMa(String? ma) => switch (ma) {
  'walking' => LoaiDichVu.datDiDao,
  'boarding' => LoaiDichVu.trongGiu,
  'grooming' => LoaiDichVu.catTia,
  _ => null,
};

class ThongKeDanhGia {
  const ThongKeDanhGia({
    required this.diemTrungBinh,
    required this.tongSo,
    required this.phanBoSao,
    required this.phanBoDichVu,
    required this.soCoAnh,
  });

  factory ThongKeDanhGia.fromJson(Map<String, dynamic> j) => ThongKeDanhGia(
    diemTrungBinh: (j['ratingAvg'] as num?)?.toDouble() ?? 0,
    tongSo: (j['total'] as num?)?.toInt() ?? 0,
    phanBoSao: {
      for (var sao = 1; sao <= 5; sao++)
        sao: ((j['byRating'] as Map?)?['$sao'] as num?)?.toInt() ?? 0,
    },
    phanBoDichVu: {
      for (final dv in LoaiDichVu.values)
        dv: ((j['byService'] as Map?)?[dv.maApi] as num?)?.toInt() ?? 0,
    },
    soCoAnh: (j['withPhotos'] as num?)?.toInt() ?? 0,
  );

  final double diemTrungBinh;
  final int tongSo;
  final Map<int, int> phanBoSao;
  final Map<LoaiDichVu, int> phanBoDichVu;
  final int soCoAnh;

  int get mucCaoNhat =>
      phanBoSao.values.fold(0, (max, so) => so > max ? so : max);
}
