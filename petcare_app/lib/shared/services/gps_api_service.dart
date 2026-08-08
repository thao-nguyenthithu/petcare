import 'package:latlong2/latlong.dart';
import 'package:petcare_app/core/network/api_client.dart';

// Gọi GET /gps/bookings/:id/track lấy lịch sử lộ trình
class GpsApiService {
  Future<List<LatLng>> lichSuLoTrinh(String bookingId) async {
    final res = await apiClient.get('/gps/bookings/$bookingId/track');
    final data = Map<String, dynamic>.from(res.data as Map);
    final diem = (data['diem'] as List? ?? const [])
        .whereType<Map>()
        .map((d) {
          final lat = d['lat'];
          final lng = d['lng'];
          if (lat is! num || lng is! num) return null;
          return LatLng(lat.toDouble(), lng.toDouble());
        })
        .whereType<LatLng>()
        .toList();
    return diem;
  }
}
