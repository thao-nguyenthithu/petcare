import 'package:petcare_app/core/l10n/generated/app_localizations.dart';
import 'package:petcare_app/core/utils/vn_date.dart';
import 'package:petcare_app/shared/data/pet_brief.dart';
import 'package:petcare_app/shared/data/service_catalog.dart';
import 'package:petcare_app/shared/utils/relative_time.dart';

enum SitterBookingStatus {
  choXacNhan, // PENDING
  daXacNhan, // CONFIRMED
  dangDienRa, // IN_PROGRESS
  choChuNuoiXacNhan, // WAIT_CONFIRM
  khieuNai, // DISPUTED
  hoanThanh, // COMPLETED
  daHuy, // CANCELLED, gồm cả CANCELLED_BY_ADMIN
  khongRo,
}

String maChipDon(SitterBookingStatus tt) => tt.name;

SitterBookingStatus? chipDonTuMa(String? ma) {
  for (final tt in SitterBookingStatus.values) {
    if (tt.name == ma) return tt;
  }
  return null;
}

enum GhiChuDon {
  khong,
  choBanNhanDon,
  choChuNuoiChot,
  choHoTroXuLy,
  khachVangMat,
  khachHuy,
  khachHuySom,
  banDaHuy,
  hetHanNhan,
  quanTriHuy,
}

extension GhiChuDonHienThi on GhiChuDon {
  String? nhan(AppLocalizations l10n) => switch (this) {
    GhiChuDon.khong => null,
    GhiChuDon.choBanNhanDon => l10n.choBanNhanDon,
    GhiChuDon.choChuNuoiChot => l10n.choChuNuoiChot,
    GhiChuDon.choHoTroXuLy => l10n.choHoTroXuLy,
    GhiChuDon.khachVangMat => l10n.khachVangMatQuaHen,
    GhiChuDon.khachHuy => l10n.khachHuyDon,
    GhiChuDon.khachHuySom => l10n.khachHuySom,
    GhiChuDon.banDaHuy => l10n.banDaHuyDon,
    GhiChuDon.hetHanNhan => l10n.hetHanNhanDon,
    GhiChuDon.quanTriHuy => l10n.quanTriHuyDon,
  };
}

class SitterBooking {
  const SitterBooking({
    required this.id,
    required this.maDon,
    required this.tenChuNuoi,
    required this.dichVu,
    required this.trangThai,
    required this.batDau,
    required this.pets,
    required this.soTien,
    this.anhChuNuoi,
    this.ketThuc,
    this.soDem,
    this.thoiLuongPhut,
    this.ghiChu = GhiChuDon.khong,
    this.thucNhan = false,
    this.phutConLai,
    this.phutTruocKhiHuy,
  });

  final String id;
  final String maDon;
  final String tenChuNuoi;
  final String? anhChuNuoi;
  final LoaiDichVu dichVu;
  final SitterBookingStatus trangThai;
  final DateTime batDau;
  final DateTime? ketThuc;
  // Trông giữ tính theo đêm
  final int? soDem;
  final int? thoiLuongPhut;
  final List<PetBrief> pets;
  final GhiChuDon ghiChu;
  final int soTien;
  final bool thucNhan;
  final int? phutConLai;
  final int? phutTruocKhiHuy;

  SitterBooking copyWith({
    String? id,
    String? maDon,
    String? tenChuNuoi,
    String? anhChuNuoi,
    LoaiDichVu? dichVu,
    SitterBookingStatus? trangThai,
    DateTime? batDau,
    DateTime? ketThuc,
    int? soDem,
    int? thoiLuongPhut,
    List<PetBrief>? pets,
    GhiChuDon? ghiChu,
    int? soTien,
    bool? thucNhan,
    int? phutConLai,
    int? phutTruocKhiHuy,
  }) => SitterBooking(
    id: id ?? this.id,
    maDon: maDon ?? this.maDon,
    tenChuNuoi: tenChuNuoi ?? this.tenChuNuoi,
    anhChuNuoi: anhChuNuoi ?? this.anhChuNuoi,
    dichVu: dichVu ?? this.dichVu,
    trangThai: trangThai ?? this.trangThai,
    batDau: batDau ?? this.batDau,
    ketThuc: ketThuc ?? this.ketThuc,
    soDem: soDem ?? this.soDem,
    thoiLuongPhut: thoiLuongPhut ?? this.thoiLuongPhut,
    pets: pets ?? this.pets,
    ghiChu: ghiChu ?? this.ghiChu,
    soTien: soTien ?? this.soTien,
    thucNhan: thucNhan ?? this.thucNhan,
    phutConLai: phutConLai ?? this.phutConLai,
    phutTruocKhiHuy: phutTruocKhiHuy ?? this.phutTruocKhiHuy,
  );
}

extension SitterBookingHienThi on SitterBooking {
  String nhanThoiLuong(AppLocalizations l10n) => soDem != null
      ? l10n.nDemNhan('$soDem')
      : l10n.nPhutNhan('${thoiLuongPhut ?? 0}');

  String nhanThoiGian(AppLocalizations l10n) {
    if (soDem != null && ketThuc != null) {
      return '${_nhanNgay(l10n, batDau)} - ${_nhanNgay(l10n, ketThuc!)}'
          ' · ${l10n.nhanLucGio(gioPhut(batDau))}';
    }
    final khoang = ketThuc == null
        ? gioPhut(batDau)
        : '${gioPhut(batDau)} - ${gioPhut(ketThuc!)}';
    final duoi = _duoiThoiGian(l10n);
    final dong = '${_nhanNgay(l10n, batDau)} · $khoang';
    return duoi == null ? dong : '$dong · $duoi';
  }

  String nhanCacBe(AppLocalizations l10n) {
    if (pets.isEmpty) return '';
    if (pets.length == 1) return pets.first.name;
    return l10n.nBeVaTen('${pets.length}', pets.map((p) => p.name).join(', '));
  }

  String nhanCacBeVaGhiChu(AppLocalizations l10n) {
    final be = nhanCacBe(l10n);
    final chu = ghiChu.nhan(l10n);
    return chu == null ? be : '$be · $chu';
  }

  String get chuoiTimKiem =>
      '$tenChuNuoi $maDon ${pets.map((p) => p.name).join(' ')}';

  String _nhanNgay(AppLocalizations l10n, DateTime d) {
    final homNay = homNayVn();
    if (cungNgay(d, homNay)) return l10n.homNay;
    if (cungNgay(d, homNay.subtract(const Duration(days: 1)))) {
      return l10n.homQua;
    }
    return '${thuNgan(l10n, d)} ${ngayThang(d)}';
  }

  String? _duoiThoiGian(AppLocalizations l10n) => switch (trangThai) {
    SitterBookingStatus.choChuNuoiXacNhan => l10n.banDaXongViec,
    SitterBookingStatus.khieuNai => l10n.daXongViec,
    SitterBookingStatus.daHuy when phutTruocKhiHuy != null =>
      l10n.huyTruocKhoang(khoangTho(l10n, phutTruocKhiHuy!)),
    _ => null,
  };
}
