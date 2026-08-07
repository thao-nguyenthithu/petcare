import 'package:petcare_app/core/l10n/generated/app_localizations.dart';
import 'package:petcare_app/shared/data/booking_common.dart';
import 'package:petcare_app/shared/data/service_catalog.dart';
import 'package:petcare_app/shared/data/sitter_booking.dart';
import 'package:petcare_app/shared/data/vi_chung.dart';

// Cụm THANH TOÁN của chủ nuôi
enum LoaiGiaoDichChuNuoi { thanhToan, hoanTien }

extension LoaiGiaoDichChuNuoiHienThi on LoaiGiaoDichChuNuoi {
  String nhan(AppLocalizations l10n) => switch (this) {
    LoaiGiaoDichChuNuoi.thanhToan => l10n.thanhToan,
    LoaiGiaoDichChuNuoi.hoanTien => l10n.hoanTien,
  };
}

class KhoanTamGiuChuNuoi {
  const KhoanTamGiuChuNuoi({
    required this.don,
    required this.soTien,
    required this.dangKhieuNai,
  });

  final SitterBooking don;
  final int soTien;
  final bool dangKhieuNai;
}

class GiaoDichChuNuoi {
  const GiaoDichChuNuoi({
    required this.ma,
    required this.loai,
    required this.tieuDe,
    required this.soTien,
    required this.thoiDiem,
    required this.moTaMoc,
    this.don,
    this.nganHang,
    this.maKhieuNai,
  });

  final String ma;
  final LoaiGiaoDichChuNuoi loai;
  final String tieuDe;
  final int soTien;
  final DateTime thoiDiem;
  final String moTaMoc;
  final SitterBooking? don;
  final String? nganHang;
  final String? maKhieuNai;
  bool get laTienVao => soTien > 0;
}

class ChiTietGiaoDichChuNuoi {
  const ChiTietGiaoDichChuNuoi({
    required this.giaoDich,
    required this.nhanTrangThai,
    required this.tieuDeKhoiTien,
    required this.cacDongTien,
    required this.tongCuoi,
    required this.dienBien,
    required this.thongTinKhac,
    required this.nhanNutDay,
    this.tieuDeGiaiThich,
    this.giaiThich,
  });

  final GiaoDichChuNuoi giaoDich;
  final String nhanTrangThai;
  final String tieuDeKhoiTien;
  final List<DongHoaDon> cacDongTien;
  final DongHoaDon tongCuoi;
  final List<MocViDien> dienBien;
  final List<({String nhan, String giaTri})> thongTinKhac;
  final String nhanNutDay;
  final String? tieuDeGiaiThich;
  final String? giaiThich;
}

typedef ChiTieuTheoDichVu = ({LoaiDichVu dichVu, int soDon, int soTien});

class ThanhToanChuNuoi {
  const ThanhToanChuNuoi({
    required this.thangHienTai,
    required this.khoanTamGiu,
    required this.chiTieuThangNay,
  });

  final int thangHienTai;
  final List<KhoanTamGiuChuNuoi> khoanTamGiu;
  final int chiTieuThangNay;

  int get tongTamGiu => khoanTamGiu.fold(0, (t, k) => t + k.soTien);

  List<KhoanTamGiuChuNuoi> get dangGiu =>
      khoanTamGiu.where((k) => !k.dangKhieuNai).toList();

  List<KhoanTamGiuChuNuoi> get dangKhieuNai =>
      khoanTamGiu.where((k) => k.dangKhieuNai).toList();
}
