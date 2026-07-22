import 'package:dio/dio.dart';
import 'package:latlong2/latlong.dart';

class PhanTichDiaChi {
  const PhanTichDiaChi({this.moTa, this.soNhaDuong, this.phuong, this.tinh});

  final String? moTa;
  final String? soNhaDuong;
  final String? phuong;
  final String? tinh;
}

class GoiYDiaDiem {
  const GoiYDiaDiem({required this.ten, required this.viTri});

  final String ten;
  final LatLng viTri;
}

// Tra cứu địa chỉ qua Nominatim (OpenStreetMap)
class TraCuuDiaChiService {
  TraCuuDiaChiService._();

  static final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'https://nominatim.openstreetmap.org',
      headers: {'User-Agent': 'SmartPetCare/1.0 (petcare app)'},
    ),
  );

  static Future<PhanTichDiaChi?> traDiaChi(double lat, double lng) async {
    try {
      final res = await _dio.get(
        '/reverse',
        queryParameters: {
          'format': 'jsonv2',
          'lat': lat,
          'lon': lng,
          'accept-language': 'vi',
        },
      );
      final data = res.data;
      if (data is! Map) return null;
      final diaChi = data['address'];
      final a = diaChi is Map ? diaChi : const {};
      String? lay(List<String> khoa) {
        for (final k in khoa) {
          final v = a[k];
          if (v is String && v.trim().isNotEmpty) return v.trim();
        }
        return null;
      }

      final moTa = data['display_name'] is String
          ? data['display_name'] as String
          : null;
      final phuong = lay([
        'ward',
        'suburb',
        'quarter',
        'village',
        'neighbourhood',
        'city_district',
      ]);
      final tinh = lay(['city', 'state', 'town']);

      var soNhaDuong = _phanChiTiet(moTa, phuong, tinh);
      if (soNhaDuong == null || soNhaDuong.isEmpty) {
        final soNha = lay(['house_number']);
        final duong = lay(['road', 'pedestrian', 'footway']);
        soNhaDuong = [soNha, duong].where((e) => e != null).join(' ').trim();
      }
      return PhanTichDiaChi(
        moTa: moTa,
        soNhaDuong: soNhaDuong.isEmpty ? null : soNhaDuong,
        phuong: phuong,
        tinh: tinh,
      );
    } catch (_) {
      return null;
    }
  }

  static String? _phanChiTiet(String? moTa, String? phuong, String? tinh) {
    if (moTa == null) return null;
    final phan = moTa.split(',').map((e) => e.trim()).toList();
    bool laHanhChinh(String p) {
      final s = p.toLowerCase();
      return s.startsWith('phường') ||
          s.startsWith('xã') ||
          s.startsWith('thị trấn') ||
          s.startsWith('quận') ||
          s.startsWith('huyện') ||
          s.startsWith('thành phố') ||
          s.startsWith('tỉnh') ||
          (phuong != null && s == phuong.toLowerCase()) ||
          (tinh != null && s == tinh.toLowerCase());
    }

    var cat = phan.length;
    for (var i = 0; i < phan.length; i++) {
      if (laHanhChinh(phan[i])) {
        cat = i;
        break;
      }
    }
    final dau = phan.take(cat).where((e) => e.isNotEmpty).toList();
    return dau.isEmpty ? null : dau.join(', ');
  }

  // Tìm địa điểm theo từ khoá
  static Future<List<GoiYDiaDiem>> timDiaDiem(String tuKhoa) async {
    if (tuKhoa.trim().isEmpty) return const [];
    try {
      final res = await _dio.get(
        '/search',
        queryParameters: {
          'format': 'jsonv2',
          'q': tuKhoa,
          'accept-language': 'vi',
          'countrycodes': 'vn',
          'limit': 6,
        },
      );
      final data = res.data;
      if (data is! List) return const [];
      return [
        for (final e in data)
          if (e is Map && e['lat'] != null && e['lon'] != null)
            GoiYDiaDiem(
              ten: e['display_name']?.toString() ?? '',
              viTri: LatLng(
                double.parse(e['lat'].toString()),
                double.parse(e['lon'].toString()),
              ),
            ),
      ];
    } catch (_) {
      return const [];
    }
  }
}
