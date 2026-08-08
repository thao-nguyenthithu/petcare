import 'dart:typed_data';

import 'package:petcare_app/core/utils/vn_date.dart';
import 'package:petcare_app/shared/data/prevention_record.dart';
import 'package:petcare_app/shared/widgets/photo_viewer.dart';

// Đơn chưa kết thúc của bé, dùng để chặn xoá hồ sơ
class PetActiveBooking {
  const PetActiveBooking({
    required this.maDon,
    required this.tenDichVu,
    required this.tenNcc,
    required this.moTaThoiGian,
    this.avatarNcc,
  });

  final String maDon;
  final String tenDichVu;
  final String tenNcc;

  final String moTaThoiGian;
  final String? avatarNcc;
}

// Hồ sơ một thú cưng của chủ nuôi
enum PetSpecies { dog, cat }

enum PetGender { male, female }

class Pet {
  const Pet({
    required this.id,
    required this.name,
    required this.species,
    required this.breed,
    required this.weightKg,
    required this.gender,
    this.birthDate,
    this.avatar,
    this.anh = const [],
    this.daTrietSan = false,
    this.dangDieuTri = false,
    this.benhNen,
    this.thuocDangDung,
    this.luuYChamSoc,
    this.phongBenh = const [],
    this.donDangChay,
  });

  final String id;
  final String name;
  final PetSpecies species;
  final String breed;
  final double weightKg;
  final PetGender gender;
  final DateTime? birthDate;
  final String? avatar;
  final List<PhotoItem> anh;
  final bool daTrietSan;
  final bool dangDieuTri;
  final String? benhNen;
  final String? thuocDangDung;
  final String? luuYChamSoc;
  final List<PreventionRecord> phongBenh;

  // Có đơn thì chưa cho xoá hồ sơ bé
  final PetActiveBooking? donDangChay;

  factory Pet.fromJson(Map<String, dynamic> j) => Pet(
    id: j['id'] as String,
    name: j['name'] as String,
    species: (j['species'] as String) == 'CAT'
        ? PetSpecies.cat
        : PetSpecies.dog,
    breed: j['breed'] as String,
    weightKg: (j['weightKg'] as num).toDouble(),
    gender: (j['gender'] as String) == 'FEMALE'
        ? PetGender.female
        : PetGender.male,
    birthDate: docNgayJson(j['birthDate'] as String?),
    avatar: j['avatarUrl'] as String?,
    anh: [
      for (final a in (j['photos'] as List? ?? []))
        PhotoItem.mang(
          (a as Map)['url'] as String,
          id: a['id'] as String?,
          ngayThem: docMocVn(a['createdAt'] as String?),
        ),
    ],
    daTrietSan: j['isNeutered'] as bool? ?? false,
    dangDieuTri: j['underTreatment'] as bool? ?? false,
    benhNen: j['chronicDisease'] as String?,
    thuocDangDung: j['medication'] as String?,
    luuYChamSoc: j['careNote'] as String?,
    phongBenh: [
      for (final p in (j['preventions'] as List? ?? []))
        PreventionRecord.fromJson(Map<String, dynamic>.from(p as Map)),
    ],
  );

  // Thân request khi tạo hoặc sửa hồ sơ
  Map<String, dynamic> toJson() => {
    'name': name,
    'species': species == PetSpecies.cat ? 'CAT' : 'DOG',
    'breed': breed,
    'gender': gender == PetGender.female ? 'FEMALE' : 'MALE',
    'birthDate': birthDate == null ? null : ngayJson(birthDate!),
    'weightKg': weightKg,
    'isNeutered': daTrietSan,
    'underTreatment': dangDieuTri,
    'chronicDisease': benhNen,
    'medication': thuocDangDung,
    'careNote': luuYChamSoc,
  };
}

// Một ảnh của bé trong form
class PetPhoto {
  const PetPhoto({required this.addedAt, this.id, this.url, this.bytes})
    : assert(url != null || bytes != null, 'Ảnh phải có url hoặc bytes');

  final String? id;
  final String? url;
  final Uint8List? bytes;
  final DateTime addedAt;

  bool get daTaiLen => id != null;

  PhotoItem get item => bytes != null
      ? PhotoItem.bytes(bytes!, ngayThem: addedAt)
      : PhotoItem.mang(url!, id: id, ngayThem: addedAt);
}

// Số ảnh tối đa một bé
const int maxPetPhotos = 10;

typedef PetDocument = ({
  PreventionRecord hangMuc,
  PreventionDose lan,
  PhotoItem anh,
});

// Ảnh của 1 hạng mục
typedef PetDocumentGroup = ({PreventionRecord hangMuc, List<PetDocument> anh});

List<PetDocument> giayToCuaBe(List<PreventionRecord> phongBenh) => [
  for (final hangMuc in phongBenh)
    for (final lan in hangMuc.lanThucHien)
      for (final anh in lan.anh) (hangMuc: hangMuc, lan: lan, anh: anh),
];

// Gom ảnh phiếu theo hạng mục
List<PetDocumentGroup> gomGiayToTheoHangMuc(List<PetDocument> giayTo) {
  final theoHangMuc = <String, List<PetDocument>>{};
  for (final muc in giayTo) {
    theoHangMuc.putIfAbsent(muc.hangMuc.id, () => []).add(muc);
  }
  return [
    for (final nhom in theoHangMuc.values)
      (
        hangMuc: nhom.first.hangMuc,
        anh: [...nhom]..sort((a, b) => b.lan.ngay.compareTo(a.lan.ngay)),
      ),
  ];
}
