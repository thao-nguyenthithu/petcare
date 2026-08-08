import 'package:petcare_app/core/network/api_client.dart';
import 'package:petcare_app/features/home/data/owner_home.dart';

// Trang chủ của chủ nuôi
class HomeApiService {
  Future<TrangChuChuNuoi> trangChu() async {
    final res = await apiClient.get('/home');
    return TrangChuChuNuoi.fromJson(Map<String, dynamic>.from(res.data as Map));
  }
}
