import 'package:petcare_app/core/network/api_client.dart';
import 'package:petcare_app/features/sitter/data/sitter_dashboard.dart';

// Tab Công việc của người chăm
class SitterHomeApiService {
  Future<SitterDashboard> dashboard() async {
    final res = await apiClient.get('/sitter/home');
    return SitterDashboard.fromJson(Map<String, dynamic>.from(res.data as Map));
  }
}
