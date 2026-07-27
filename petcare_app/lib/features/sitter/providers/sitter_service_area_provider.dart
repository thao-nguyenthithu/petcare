import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petcare_app/features/sitter/data/sitter_service_area.dart';
import 'package:petcare_app/features/sitter/services/sitter_services_api_service.dart';

// Địa điểm khu vực phục vụ NCC
class SitterServiceAreaNotifier extends AsyncNotifier<SitterServiceArea> {
  final _api = SitterServicesApiService();

  @override
  Future<SitterServiceArea> build() => _api.getServiceArea();

  Future<void> capNhat(SitterServiceArea moi) async {
    state = AsyncData(moi);
    try {
      await _api.updateServiceArea(moi);
    } catch (_) {
      ref.invalidateSelf();
    }
  }
}

final sitterServiceAreaProvider =
    AsyncNotifierProvider<SitterServiceAreaNotifier, SitterServiceArea>(
      SitterServiceAreaNotifier.new,
    );
