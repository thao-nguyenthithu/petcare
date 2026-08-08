import 'package:petcare_app/core/config/cau_hinh_nghiep_vu.dart';

// Phí huỷ kỳ trông giữ
const int demTinhPhiToiDa = 7;
const int gioHanPhanDoiVangMat = 24;
const int soAnhMoKhieuNai = 6;
const int soAnhPhanHoiKhieuNai = 3;

int phiHuyCuaDon({
  required int tongTien,
  required bool laTrongGiu,
  required int soDem,
  int phanTramPhiHuy = phiHuyMuonMacDinh,
}) {
  if (!laTrongGiu || soDem < 1) return tongTien * phanTramPhiHuy ~/ 100;
  final giaMotDem = tongTien / soDem;
  final demTinhPhi = soDem < demTinhPhiToiDa ? soDem : demTinhPhiToiDa;
  return (giaMotDem * demTinhPhi * phanTramPhiHuy / 100).round();
}

typedef MucXacMinh = ({String ten, String gio, int doTinCay});
typedef MocDienBien = ({String gio, String viec, bool daXong});
typedef KetQuaPhien = ({int phut, double? km, int soAnh});
typedef DongHoaDon = ({String nhan, int tien});
