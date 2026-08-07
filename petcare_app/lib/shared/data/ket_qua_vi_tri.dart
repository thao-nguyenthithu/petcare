import 'package:latlong2/latlong.dart';

class KetQuaViTri {
  const KetQuaViTri({
    required this.viTri,
    this.moTa,
    this.soNhaDuong,
    this.phuong,
    this.tinh,
  });

  final LatLng viTri;
  final String? moTa;
  final String? soNhaDuong;
  final String? phuong;
  final String? tinh;
}
