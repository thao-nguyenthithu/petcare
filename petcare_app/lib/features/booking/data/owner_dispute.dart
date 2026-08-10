import 'package:petcare_app/core/utils/vn_date.dart';

enum TinhTrangHoSo {
  choNguoiChamPhanHoi,
  choHoTroXuLy,
  daHoanMotPhan,
  khongChapNhan,
}

typedef KetLuanHoSo = ({
  String? noiDung,
  String? lyDo,
  String nguoiXuLy,
  DateTime? luc,
});

// Hồ sơ khiếu nại nhìn từ phía chủ nuôi, không có khoản tiền nào của người chăm
class HoSoKhieuNaiChuNuoi {
  const HoSoKhieuNaiChuNuoi({
    required this.ma,
    required this.tinhTrang,
    required this.maDon,
    required this.tenDichVu,
    required this.tenNcc,
    required this.tenBe,
    required this.phanAnh,
    this.banMo = true,
    this.maLyDo,
    this.batDau,
    this.anhPhanAnh = const [],
    this.luc,
    this.phanHoiNcc,
    this.anhPhanHoi = const [],
    this.lucPhanHoi,
    this.ketLuan,
    this.tienHoan,
  });

  factory HoSoKhieuNaiChuNuoi.fromJson(Map<String, dynamic> json) {
    final don = _map(json['don']);
    return HoSoKhieuNaiChuNuoi(
      ma: json['ma'] as String? ?? '',
      tinhTrang: _tinhTrang(json['trangThai'] as String?),
      banMo: json['banMo'] as bool? ?? true,
      maLyDo: json['lyDo'] as String?,
      maDon: don['code'] as String? ?? '',
      tenDichVu: don['serviceName'] as String? ?? '',
      tenNcc: don['sitterName'] as String? ?? '',
      tenBe: [
        for (final e in (don['pets'] as List? ?? const []))
          if ((e as Map)['name'] case final String ten) ten,
      ],
      batDau: docMocVn(don['startAt'] as String?),
      phanAnh: json['phanAnh'] as String? ?? '',
      anhPhanAnh: _anh(json['anhPhanAnh']),
      luc: docMocVn(json['thoiDiemPhanAnh'] as String?),
      phanHoiNcc: json['phanHoiNguoiCham'] as String?,
      anhPhanHoi: _anh(json['anhPhanHoiNguoiCham']),
      lucPhanHoi: docMocVn(json['thoiDiemPhanHoi'] as String?),
      ketLuan: _ketLuan(json['ketLuan']),
      tienHoan: (json['tienHoan'] as num?)?.round(),
    );
  }

  final String ma;
  final TinhTrangHoSo tinhTrang;

  // Hồ sơ do người chăm mở thì chủ nuôi chỉ đọc, không có lượt đáp
  final bool banMo;
  final String? maLyDo;

  final String maDon;
  final String tenDichVu;
  final String tenNcc;
  final List<String> tenBe;
  final DateTime? batDau;

  final String phanAnh;
  final List<String> anhPhanAnh;
  final DateTime? luc;

  final String? phanHoiNcc;
  final List<String> anhPhanHoi;
  final DateTime? lucPhanHoi;

  final KetLuanHoSo? ketLuan;
  final int? tienHoan;

  bool get dangCho =>
      tinhTrang == TinhTrangHoSo.choNguoiChamPhanHoi ||
      tinhTrang == TinhTrangHoSo.choHoTroXuLy;
}

TinhTrangHoSo _tinhTrang(String? ma) => switch (ma) {
  'choHoTroXuLy' => TinhTrangHoSo.choHoTroXuLy,
  'daHoanMotPhan' => TinhTrangHoSo.daHoanMotPhan,
  'khongChapNhan' => TinhTrangHoSo.khongChapNhan,
  _ => TinhTrangHoSo.choNguoiChamPhanHoi,
};

KetLuanHoSo? _ketLuan(Object? o) {
  if (o is! Map) return null;
  final m = Map<String, dynamic>.from(o);
  return (
    noiDung: m['noiDung'] as String?,
    lyDo: m['lyDo'] as String?,
    nguoiXuLy: m['nguoiXuLy'] as String? ?? '',
    luc: docMocVn(m['thoiDiem'] as String?),
  );
}

List<String> _anh(Object? o) => [
  if (o is List)
    for (final e in o)
      if (e is String && e.isNotEmpty) e,
];

Map<String, dynamic> _map(Object? o) =>
    o is Map ? Map<String, dynamic>.from(o) : <String, dynamic>{};
