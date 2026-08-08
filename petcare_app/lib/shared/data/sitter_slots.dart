import 'package:petcare_app/core/utils/vn_date.dart';
import 'package:petcare_app/shared/data/sitter_services.dart';

// Lịch trống của một người chăm
class KhoangBanGio {
  const KhoangBanGio({required this.batDauPhut, required this.ketThucPhut});

  final int batDauPhut;
  final int ketThucPhut;

  bool giaoVoi(int batDau, int ketThuc) =>
      batDau < ketThucPhut && ketThuc > batDauPhut;

  factory KhoangBanGio.fromJson(Map<String, dynamic> json) => KhoangBanGio(
    batDauPhut: phutTuGio(json['start'] as String?),
    ketThucPhut: phutTuGio(json['end'] as String?),
  );
}

class NgayLichNcc {
  const NgayLichNcc({
    required this.ngay,
    required this.nghi,
    required this.phutMo,
    required this.phutDong,
    required this.ban,
    required this.choTrongGiu,
    this.banCuaBe = const [],
    this.beBanCaNgay = false,
  });

  final DateTime ngay;
  final bool nghi;
  final int phutMo;
  final int phutDong;
  final List<KhoangBanGio> ban;
  final int choTrongGiu;
  final List<KhoangBanGio> banCuaBe;
  final bool beBanCaNgay;

  bool get kinCaNgay {
    if (nghi || phutDong <= phutMo) return false;
    final sapXep = [...ban]
      ..sort((a, b) => a.batDauPhut.compareTo(b.batDauPhut));
    var moc = phutMo;
    for (final k in sapXep) {
      if (k.batDauPhut > moc) return false;
      if (k.ketThucPhut > moc) moc = k.ketThucPhut;
      if (moc >= phutDong) return true;
    }
    return moc >= phutDong;
  }

  factory NgayLichNcc.fromJson(Map<String, dynamic> json) => NgayLichNcc(
    ngay: docNgayJson(json['date'] as String?) ?? homNayVn(),
    nghi: (json['closed'] as bool?) ?? false,
    phutMo: phutTuGio(json['start'] as String?),
    phutDong: phutTuGio(json['end'] as String?),
    ban: _docKhoang(json['busy']),
    choTrongGiu: ((json['boardingLeft'] as num?) ?? 0).toInt(),
    banCuaBe: _docKhoang(json['petBusy']),
    beBanCaNgay: (json['petBusyAllDay'] as bool?) ?? false,
  );
}

List<KhoangBanGio> _docKhoang(Object? raw) => [
  for (final e in (raw as List?) ?? const [])
    KhoangBanGio.fromJson(Map<String, dynamic>.from(e as Map)),
];

class SitterSlots {
  const SitterSlots({
    required this.phutMoMacDinh,
    required this.phutDongMacDinh,
    required this.sucChuaTrongGiu,
    required this.theoNgay,
  });

  final int phutMoMacDinh;
  final int phutDongMacDinh;
  final int sucChuaTrongGiu;
  final Map<String, NgayLichNcc> theoNgay;

  NgayLichNcc? cuaNgay(DateTime d) => theoNgay[ngayJson(d)];

  List<DateTime> ngayNghi() => [
    for (final e in theoNgay.values)
      if (e.nghi) e.ngay,
  ];
  List<DateTime> ngayKinDon(ServiceType loai) => [
    for (final e in theoNgay.values)
      if (!e.nghi &&
          (e.kinCaNgay ||
              e.beBanCaNgay ||
              (loai == ServiceType.boarding && e.choTrongGiu < 1)))
        e.ngay,
  ];

  List<DateTime> ngayKhongDat(ServiceType loai) => [
    ...ngayNghi(),
    ...ngayKinDon(loai),
  ];

  factory SitterSlots.fromJson(Map<String, dynamic> json) {
    final days = <String, NgayLichNcc>{};
    for (final e in (json['days'] as List?) ?? const []) {
      final ngay = NgayLichNcc.fromJson(Map<String, dynamic>.from(e as Map));
      days[ngayJson(ngay.ngay)] = ngay;
    }
    return SitterSlots(
      phutMoMacDinh: phutTuGio(json['workStart'] as String?),
      phutDongMacDinh: phutTuGio(json['workEnd'] as String?),
      sucChuaTrongGiu: ((json['boardingCapacity'] as num?) ?? 0).toInt(),
      theoNgay: days,
    );
  }
}

int phutTuGio(String? s) {
  if (s == null || s.length < 4) return 0;
  final phan = s.split(':');
  if (phan.length < 2) return 0;
  return (int.tryParse(phan[0]) ?? 0) * 60 + (int.tryParse(phan[1]) ?? 0);
}
