import 'package:petcare_app/core/network/api_client.dart';
import 'package:petcare_app/shared/data/sitter_result.dart';

// Gọi GET /search/sitters, nhận tham số rời để Home cũng dùng được
class SitterSearchApiService {
  Future<TrangKetQuaTim> tim({
    String? tuKhoa,
    String? maDichVu,
    String? maGoi,
    double? lat,
    double? lng,
    int? banKinhKm,
    int? soBe,
    String? ngayTu,
    String? ngayDen,
    double? diemToiThieu,
    int? giaTu,
    int? giaDen,
    bool chiTinCay = false,
    String? loai,
    String sapXep = 'rating',
    int trang = 1,
    int moiTrang = 20,
  }) async {
    final res = await apiClient.get(
      '/search/sitters',
      queryParameters: {
        if (tuKhoa != null && tuKhoa.trim().isNotEmpty) 'q': tuKhoa.trim(),
        'service': ?maDichVu,
        'package': ?maGoi,
        if (lat != null && lng != null) ...{
          'lat': lat,
          'lng': lng,
          'radiusKm': ?banKinhKm,
        },
        if (soBe != null && soBe > 0) 'petCount': soBe,
        if (ngayTu != null && ngayDen != null) ...{
          'dateFrom': ngayTu,
          'dateTo': ngayDen,
        },
        'minRating': ?diemToiThieu,
        'priceMin': ?giaTu,
        'priceMax': ?giaDen,
        if (chiTinCay) 'trusted': true,
        'species': ?loai,
        'sort': sapXep,
        'page': trang,
        'limit': moiTrang,
      },
    );
    return TrangKetQuaTim.fromJson(Map<String, dynamic>.from(res.data as Map));
  }
}
