import 'package:petcare_app/shared/data/pet.dart';
import 'package:petcare_app/shared/data/sitter_services.dart';

enum BenHuy {
  chuNuoi,
  nguoiCham,
  nccChuaToi,
  heThongNccChuaToi,
  heThongKhongBatDau,
  heThongHetHan,
  heThongNccBan,
  chuNuoiVangMat,
  quanTri,
}

typedef ThongTinHuy = ({
  BenHuy ben,
  DateTime? mocHuy,
  String gioHuy,
  String ngayHuy,
  String lyDo,
  int phiHuy,
  String truocGioHen,
});

typedef GoiYNcc = ({
  String? sitterId,
  String? avatar,
  String ten,
  double rating,
  int soDanhGia,
  double km,
  int gia,
});

// Nhật ký kỳ giữ
typedef MucNhatKyGiu = ({String gio, List<String> anh, String ghiChu});
typedef NgayNhatKyGiu = ({String nhan, List<MucNhatKyGiu> muc});

typedef GoiCuaBe = ({Pet be, GroomingPackage goi, int gia});

// Chính sách huỷ
typedef ChinhSachHuyDon = ({
  DateTime? hanMienPhiAt,
  bool laDatGap,
  DateTime? hetAnHanDatGapAt,
  bool mienPhi,
  bool coTheHuy,
  int phiHuy,
  int tienHoan,
});
