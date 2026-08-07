import 'package:petcare_app/features/sitter_order/data/sitter_order_detail.dart';
import 'package:petcare_app/shared/data/booking_common.dart';

// Phút phải chờ trước khi được báo chủ nuôi vắng mặt
const int phutChoBatBuoc = 15;

// Ảnh kèm lời báo vắng mặt, phải thấy được điểm hẹn (bộ luật mục 8)
const int soAnhVangMatToiThieu = 1;
const int soAnhVangMatToiDa = 3;

// Hai chiều của tranh chấp không gặp nhau ở điểm hẹn
enum LoaiBaoVangMat {
  // Chờ đủ giờ mà chủ nuôi không ra giao bé
  toiBao,
  // Chủ nuôi báo chưa thấy người chăm, đơn đã huỷ
  biBao,
}

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

  // Chiều tôi báo: ba số này là bằng chứng
  final String? gioCoMat;
  final int phutDaCho;
  final int metSaiLech;

  // Chiều bị báo: mốc chủ nuôi bấm và vị trí cuối của tôi
  final String? gioChuNuoiBao;
  final int phutQuaHen;
  final String? gioViTriCuoi;
  final double kmViTriCuoi;

  // Kỳ trông giữ, chiều bị báo: bằng chứng từ máy chủ nuôi
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
