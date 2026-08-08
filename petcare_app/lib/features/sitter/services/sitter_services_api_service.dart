import 'package:petcare_app/core/network/api_client.dart';
import 'package:petcare_app/shared/data/sitter_service_area.dart';
import 'package:petcare_app/shared/data/sitter_services.dart';

// Gọi API dịch vụ, khu vực phục vụ của NCC
class SitterServicesApiService {
  Future<SitterServices> getServices() async {
    final res = await apiClient.get('/sitter/services');
    return SitterServices.fromJson(Map<String, dynamic>.from(res.data as Map));
  }

  Future<SitterServices> updateServices(SitterServices services) async {
    final res = await apiClient.put(
      '/sitter/services',
      data: services.toJson(),
    );
    return SitterServices.fromJson(Map<String, dynamic>.from(res.data as Map));
  }

  Future<SitterServiceArea> getServiceArea() async {
    final res = await apiClient.get('/sitter/service-area');
    return SitterServiceArea.fromJson(
      Map<String, dynamic>.from(res.data as Map),
    );
  }

  Future<SitterServiceArea> updateServiceArea(SitterServiceArea area) async {
    final res = await apiClient.put(
      '/sitter/service-area',
      data: area.toJson(),
    );
    return SitterServiceArea.fromJson(
      Map<String, dynamic>.from(res.data as Map),
    );
  }

  // Đã bấm bắt đầu nhận đơnchưa (onboardedAt != null)
  Future<bool> getOnboarded() async {
    final res = await apiClient.get('/sitter/onboarding');
    final map = Map<String, dynamic>.from(res.data as Map);
    return map['onboardedAt'] != null;
  }

  // Đánh dấu hoàn tất onboarding trả true nếu đã ghi nhận
  Future<bool> completeOnboarding() async {
    final res = await apiClient.post('/sitter/onboarding/complete');
    final map = Map<String, dynamic>.from(res.data as Map);
    return map['onboardedAt'] != null;
  }
}
