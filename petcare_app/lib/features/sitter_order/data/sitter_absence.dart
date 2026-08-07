import 'package:petcare_app/features/sitter_order/data/sitter_order_detail.dart';
import 'package:petcare_app/shared/data/booking_common.dart';

const int phutChoBatBuoc = 15;
const int soAnhVangMatToiThieu = 1;
const int soAnhVangMatToiDa = 3;

enum LoaiBaoVangMat { toiBao, biBao }

extension LoaiBaoVangMatMa on LoaiBaoVangMat {
  String get ma => switch (this) {
    LoaiBaoVangMat.toiBao => 'toi-bao',
    LoaiBaoVangMat.biBao => 'bi-bao',
  };
}

// Dữ liệu của màn vắng mặt
class BaoVangMat {
  const BaoVangMat({
    required this.don,
    required this.loai,
    this.gioCoMat,
    this.phutDaCho = 0,
    this.metSaiLech = 0,
    this.gioChuNuoiBao,
    this.phutQuaHen = 0,
    this.gioViTriCuoi,
    this.kmViTriCuoi = 0,
    this.gioChuNuoiToiNha,
    this.gioChuNuoiChoDen,
  });

  final SitterOrderDetail don;
  final LoaiBaoVangMat loai;

  final String? gioCoMat;
  final int phutDaCho;
  final int metSaiLech;

  final String? gioChuNuoiBao;
  final int phutQuaHen;
  final String? gioViTriCuoi;
  final double kmViTriCuoi;

  final String? gioChuNuoiToiNha;
  final String? gioChuNuoiChoDen;

  // Vắng mặt đền như huỷ muộn cho mọi dịch vụ
  int get phiHuyChuNuoiChiu => phiHuyCuaDon(
    tongTien: don.tongTien,
    laTrongGiu: don.laTrongGiu,
    soDem: don.trongGiu?.soDem ?? 0,
    phanTramPhiHuy: don.phanTramPhiHuy,
  );
  int get phiNenTangTrenPhiHuy =>
      phiHuyChuNuoiChiu * don.phanTramPhiNenTang ~/ 100;
  int get banNhan => phiHuyChuNuoiChiu - phiNenTangTrenPhiHuy;
}
