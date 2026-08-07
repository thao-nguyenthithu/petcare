import 'package:petcare_app/shared/data/booking_common.dart';

typedef MocViDien = ({String viec, String thoiDiem, bool daXong});

typedef KetLuanHoTro = ({
  String noiDung,
  String? lyDo,
  String nguoiXuLy,
  String thoiDiem,
});

class TaiKhoanNganHang {
  const TaiKhoanNganHang({
    required this.tenNganHang,
    required this.bonSoCuoi,
    required this.tenChuTaiKhoan,
    this.daXacThuc = false,
    this.soLuotConLai,
    this.soLuotMoiNgay,
  });

  final String tenNganHang;
  final String bonSoCuoi;
  final String tenChuTaiKhoan;
  final bool daXacThuc;
  final int? soLuotConLai;
  final int? soLuotMoiNgay;

  bool get conLuotRut => (soLuotConLai ?? 1) > 0;

  String get nhan => '$tenNganHang · $bonSoCuoi';
}

typedef DongTienVi = DongHoaDon;
