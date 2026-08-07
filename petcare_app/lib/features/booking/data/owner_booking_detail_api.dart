import 'package:latlong2/latlong.dart';
import 'package:petcare_app/core/utils/vn_date.dart';
import 'package:petcare_app/features/booking/data/owner_booking.dart';
import 'package:petcare_app/shared/data/pet.dart';
import 'package:petcare_app/shared/data/sitter_services.dart';

typedef NccCuaDon = ({
  String? id,
  String ten,
  String? avatar,
  double rating,
  int soDanhGia,
});

typedef PhienApi = ({double? km, int? phut, int? giayMoiLuotGui});

typedef ChoNguoiChamApi = ({
  String? khuVuc,
  String? diaChiDayDu,
  LatLng? viTri,
  double? km,
});

typedef DongGiaApi = ({
  String key,
  int tien,
  String? petId,
  Map<String, dynamic> meta,
});

typedef ChinhSachHuyApi = ({
  DateTime? hanHuyMienPhiAt,
  bool laDatGap,
  DateTime? hetAnHanDatGapAt,
  bool mienPhi,
  bool doNguoiCham,
  bool coTheHuy,
  int phiHuyDuKien,
  int tienHoanDuKien,
});

typedef ThongTinHuyApi = ({
  String ben,
  DateTime? luc,
  String? lyDo,
  String? moTa,
  int phiHuy,
});

class ChiTietDonApi {
  const ChiTietDonApi({
    required this.id,
    required this.code,
    required this.trangThai,
    required this.loai,
    required this.tenDichVu,
    required this.pets,
    required this.ncc,
    required this.batDau,
    required this.tongTien,
    required this.dongGia,
    required this.chinhSachHuy,
    this.goiTheoBe = const {},
    this.thoiLuongPhut,
    this.soDem,
    this.ketThuc,
    this.hanChot,
    this.nhanLuc,
    this.xuatPhatLuc,
    this.toiNoiLuc,
    this.batDauThat,
    this.ketThucThat,
    this.ghiChu,
    this.diaChi,
    this.viTri,
    this.choNcc,
    this.phien,
    this.thongTinHuy,
  });

  factory ChiTietDonApi.fromJson(Map<String, dynamic> json) {
    final ncc = _map(json['sitter']);
    final diaChi = _map(json['address']);
    return ChiTietDonApi(
      id: json['id'] as String,
      code: json['code'] as String? ?? '',
      trangThai: trangThaiTuMa(json['status'] as String?),
      loai: _loaiTuMa(json['serviceType'] as String?),
      tenDichVu: json['serviceName'] as String? ?? '',
      thoiLuongPhut: (json['durationMinutes'] as num?)?.toInt(),
      soDem: (json['nights'] as num?)?.toInt(),
      batDau: docMocVn(json['startAt'] as String?) ?? nowVn(),
      ketThuc: docMocVn(json['endAt'] as String?),
      hanChot: docMocVn(json['deadlineAt'] as String?),
      nhanLuc: docMocVn(json['acceptedAt'] as String?),
      xuatPhatLuc: docMocVn(json['departedAt'] as String?),
      toiNoiLuc: docMocVn(json['arrivedAt'] as String?),
      batDauThat: docMocVn(json['startedAt'] as String?),
      ketThucThat: docMocVn(json['endedAt'] as String?),
      ghiChu: json['note'] as String?,
      phien: _phien(json['session']),
      ncc: (
        id: ncc['id'] as String?,
        ten: ncc['fullName'] as String? ?? '',
        avatar: ncc['avatarUrl'] as String?,
        rating: (ncc['ratingAvg'] as num?)?.toDouble() ?? 0,
        soDanhGia: (ncc['totalReviews'] as num?)?.toInt() ?? 0,
      ),
      pets: [
        for (final e in (json['pets'] as List? ?? const []))
          Pet.fromJson(Map<String, dynamic>.from(e as Map)),
      ],
      goiTheoBe: {
        for (final e in (json['pets'] as List? ?? const []))
          if ((e as Map)['packageCode'] != null)
            e['id'] as String: (
              goi: _goiTuMa(e['packageCode'] as String?),
              gia: ((e['packagePrice'] as num?) ?? 0).round(),
            ),
      },
      diaChi: diaChi['text'] as String?,
      viTri: _viTri(diaChi['lat'], diaChi['lng']),
      choNcc: _choNcc(json['sitterPlace']),
      dongGia: [
        for (final e in (json['priceLines'] as List? ?? const []))
          _dongGia(Map<String, dynamic>.from(e as Map)),
      ],
      tongTien: ((json['totalPrice'] as num?) ?? 0).round(),
      chinhSachHuy: _chinhSach(_map(json['cancelPolicy'])),
      thongTinHuy: _thongTinHuy(json['cancellation']),
    );
  }

  final String id;
  final String code;
  final TrangThaiDon trangThai;
  final ServiceType loai;
  final String tenDichVu;
  final int? thoiLuongPhut;
  final int? soDem;
  final DateTime batDau;
  final DateTime? ketThuc;
  final DateTime? hanChot;
  final DateTime? nhanLuc;
  final DateTime? xuatPhatLuc;
  final DateTime? toiNoiLuc;
  final DateTime? batDauThat;
  final DateTime? ketThucThat;
  final String? ghiChu;
  final NccCuaDon ncc;
  final List<Pet> pets;
  final Map<String, ({GroomingPackage goi, int gia})> goiTheoBe;
  final String? diaChi;
  final LatLng? viTri;

  final ChoNguoiChamApi? choNcc;
  final PhienApi? phien;
  final List<DongGiaApi> dongGia;
  final int tongTien;
  final ChinhSachHuyApi chinhSachHuy;
  final ThongTinHuyApi? thongTinHuy;
}

Map<String, dynamic> _map(Object? o) =>
    o is Map ? Map<String, dynamic>.from(o) : <String, dynamic>{};

ServiceType _loaiTuMa(String? ma) => switch (ma) {
  'boarding' => ServiceType.boarding,
  'grooming' => ServiceType.grooming,
  _ => ServiceType.walking,
};

GroomingPackage _goiTuMa(String? ma) =>
    ma == 'bath' ? GroomingPackage.bath : GroomingPackage.bathAndTrim;

LatLng? _viTri(Object? lat, Object? lng) =>
    lat is num && lng is num ? LatLng(lat.toDouble(), lng.toDouble()) : null;

PhienApi? _phien(Object? o) {
  if (o is! Map) return null;
  final m = Map<String, dynamic>.from(o);
  return (
    km: (m['distanceKm'] as num?)?.toDouble(),
    phut: (m['durationMinutes'] as num?)?.toInt(),
    giayMoiLuotGui: (m['updateEverySeconds'] as num?)?.toInt(),
  );
}

ChoNguoiChamApi? _choNcc(Object? o) {
  if (o is! Map) return null;
  final m = Map<String, dynamic>.from(o);
  return (
    khuVuc: m['area'] as String?,
    diaChiDayDu: m['address'] as String?,
    viTri: _viTri(m['lat'], m['lng']),
    km: (m['distanceKm'] as num?)?.toDouble(),
  );
}

DongGiaApi _dongGia(Map<String, dynamic> j) => (
  key: j['key'] as String? ?? '',
  tien: ((j['amount'] as num?) ?? 0).round(),
  petId: j['petId'] as String?,
  meta: _map(j['meta']),
);

ChinhSachHuyApi _chinhSach(Map<String, dynamic> j) => (
  hanHuyMienPhiAt: docMocVn(j['hanHuyMienPhiAt'] as String?),
  laDatGap: j['laDatGap'] as bool? ?? false,
  hetAnHanDatGapAt: docMocVn(j['hetAnHanDatGapAt'] as String?),
  mienPhi: j['mienPhi'] as bool? ?? false,
  doNguoiCham: j['doNguoiCham'] as bool? ?? false,
  coTheHuy: j['coTheHuy'] as bool? ?? false,
  phiHuyDuKien: ((j['phiHuyDuKien'] as num?) ?? 0).round(),
  tienHoanDuKien: ((j['tienHoanDuKien'] as num?) ?? 0).round(),
);

ThongTinHuyApi? _thongTinHuy(Object? o) {
  if (o is! Map) return null;
  final m = Map<String, dynamic>.from(o);
  return (
    ben: m['by'] as String? ?? 'systemExpired',
    luc: docMocVn(m['at'] as String?),
    lyDo: m['reason'] as String?,
    moTa: m['note'] as String?,
    phiHuy: ((m['fee'] as num?) ?? 0).round(),
  );
}
