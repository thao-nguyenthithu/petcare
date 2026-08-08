import 'package:latlong2/latlong.dart';

enum NguonNoiTim { diaChiLuu, viTriHienTai, ghimTrenBanDo, vungDangXem }

// Chỗ đang lấy làm tâm tìm kiếm trên bản đồ
class NoiTimQuanh {
  const NoiTimQuanh({
    required this.nguon,
    required this.viTri,
    this.moTa,
    this.moTaPhu,
    this.idDiaChi,
  });

  static const LatLng macDinh = LatLng(21.028511, 105.804817);

  final NguonNoiTim nguon;
  final LatLng viTri;
  final String? moTa;
  final String? moTaPhu;
  final String? idDiaChi;

  bool get laDiaChiLuu => nguon == NguonNoiTim.diaChiLuu;
  bool get laVungDangXem => nguon == NguonNoiTim.vungDangXem;
}
