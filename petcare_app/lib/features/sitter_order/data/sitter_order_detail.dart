import 'package:latlong2/latlong.dart';
import 'package:petcare_app/core/config/cau_hinh_nghiep_vu.dart';
import 'package:petcare_app/features/sitter_order/data/sitter_order_parts.dart';
import 'package:petcare_app/shared/data/booking_common.dart';
import 'package:petcare_app/shared/data/pet.dart';
import 'package:petcare_app/shared/data/sitter_services.dart';

export 'package:petcare_app/features/sitter_order/data/sitter_order_parts.dart';

const int phutMoNutBatDau = 15;
const int soAnhChungMinhToiDa = 3;
const int metGeofence = 200;
const int phutAnHanNhanBe = 15;

enum TinhTrangDonNcc {
  choXacNhan,
  daNhanDon,
  dangToi,
  daBaoMuon,
  quaHenNhanBe,
  daToiDiemDon,
  dangDat,
  choChuNuoiXacNhan,
  hoanThanh,
  hetHanNhan,
  banDaHuy,
  khachHuy,
  khachVangMat,
  tuHuyTrungLich,
  huyBoiQuanTri,
  khongRo,
}

extension TinhTrangDonNccMa on TinhTrangDonNcc {
  String get ma => switch (this) {
    TinhTrangDonNcc.choXacNhan => 'cho-xac-nhan',
    TinhTrangDonNcc.daNhanDon => 'da-nhan',
    TinhTrangDonNcc.dangToi => 'dang-toi',
    TinhTrangDonNcc.daBaoMuon => 'da-bao-muon',
    TinhTrangDonNcc.quaHenNhanBe => 'qua-hen',
    TinhTrangDonNcc.daToiDiemDon => 'da-toi',
    TinhTrangDonNcc.dangDat => 'dang-dat',
    TinhTrangDonNcc.choChuNuoiXacNhan => 'cho-chot',
    TinhTrangDonNcc.hoanThanh => 'hoan-thanh',
    TinhTrangDonNcc.hetHanNhan => 'het-han',
    TinhTrangDonNcc.banDaHuy => 'ban-huy',
    TinhTrangDonNcc.khachHuy => 'khach-huy',
    TinhTrangDonNcc.khachVangMat => 'khach-vang-mat',
    TinhTrangDonNcc.tuHuyTrungLich => 'tu-huy-trung-lich',
    TinhTrangDonNcc.huyBoiQuanTri => 'quan-tri-huy',
    TinhTrangDonNcc.khongRo => 'khong-ro',
  };
}

// Mọi số đã chốt, màn chỉ tính thêm phí nền tảng
class SitterOrderDetail {
  const SitterOrderDetail({
    required this.bookingId,
    required this.maDon,
    required this.tinhTrang,
    required this.loai,
    required this.tenDichVu,
    required this.pets,
    required this.tenChuNuoi,
    required this.soDonDaDat,
    required this.gioHen,
    required this.ngayNganHen,
    required this.moTaThoiGian,
    required this.kmToiDiemDon,
    required this.khuVucDiemDon,
    required this.ghiChu,
    required this.dongTien,
    required this.tongTien,
    this.phanTramPhiNenTang = phiNenTangMacDinh,
    this.phanTramPhiHuy = phiHuyMuonMacDinh,
    this.gioGiuTien = gioGiuTienMacDinh,
    this.tranTyLeHuy = tranTyLeHuyMacDinh,
    this.avatarChuNuoi,
    this.diaChiDayDu,
    this.viTri,
    this.mocPhu,
    this.gioMoChiDuong,
    this.ngayMoChiDuong,
    this.gioMoXuatPhat,
    this.gioMoBatDau,
    this.phutBaoMuon,
    this.gioDuKienToi,
    this.gioDaBaoMuon,
    this.gioToiNoi,
    this.metCachDiemDon,
    this.gioMoBaoVangMat,
    this.gioBatDauPhien,
    this.gioXacMinhDungCu,
    this.kmDaDi,
    this.phutThucHien,
    this.phutConLai,
    this.gioMoKetThuc,
    this.anhNhatKy = const [],
    this.tongAnhNhatKy = 0,
    this.gioHetHan,
    this.ngayHetHan,
    this.tienHuyBanNhan = 0,
    this.lyDoHuy,
    this.ketQua,
    this.grooming,
    this.trongGiu,
    this.dienBien = const [],
    this.anhTruoc = const [],
    this.tongAnhTruoc = 0,
    this.anhSau = const [],
    this.tongAnhSau = 0,
  });

  // Id đơn trên server, mọi màn dựng đường dẫn từ đây
  final String bookingId;
  final String maDon;
  final TinhTrangDonNcc tinhTrang;
  final ServiceType loai;
  final String tenDichVu;
  final List<Pet> pets;
  final String tenChuNuoi;
  final String? avatarChuNuoi;
  final int soDonDaDat;
  final String gioHen;
  final String ngayNganHen;
  final String moTaThoiGian;
  final double kmToiDiemDon;
  final String khuVucDiemDon;
  final String? diaChiDayDu;
  final LatLng? viTri;

  final String ghiChu;
  final List<DongHoaDon> dongTien;
  final int tongTien;
  final int phanTramPhiNenTang;
  final int phanTramPhiHuy;
  final int gioGiuTien;
  final int tranTyLeHuy;
  final String? mocPhu;
  final String? gioMoChiDuong;
  final String? ngayMoChiDuong;
  final String? gioMoXuatPhat;
  bool get moXuatPhat => gioMoXuatPhat == null;

  final String? gioMoBatDau;
  bool get moBatDau => gioMoBatDau == null;

  final int? phutBaoMuon;
  final String? gioDuKienToi;
  final String? gioDaBaoMuon;

  final String? gioToiNoi;
  final int? metCachDiemDon;

  final String? gioMoBaoVangMat;

  final String? gioBatDauPhien;
  final String? gioXacMinhDungCu;

  final double? kmDaDi;

  final int? phutThucHien;

  final int? phutConLai;

  final String? gioMoKetThuc;

  final List<String> anhNhatKy;
  final int tongAnhNhatKy;
  final String? gioHetHan;
  final String? ngayHetHan;

  final int tienHuyBanNhan;

  final String? lyDoHuy;

  final KetQuaPhien? ketQua;

  final ThongTinGrooming? grooming;

  final ThongTinTrongGiu? trongGiu;

  final List<MocDienBien> dienBien;

  final List<String> anhTruoc;
  final int tongAnhTruoc;
  final List<String> anhSau;
  final int tongAnhSau;

  bool get daNhanDon => tinhTrang != TinhTrangDonNcc.choXacNhan && !daBoDangDo;

  bool get daBoDangDo => switch (tinhTrang) {
    TinhTrangDonNcc.hetHanNhan ||
    TinhTrangDonNcc.banDaHuy ||
    TinhTrangDonNcc.khachHuy ||
    TinhTrangDonNcc.khachVangMat ||
    TinhTrangDonNcc.tuHuyTrungLich ||
    TinhTrangDonNcc.huyBoiQuanTri ||
    TinhTrangDonNcc.khongRo => true,
    _ => false,
  };

  bool get daHetHan => tinhTrang == TinhTrangDonNcc.hetHanNhan;

  bool get daXuatPhat =>
      tinhTrang == TinhTrangDonNcc.dangToi ||
      tinhTrang == TinhTrangDonNcc.daBaoMuon ||
      tinhTrang == TinhTrangDonNcc.daToiDiemDon;

  bool get daToiNoi => tinhTrang == TinhTrangDonNcc.daToiDiemDon;

  bool get dangDat => tinhTrang == TinhTrangDonNcc.dangDat;

  bool get choChot => tinhTrang == TinhTrangDonNcc.choChuNuoiXacNhan;

  bool get laGrooming => loai == ServiceType.grooming;
  bool get laTrongGiu => loai == ServiceType.boarding;

  bool get daHoanThanh => tinhTrang == TinhTrangDonNcc.hoanThanh;

  bool get quaHenNhanBe => tinhTrang == TinhTrangDonNcc.quaHenNhanBe;

  bool get daChotKetThucSom => trongGiu?.ketThucSom != null;

  bool get duGioKetThuc => gioMoKetThuc == null;

  bool get daBaoMuon => tinhTrang == TinhTrangDonNcc.daBaoMuon;

  bool get daMoDiaChi => viTri != null;

  bool get canCamKetAnToan =>
      loai == ServiceType.walking && tinhTrang == TinhTrangDonNcc.choXacNhan;

  bool get coKhoiDuongDi =>
      !laTrongGiu && daNhanDon && !daToiNoi && !dangDat && !choChot;

  bool get chiDuongDaMo => gioMoChiDuong == null;

  int get phiNenTang => tongTien * phanTramPhiNenTang ~/ 100;
  int get thucNhan => tongTien - phiNenTang;

  Set<int> get mocXong => switch (tinhTrang) {
    TinhTrangDonNcc.choXacNhan => const {0},
    TinhTrangDonNcc.hetHanNhan ||
    TinhTrangDonNcc.tuHuyTrungLich ||
    TinhTrangDonNcc.huyBoiQuanTri => const {0, 3},
    TinhTrangDonNcc.khongRo => const {},
    TinhTrangDonNcc.banDaHuy ||
    TinhTrangDonNcc.khachHuy ||
    TinhTrangDonNcc.khachVangMat => const {0, 1, 3},
    TinhTrangDonNcc.choChuNuoiXacNhan => const {0, 1, 2},
    TinhTrangDonNcc.hoanThanh => const {0, 1, 2, 3},
    _ => const {0, 1},
  };

  int? get mocDangO => switch (tinhTrang) {
    TinhTrangDonNcc.choXacNhan => 1,
    TinhTrangDonNcc.hoanThanh => null,
    TinhTrangDonNcc.choChuNuoiXacNhan => 3,
    _ => daBoDangDo ? null : 2,
  };

  SitterOrderDetail copyWith({
    String? bookingId,
    String? maDon,
    TinhTrangDonNcc? tinhTrang,
    ServiceType? loai,
    String? tenDichVu,
    List<Pet>? pets,
    String? tenChuNuoi,
    int? soDonDaDat,
    String? gioHen,
    String? ngayNganHen,
    String? moTaThoiGian,
    double? kmToiDiemDon,
    String? khuVucDiemDon,
    String? ghiChu,
    List<DongHoaDon>? dongTien,
    int? tongTien,
    int? phanTramPhiNenTang,
    int? phanTramPhiHuy,
    int? gioGiuTien,
    int? tranTyLeHuy,
    String? avatarChuNuoi,
    String? diaChiDayDu,
    LatLng? viTri,
    String? mocPhu,
    String? gioMoChiDuong,
    String? ngayMoChiDuong,
    String? gioMoXuatPhat,
    String? gioMoBatDau,
    int? phutBaoMuon,
    String? gioDuKienToi,
    String? gioDaBaoMuon,
    String? gioToiNoi,
    int? metCachDiemDon,
    String? gioMoBaoVangMat,
    String? gioBatDauPhien,
    String? gioXacMinhDungCu,
    double? kmDaDi,
    int? phutThucHien,
    int? phutConLai,
    String? gioMoKetThuc,
    List<String>? anhNhatKy,
    int? tongAnhNhatKy,
    String? gioHetHan,
    String? ngayHetHan,
    int? tienHuyBanNhan,
    String? lyDoHuy,
    KetQuaPhien? ketQua,
    ThongTinGrooming? grooming,
    ThongTinTrongGiu? trongGiu,
    List<MocDienBien>? dienBien,
    List<String>? anhTruoc,
    int? tongAnhTruoc,
    List<String>? anhSau,
    int? tongAnhSau,
    bool xoaMocChiDuong = false,
    bool xoaMocPhu = false,
    bool xoaMocKetThuc = false,
    bool xoaMocXuatPhat = false,
    bool xoaMocBatDau = false,
  }) => SitterOrderDetail(
    bookingId: bookingId ?? this.bookingId,
    maDon: maDon ?? this.maDon,
    tinhTrang: tinhTrang ?? this.tinhTrang,
    loai: loai ?? this.loai,
    tenDichVu: tenDichVu ?? this.tenDichVu,
    pets: pets ?? this.pets,
    tenChuNuoi: tenChuNuoi ?? this.tenChuNuoi,
    soDonDaDat: soDonDaDat ?? this.soDonDaDat,
    gioHen: gioHen ?? this.gioHen,
    ngayNganHen: ngayNganHen ?? this.ngayNganHen,
    moTaThoiGian: moTaThoiGian ?? this.moTaThoiGian,
    kmToiDiemDon: kmToiDiemDon ?? this.kmToiDiemDon,
    khuVucDiemDon: khuVucDiemDon ?? this.khuVucDiemDon,
    ghiChu: ghiChu ?? this.ghiChu,
    dongTien: dongTien ?? this.dongTien,
    tongTien: tongTien ?? this.tongTien,
    phanTramPhiNenTang: phanTramPhiNenTang ?? this.phanTramPhiNenTang,
    phanTramPhiHuy: phanTramPhiHuy ?? this.phanTramPhiHuy,
    gioGiuTien: gioGiuTien ?? this.gioGiuTien,
    tranTyLeHuy: tranTyLeHuy ?? this.tranTyLeHuy,
    avatarChuNuoi: avatarChuNuoi ?? this.avatarChuNuoi,
    diaChiDayDu: diaChiDayDu ?? this.diaChiDayDu,
    viTri: viTri ?? this.viTri,
    mocPhu: xoaMocPhu ? null : (mocPhu ?? this.mocPhu),
    gioMoChiDuong: xoaMocChiDuong
        ? null
        : (gioMoChiDuong ?? this.gioMoChiDuong),
    ngayMoChiDuong: xoaMocChiDuong
        ? null
        : (ngayMoChiDuong ?? this.ngayMoChiDuong),
    gioMoXuatPhat: xoaMocXuatPhat
        ? null
        : (gioMoXuatPhat ?? this.gioMoXuatPhat),
    gioMoBatDau: xoaMocBatDau ? null : (gioMoBatDau ?? this.gioMoBatDau),
    phutBaoMuon: phutBaoMuon ?? this.phutBaoMuon,
    gioDuKienToi: gioDuKienToi ?? this.gioDuKienToi,
    gioDaBaoMuon: gioDaBaoMuon ?? this.gioDaBaoMuon,
    gioToiNoi: gioToiNoi ?? this.gioToiNoi,
    metCachDiemDon: metCachDiemDon ?? this.metCachDiemDon,
    gioMoBaoVangMat: gioMoBaoVangMat ?? this.gioMoBaoVangMat,
    gioBatDauPhien: gioBatDauPhien ?? this.gioBatDauPhien,
    gioXacMinhDungCu: gioXacMinhDungCu ?? this.gioXacMinhDungCu,
    kmDaDi: kmDaDi ?? this.kmDaDi,
    phutThucHien: phutThucHien ?? this.phutThucHien,
    phutConLai: phutConLai ?? this.phutConLai,
    gioMoKetThuc: xoaMocKetThuc ? null : (gioMoKetThuc ?? this.gioMoKetThuc),
    anhNhatKy: anhNhatKy ?? this.anhNhatKy,
    tongAnhNhatKy: tongAnhNhatKy ?? this.tongAnhNhatKy,
    gioHetHan: gioHetHan ?? this.gioHetHan,
    ngayHetHan: ngayHetHan ?? this.ngayHetHan,
    tienHuyBanNhan: tienHuyBanNhan ?? this.tienHuyBanNhan,
    lyDoHuy: lyDoHuy ?? this.lyDoHuy,
    ketQua: ketQua ?? this.ketQua,
    grooming: grooming ?? this.grooming,
    trongGiu: trongGiu ?? this.trongGiu,
    dienBien: dienBien ?? this.dienBien,
    anhTruoc: anhTruoc ?? this.anhTruoc,
    tongAnhTruoc: tongAnhTruoc ?? this.tongAnhTruoc,
    anhSau: anhSau ?? this.anhSau,
    tongAnhSau: tongAnhSau ?? this.tongAnhSau,
  );
}
