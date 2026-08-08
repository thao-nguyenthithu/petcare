import 'package:latlong2/latlong.dart';
import 'package:petcare_app/core/config/cau_hinh_nghiep_vu.dart';
import 'package:petcare_app/features/booking/data/owner_booking_parts.dart';
import 'package:petcare_app/shared/data/booking_common.dart';
import 'package:petcare_app/shared/data/pet.dart';
import 'package:petcare_app/shared/data/sitter_services.dart';

export 'package:petcare_app/features/booking/data/owner_booking_parts.dart';

enum BuocDon { daDat, daNhan, dangDienRa, hoanThanh }

enum TinhTrangDon {
  choXacNhan,
  daXacNhan,
  dangToi,
  denMuon,
  quaGioHen,
  dangDienRa,
  choBanXacNhan,
  hoanThanh,
  daHuy,
  khongRo,
}

typedef PhienDangChay = ({
  String gioBatDau,
  double kmDaDi,
  int phutConLai,
  int giayCapNhat,
});

class OwnerBookingDetail {
  const OwnerBookingDetail({
    required this.id,
    required this.maDon,
    required this.tinhTrang,
    required this.loai,
    required this.tenDichVu,
    required this.pets,
    required this.tenNcc,
    required this.ratingNcc,
    required this.soDanhGiaNcc,
    required this.moTaThoiGian,
    required this.diaDiem,
    required this.ghiChu,
    required this.dongTien,
    required this.tongTien,
    this.avatarNcc,
    this.sitterId,
    this.viTri,
    this.thongTinHuy,
    this.goiYNcc = const [],
    this.mocPhu,
    this.phutDenMuon,
    this.gioDuKien,
    this.gioKhoiHanh,
    this.gioHen,
    this.phutKhoiHanhTre,
    this.gioHienTai,
    this.phutQuaHen,
    this.kmLanCuoi,
    this.gioGhiNhanCuoi,
    this.phien,
    this.xacMinh = const [],
    this.dienBien = const [],
    this.anhNhatKy = const [],
    this.tongAnh = 0,
    this.ketQua,
    this.ghiChuNcc,
    this.gioHoanThanh,
    this.ngayHoanThanh,
    this.goiTungBe = const [],
    this.gioXongDuKien,
    this.anhTruoc = const [],
    this.anhSau = const [],
    this.moTaTraBe,
    this.soDem,
    this.mocNhanBe,
    this.mocTraBe,
    this.diaDiemPhu,
    this.gioMoChiDuong,
    this.ngayMoChiDuong,
    this.diaChiDayDu,
    this.gioNhanBe,
    this.gioToiNoi,
    this.gioMoBaoKhongCoNha,
    this.demHienTai,
    this.laNgayCuoiKy = false,
    this.gioTraBe,
    this.ngayTraNgan,
    this.conLaiToiTra,
    this.ghiChuMoiNhat,
    this.gioGhiChuMoiNhat,
    this.gioMoChiDuongDon,
    this.daChotKetThucSom = false,
    this.gioChotKetThucSom,
    this.gioDonMoi,
    this.moTaTraGoc,
    this.dongHoanTien = const [],
    this.tienHoan,
    this.dangDiDonBe = false,
    this.dangNhanBeVe = false,
    this.kmConToiDon,
    this.phutConToiDon,
    this.nhatKyKyGiu = const [],
    this.chinhSachHuy,
    this.gioGiuTien = gioGiuTienMacDinh,
    this.phanTramPhiHuy = phiHuyMuonMacDinh,
  });

  final String id;
  final String maDon;
  final TinhTrangDon tinhTrang;
  final ServiceType loai;

  final String tenDichVu;
  final List<Pet> pets;

  final String tenNcc;
  final String? avatarNcc;

  final String? sitterId;
  final double ratingNcc;
  final int soDanhGiaNcc;

  final String moTaThoiGian;
  final String? moTaTraBe;
  final int? soDem;

  final DateTime? mocNhanBe;
  final DateTime? mocTraBe;

  final String? diaDiemPhu;

  final String? diaChiDayDu;

  final String? gioNhanBe;

  final String? gioToiNoi;

  final String? gioMoBaoKhongCoNha;

  final int? demHienTai;
  final bool laNgayCuoiKy;
  final String? gioTraBe;
  final String? ngayTraNgan;
  final String? conLaiToiTra;

  final String? ghiChuMoiNhat;
  final String? gioGhiChuMoiNhat;

  final String? gioMoChiDuongDon;
  bool get chiDuongDonDaMo => gioMoChiDuongDon == null;

  final bool dangDiDonBe;
  final bool dangNhanBeVe;
  final double? kmConToiDon;
  final int? phutConToiDon;
  final List<NgayNhatKyGiu> nhatKyKyGiu;

  final bool daChotKetThucSom;
  final String? gioChotKetThucSom;
  final String? gioDonMoi;
  final String? moTaTraGoc;
  final List<DongHoaDon> dongHoanTien;
  final int? tienHoan;

  final String? gioMoChiDuong;
  final String? ngayMoChiDuong;

  bool get chiDuongDaMo => gioMoChiDuong == null;

  final String? gioXongDuKien;
  final String diaDiem;

  final LatLng? viTri;
  final String ghiChu;

  final List<DongHoaDon> dongTien;
  final int tongTien;

  final ThongTinHuy? thongTinHuy;

  final ChinhSachHuyDon? chinhSachHuy;

  final int gioGiuTien;
  final int phanTramPhiHuy;

  final PhienDangChay? phien;

  final List<MucXacMinh> xacMinh;

  final List<MocDienBien> dienBien;

  final List<String> anhNhatKy;
  final int tongAnh;

  final List<String> anhTruoc;
  final List<String> anhSau;

  bool get coAnhTruocSau => anhTruoc.isNotEmpty || anhSau.isNotEmpty;

  final KetQuaPhien? ketQua;

  final String? ghiChuNcc;

  final String? gioHoanThanh;
  final String? ngayHoanThanh;

  final List<GoiCuaBe> goiTungBe;

  final List<GoiYNcc> goiYNcc;

  final String? mocPhu;

  final int? phutDenMuon;
  final String? gioDuKien;

  final String? gioKhoiHanh;
  final String? gioHen;

  final int? phutKhoiHanhTre;

  final String? gioHienTai;
  final int? phutQuaHen;

  final double? kmLanCuoi;
  final String? gioGhiNhanCuoi;

  bool get huyMienPhiDoNcc => tinhTrang == TinhTrangDon.quaGioHen;

  bool get coTheBaoChuaToi => huyMienPhiDoNcc && loai != ServiceType.boarding;

  bool get daHuy => tinhTrang == TinhTrangDon.daHuy;

  bool get chuaDocDuoc => tinhTrang == TinhTrangDon.khongRo;

  bool get dangChay => tinhTrang == TinhTrangDon.dangDienRa;
  bool get choBanChot => tinhTrang == TinhTrangDon.choBanXacNhan;
  bool get daXong => tinhTrang == TinhTrangDon.hoanThanh;

  bool get daBatDau => dangChay || choBanChot || daXong;

  OwnerBookingDetail copyWith({
    String? maDon,
    TinhTrangDon? tinhTrang,
    ServiceType? loai,
    String? tenDichVu,
    List<Pet>? pets,
    String? tenNcc,
    double? ratingNcc,
    int? soDanhGiaNcc,
    String? moTaThoiGian,
    String? diaDiem,
    String? ghiChu,
    List<DongHoaDon>? dongTien,
    int? tongTien,
    String? avatarNcc,
    String? sitterId,
    LatLng? viTri,
    ThongTinHuy? thongTinHuy,
    List<GoiYNcc>? goiYNcc,
    String? mocPhu,
    int? phutDenMuon,
    String? gioDuKien,
    String? gioKhoiHanh,
    String? gioHen,
    int? phutKhoiHanhTre,
    String? gioHienTai,
    int? phutQuaHen,
    double? kmLanCuoi,
    String? gioGhiNhanCuoi,
    PhienDangChay? phien,
    List<MucXacMinh>? xacMinh,
    List<MocDienBien>? dienBien,
    List<String>? anhNhatKy,
    int? tongAnh,
    KetQuaPhien? ketQua,
    String? ghiChuNcc,
    String? gioHoanThanh,
    String? ngayHoanThanh,
    List<GoiCuaBe>? goiTungBe,
    String? gioXongDuKien,
    List<String>? anhTruoc,
    List<String>? anhSau,
    String? moTaTraBe,
    int? soDem,
    DateTime? mocNhanBe,
    DateTime? mocTraBe,
    String? diaDiemPhu,
    String? gioMoChiDuong,
    String? ngayMoChiDuong,
    String? diaChiDayDu,
    String? gioNhanBe,
    String? gioToiNoi,
    String? gioMoBaoKhongCoNha,
    int? demHienTai,
    bool? laNgayCuoiKy,
    String? gioTraBe,
    String? ngayTraNgan,
    String? conLaiToiTra,
    String? ghiChuMoiNhat,
    String? gioGhiChuMoiNhat,
    String? gioMoChiDuongDon,
    bool? daChotKetThucSom,
    String? gioChotKetThucSom,
    String? gioDonMoi,
    String? moTaTraGoc,
    List<DongHoaDon>? dongHoanTien,
    int? tienHoan,
    bool? dangDiDonBe,
    bool? dangNhanBeVe,
    double? kmConToiDon,
    int? phutConToiDon,
    List<NgayNhatKyGiu>? nhatKyKyGiu,
    ChinhSachHuyDon? chinhSachHuy,
    int? gioGiuTien,
    int? phanTramPhiHuy,
  }) => OwnerBookingDetail(
    id: id,
    maDon: maDon ?? this.maDon,
    tinhTrang: tinhTrang ?? this.tinhTrang,
    loai: loai ?? this.loai,
    tenDichVu: tenDichVu ?? this.tenDichVu,
    pets: pets ?? this.pets,
    tenNcc: tenNcc ?? this.tenNcc,
    ratingNcc: ratingNcc ?? this.ratingNcc,
    soDanhGiaNcc: soDanhGiaNcc ?? this.soDanhGiaNcc,
    moTaThoiGian: moTaThoiGian ?? this.moTaThoiGian,
    diaDiem: diaDiem ?? this.diaDiem,
    ghiChu: ghiChu ?? this.ghiChu,
    dongTien: dongTien ?? this.dongTien,
    tongTien: tongTien ?? this.tongTien,
    avatarNcc: avatarNcc ?? this.avatarNcc,
    sitterId: sitterId ?? this.sitterId,
    viTri: viTri ?? this.viTri,
    thongTinHuy: thongTinHuy ?? this.thongTinHuy,
    goiYNcc: goiYNcc ?? this.goiYNcc,
    mocPhu: mocPhu ?? this.mocPhu,
    phutDenMuon: phutDenMuon ?? this.phutDenMuon,
    gioDuKien: gioDuKien ?? this.gioDuKien,
    gioKhoiHanh: gioKhoiHanh ?? this.gioKhoiHanh,
    gioHen: gioHen ?? this.gioHen,
    phutKhoiHanhTre: phutKhoiHanhTre ?? this.phutKhoiHanhTre,
    gioHienTai: gioHienTai ?? this.gioHienTai,
    phutQuaHen: phutQuaHen ?? this.phutQuaHen,
    kmLanCuoi: kmLanCuoi ?? this.kmLanCuoi,
    gioGhiNhanCuoi: gioGhiNhanCuoi ?? this.gioGhiNhanCuoi,
    phien: phien ?? this.phien,
    xacMinh: xacMinh ?? this.xacMinh,
    dienBien: dienBien ?? this.dienBien,
    anhNhatKy: anhNhatKy ?? this.anhNhatKy,
    tongAnh: tongAnh ?? this.tongAnh,
    ketQua: ketQua ?? this.ketQua,
    ghiChuNcc: ghiChuNcc ?? this.ghiChuNcc,
    gioHoanThanh: gioHoanThanh ?? this.gioHoanThanh,
    ngayHoanThanh: ngayHoanThanh ?? this.ngayHoanThanh,
    goiTungBe: goiTungBe ?? this.goiTungBe,
    gioXongDuKien: gioXongDuKien ?? this.gioXongDuKien,
    anhTruoc: anhTruoc ?? this.anhTruoc,
    anhSau: anhSau ?? this.anhSau,
    moTaTraBe: moTaTraBe ?? this.moTaTraBe,
    soDem: soDem ?? this.soDem,
    mocNhanBe: mocNhanBe ?? this.mocNhanBe,
    mocTraBe: mocTraBe ?? this.mocTraBe,
    diaDiemPhu: diaDiemPhu ?? this.diaDiemPhu,
    gioMoChiDuong: gioMoChiDuong ?? this.gioMoChiDuong,
    ngayMoChiDuong: ngayMoChiDuong ?? this.ngayMoChiDuong,
    diaChiDayDu: diaChiDayDu ?? this.diaChiDayDu,
    gioNhanBe: gioNhanBe ?? this.gioNhanBe,
    gioToiNoi: gioToiNoi ?? this.gioToiNoi,
    gioMoBaoKhongCoNha: gioMoBaoKhongCoNha ?? this.gioMoBaoKhongCoNha,
    demHienTai: demHienTai ?? this.demHienTai,
    laNgayCuoiKy: laNgayCuoiKy ?? this.laNgayCuoiKy,
    gioTraBe: gioTraBe ?? this.gioTraBe,
    ngayTraNgan: ngayTraNgan ?? this.ngayTraNgan,
    conLaiToiTra: conLaiToiTra ?? this.conLaiToiTra,
    ghiChuMoiNhat: ghiChuMoiNhat ?? this.ghiChuMoiNhat,
    gioGhiChuMoiNhat: gioGhiChuMoiNhat ?? this.gioGhiChuMoiNhat,
    gioMoChiDuongDon: gioMoChiDuongDon ?? this.gioMoChiDuongDon,
    daChotKetThucSom: daChotKetThucSom ?? this.daChotKetThucSom,
    gioChotKetThucSom: gioChotKetThucSom ?? this.gioChotKetThucSom,
    gioDonMoi: gioDonMoi ?? this.gioDonMoi,
    moTaTraGoc: moTaTraGoc ?? this.moTaTraGoc,
    dongHoanTien: dongHoanTien ?? this.dongHoanTien,
    tienHoan: tienHoan ?? this.tienHoan,
    dangDiDonBe: dangDiDonBe ?? this.dangDiDonBe,
    dangNhanBeVe: dangNhanBeVe ?? this.dangNhanBeVe,
    kmConToiDon: kmConToiDon ?? this.kmConToiDon,
    phutConToiDon: phutConToiDon ?? this.phutConToiDon,
    nhatKyKyGiu: nhatKyKyGiu ?? this.nhatKyKyGiu,
    chinhSachHuy: chinhSachHuy ?? this.chinhSachHuy,
    gioGiuTien: gioGiuTien ?? this.gioGiuTien,
    phanTramPhiHuy: phanTramPhiHuy ?? this.phanTramPhiHuy,
  );

  OwnerBookingDetail themThongTinHuy({
    required ThongTinHuy thongTinHuy,
    List<GoiYNcc> goiYNcc = const [],
  }) => copyWith(thongTinHuy: thongTinHuy, goiYNcc: goiYNcc);

  BuocDon get buocHienTai => switch (tinhTrang) {
    TinhTrangDon.choXacNhan => BuocDon.daNhan,
    TinhTrangDon.choBanXacNhan || TinhTrangDon.hoanThanh => BuocDon.hoanThanh,
    _ => BuocDon.dangDienRa,
  };

  int get soBuocXong => switch (tinhTrang) {
    TinhTrangDon.choXacNhan => 1,
    TinhTrangDon.dangDienRa => 2,
    TinhTrangDon.choBanXacNhan => 3,
    TinhTrangDon.hoanThanh => 4,
    TinhTrangDon.khongRo => 0,
    _ => 2,
  };

  int get tienHoanLai => tongTien - (thongTinHuy?.phiHuy ?? 0);

  bool get canMucAnToan => loai == ServiceType.walking;

  bool get coTheoDoiBanDo => loai == ServiceType.walking;

  bool get canXacMinhDungCu => loai == ServiceType.walking;

  bool get chuNuoiPhaiDi => loai == ServiceType.boarding;

  bool get dangChoToiGio => daNhanDon && !daBatDau && !daHuy;

  bool get dangGiaoBe => chuNuoiPhaiDi && tinhTrang == TinhTrangDon.denMuon;
  bool get choNhanBeQuaLau =>
      chuNuoiPhaiDi && tinhTrang == TinhTrangDon.quaGioHen;

  bool get daToiNoi => dangGiaoBe || choNhanBeQuaLau;

  bool get daNhanDon =>
      tinhTrang != TinhTrangDon.choXacNhan && tinhTrang != TinhTrangDon.daHuy;
}
