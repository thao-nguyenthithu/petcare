import 'package:petcare_app/core/l10n/generated/app_localizations.dart';
import 'package:petcare_app/shared/data/booking_common.dart';
import 'package:petcare_app/shared/data/sitter_booking.dart';
import 'package:petcare_app/shared/data/vi_chung.dart';

// Ba chip lọc ở màn Lịch sử giao dịch
enum LoaiGiaoDich { tienVao, rutRa, dieuChinh }

extension LoaiGiaoDichHienThi on LoaiGiaoDich {
  String nhan(AppLocalizations l10n) => switch (this) {
    LoaiGiaoDich.tienVao => l10n.tienVao,
    LoaiGiaoDich.rutRa => l10n.rutRa,
    LoaiGiaoDich.dieuChinh => l10n.dieuChinh,
  };
}

// Trạng thái khiếu nại nhìn từ phía người chăm
enum TrangThaiKhieuNai {
  choBanPhanHoi,
  choHoTroXuLy,
  daHoanMotPhan,
  khongChapNhan,
}

class KhoanGiuTam {
  const KhoanGiuTam({
    required this.don,
    required this.soTien,
    required this.dangKhieuNai,
    required this.motaMoc,
  });

  final SitterBooking don;
  final int soTien;
  final bool dangKhieuNai;
  final String motaMoc;
}

class GiaoDichVi {
  const GiaoDichVi({
    required this.ma,
    required this.loai,
    required this.tieuDe,
    required this.soTien,
    required this.thoiDiem,
    required this.moTaMoc,
    required this.soDuSau,
    this.don,
    this.moTaPhu,
    this.nganHang,
    this.maThamChieu,
    this.maKhieuNai,
  });

  final String ma;
  final LoaiGiaoDich loai;
  final String tieuDe;
  final int soTien;
  final DateTime thoiDiem;
  final String moTaMoc;
  final int soDuSau;
  final SitterBooking? don;
  final String? moTaPhu;
  final TaiKhoanNganHang? nganHang;
  final String? maThamChieu;
  final String? maKhieuNai;

  bool get laTienVao => soTien > 0;
}

class ChiTietGiaoDich {
  const ChiTietGiaoDich({
    required this.giaoDich,
    required this.mocTrangThai,
    required this.dongMot,
    required this.dongHai,
    required this.tong,
    required this.dienBien,
    this.ketLuan,
    this.chuNuoiPhanAnh,
  });

  final GiaoDichVi giaoDich;

  final String mocTrangThai;
  final int dongMot;
  final int dongHai;
  final int tong;
  final List<MocViDien> dienBien;
  final KetLuanHoTro? ketLuan;
  final String? chuNuoiPhanAnh;
}

class HoSoKhieuNai {
  const HoSoKhieuNai({
    required this.ma,
    required this.trangThai,
    required this.don,
    required this.soTien,
    required this.moTaMoc,
    required this.phanAnh,
    required this.thoiDiemPhanAnh,
    required this.dienBien,
    this.anhPhanAnh = const [],
    this.phanHoiCuaBan,
    this.thoiDiemPhanHoi,
    this.anhPhanHoi = const [],
    this.ketLuan,
    this.cacDongTien = const [],
    this.tongCuoi,
    this.hanPhanHoi,
    this.phutConLai,
    this.maGiaoDichLienQuan,
  });

  final String ma;
  final TrangThaiKhieuNai trangThai;
  final SitterBooking don;
  final int soTien;

  final String moTaMoc;
  final String phanAnh;
  final String thoiDiemPhanAnh;
  final List<String> anhPhanAnh;

  final String? phanHoiCuaBan;
  final String? thoiDiemPhanHoi;
  final List<String> anhPhanHoi;

  final KetLuanHoTro? ketLuan;
  final List<DongHoaDon> cacDongTien;
  final DongHoaDon? tongCuoi;

  final List<MocViDien> dienBien;

  final String? hanPhanHoi;
  final int? phutConLai;
  final String? maGiaoDichLienQuan;

  bool get dangCho =>
      trangThai == TrangThaiKhieuNai.choBanPhanHoi ||
      trangThai == TrangThaiKhieuNai.choHoTroXuLy;
}

class ViNguoiCham {
  const ViNguoiCham({
    required this.soDuKhaDung,
    required this.daNhanTrongThang,
    required this.thangHienTai,
    required this.khoanGiuTam,
    required this.thuNhapTuanNay,
    required this.cotTuanNay,
    required this.chiSoHomNay,
    this.nganHang,
  });

  final int soDuKhaDung;
  final int daNhanTrongThang;
  final int thangHienTai;
  final List<KhoanGiuTam> khoanGiuTam;
  final int thuNhapTuanNay;

  final List<int> cotTuanNay;

  final int chiSoHomNay;

  final TaiKhoanNganHang? nganHang;

  int get tongGiuTam => khoanGiuTam.fold(0, (tong, k) => tong + k.soTien);

  List<KhoanGiuTam> get sapVeVi =>
      khoanGiuTam.where((k) => !k.dangKhieuNai).toList();

  List<KhoanGiuTam> get dangKhieuNai =>
      khoanGiuTam.where((k) => k.dangKhieuNai).toList();
}
