import 'package:petcare_app/core/l10n/generated/app_localizations.dart';
import 'package:petcare_app/shared/data/pet.dart';
import 'package:petcare_app/shared/data/service_catalog.dart';

enum SapXepKetQua { deXuat, ganNhat, danhGiaCao, nhieuDon, itHuyMuon }

// Mức cân người chăm nhận
enum MucCan { duoi5, tu5den10, tu10den20, tren20 }

extension MucCanHienThi on MucCan {
  String ten(AppLocalizations l10n) => switch (this) {
    MucCan.duoi5 => l10n.duoi5kg,
    MucCan.tu5den10 => l10n.tu5den10kg,
    MucCan.tu10den20 => l10n.tu10den20kg,
    MucCan.tren20 => l10n.tren20kg,
  };

  static MucCan tuCanNang(double kg) {
    if (kg < 5) return MucCan.duoi5;
    if (kg < 10) return MucCan.tu5den10;
    if (kg < 20) return MucCan.tu10den20;
    return MucCan.tren20;
  }
}

// Mục chọn ở ô lọc Dịch vụ
enum MucLocDichVu { datDiDao, trongGiu, tamVaCatTia, chiTam, catTiaTatCa }

const List<MucLocDichVu> mucLocChinh = [
  MucLocDichVu.datDiDao,
  MucLocDichVu.trongGiu,
  MucLocDichVu.catTiaTatCa,
];

extension MucLocDichVuTuLoai on LoaiDichVu {
  MucLocDichVu get mucLoc => switch (this) {
    LoaiDichVu.datDiDao => MucLocDichVu.datDiDao,
    LoaiDichVu.trongGiu => MucLocDichVu.trongGiu,
    LoaiDichVu.catTia => MucLocDichVu.catTiaTatCa,
  };
}

extension MucLocDichVuHienThi on MucLocDichVu {
  String? get maGoi => switch (this) {
    MucLocDichVu.tamVaCatTia => 'bathAndTrim',
    MucLocDichVu.chiTam => 'bath',
    _ => null,
  };

  bool get laCaLoai => this == MucLocDichVu.catTiaTatCa;
  bool get chiNhanCho => loai == LoaiDichVu.datDiDao;

  MucLocDichVu get mucChinh =>
      loai == LoaiDichVu.catTia ? MucLocDichVu.catTiaTatCa : this;
  LoaiDichVu get loai => switch (this) {
    MucLocDichVu.datDiDao => LoaiDichVu.datDiDao,
    MucLocDichVu.trongGiu => LoaiDichVu.trongGiu,
    MucLocDichVu.tamVaCatTia ||
    MucLocDichVu.chiTam ||
    MucLocDichVu.catTiaTatCa => LoaiDichVu.catTia,
  };

  String ten(AppLocalizations l10n) => switch (this) {
    MucLocDichVu.datDiDao => l10n.datDiDao,
    MucLocDichVu.trongGiu => l10n.trongGiu,
    MucLocDichVu.tamVaCatTia => l10n.tamVaCatTia,
    MucLocDichVu.chiTam => l10n.chiTam,
    MucLocDichVu.catTiaTatCa => l10n.tamVaTia,
  };
}

const Object _giuNguyen = Object();

// Bộ lọc đang áp ở màn kết quả tìm kiếm
class BoLocTimKiem {
  const BoLocTimKiem({
    this.dichVu,
    this.tuNgay,
    this.denNgay,
    this.soBe = 0,
    this.diemToiThieu,
    this.chiTinCay = false,
    this.nhanCho = false,
    this.nhanMeo = false,
    this.sapXep = SapXepKetQua.deXuat,
    this.beDaChon = const {},
    this.mucCan = const {},
    this.giaTu,
    this.giaDen,
    this.banKinhKm = 5,
  });

  final double banKinhKm;
  final Set<String> beDaChon;
  final Set<MucCan> mucCan;
  final int? giaTu;
  final int? giaDen;
  final MucLocDichVu? dichVu;
  final DateTime? tuNgay;
  final DateTime? denNgay;
  final int soBe;

  final double? diemToiThieu;
  final bool chiTinCay;
  final bool nhanCho;
  final bool nhanMeo;
  final SapXepKetQua sapXep;

  bool get coDieuKien =>
      dichVu != null ||
      soNgay > 0 ||
      soBeHieuLuc > 0 ||
      mucCan.isNotEmpty ||
      diemToiThieu != null ||
      giaTu != null ||
      giaDen != null ||
      chiTinCay ||
      nhanCho ||
      nhanMeo;

  int get soBeHieuLuc => beDaChon.isNotEmpty ? beDaChon.length : soBe;
  bool get epLoaiCho => dichVu?.chiNhanCho ?? false;

  String? get maLoai {
    if (epLoaiCho) return 'dog';
    if (nhanCho == nhanMeo) return null;
    return nhanCho ? 'dog' : 'cat';
  }

  BoLocTimKiem chuanHoaLoai(List<Pet> danhSachBe) {
    if (!epLoaiCho) return this;
    final idCho = danhSachBe
        .where((be) => be.species == PetSpecies.dog)
        .map((be) => be.id)
        .toSet();
    return copyWith(
      nhanCho: false,
      nhanMeo: false,
      beDaChon: beDaChon.intersection(idCho),
    );
  }

  int get soNgay {
    final tu = tuNgay;
    final den = denNgay;
    if (tu == null || den == null) return 0;
    return den.difference(tu).inDays + 1;
  }

  @override
  bool operator ==(Object other) =>
      other is BoLocTimKiem &&
      other.dichVu == dichVu &&
      other.tuNgay == tuNgay &&
      other.denNgay == denNgay &&
      other.soBe == soBe &&
      other.diemToiThieu == diemToiThieu &&
      other.chiTinCay == chiTinCay &&
      other.nhanCho == nhanCho &&
      other.nhanMeo == nhanMeo &&
      other.sapXep == sapXep &&
      other.giaTu == giaTu &&
      other.giaDen == giaDen &&
      other.banKinhKm == banKinhKm &&
      _bangNhau(other.beDaChon, beDaChon) &&
      _bangNhau(other.mucCan, mucCan);

  @override
  int get hashCode => Object.hash(
    dichVu,
    tuNgay,
    denNgay,
    soBe,
    diemToiThieu,
    chiTinCay,
    nhanCho,
    nhanMeo,
    sapXep,
    giaTu,
    giaDen,
    banKinhKm,
    Object.hashAllUnordered(beDaChon),
    Object.hashAllUnordered(mucCan),
  );

  static bool _bangNhau(Set<Object> a, Set<Object> b) =>
      a.length == b.length && a.containsAll(b);

  BoLocTimKiem copyWith({
    Object? dichVu = _giuNguyen,
    Object? tuNgay = _giuNguyen,
    Object? denNgay = _giuNguyen,
    int? soBe,
    Object? diemToiThieu = _giuNguyen,
    bool? chiTinCay,
    bool? nhanCho,
    bool? nhanMeo,
    SapXepKetQua? sapXep,
    Set<String>? beDaChon,
    Set<MucCan>? mucCan,
    Object? giaTu = _giuNguyen,
    Object? giaDen = _giuNguyen,
    double? banKinhKm,
  }) => BoLocTimKiem(
    banKinhKm: banKinhKm ?? this.banKinhKm,
    beDaChon: beDaChon ?? this.beDaChon,
    mucCan: mucCan ?? this.mucCan,
    giaTu: giaTu == _giuNguyen ? this.giaTu : giaTu as int?,
    giaDen: giaDen == _giuNguyen ? this.giaDen : giaDen as int?,
    dichVu: dichVu == _giuNguyen ? this.dichVu : dichVu as MucLocDichVu?,
    tuNgay: tuNgay == _giuNguyen ? this.tuNgay : tuNgay as DateTime?,
    denNgay: denNgay == _giuNguyen ? this.denNgay : denNgay as DateTime?,
    soBe: soBe ?? this.soBe,
    diemToiThieu: diemToiThieu == _giuNguyen
        ? this.diemToiThieu
        : diemToiThieu as double?,
    chiTinCay: chiTinCay ?? this.chiTinCay,
    nhanCho: nhanCho ?? this.nhanCho,
    nhanMeo: nhanMeo ?? this.nhanMeo,
    sapXep: sapXep ?? this.sapXep,
  );
}
