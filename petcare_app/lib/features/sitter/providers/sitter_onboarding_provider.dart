import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petcare_app/features/sitter/services/sitter_services_api_service.dart';

// NCC đã bấm onboardedAt hay chưa
class SitterOnboardingNotifier extends AsyncNotifier<bool> {
  final _api = SitterServicesApiService();

  @override
  Future<bool> build() => _api.getOnboarded();

  // Bấm Bắt đầu nhận đơn
  Future<void> hoanTat() async {
    state = const AsyncData(true);
    try {
      await _api.completeOnboarding();
    } catch (_) {
      ref.invalidateSelf();
    }
  }
}

final sitterOnboardingProvider =
    AsyncNotifierProvider<SitterOnboardingNotifier, bool>(
      SitterOnboardingNotifier.new,
    );
