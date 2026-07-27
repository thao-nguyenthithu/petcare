import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petcare_app/features/sitter/data/sitter_services.dart';
import 'package:petcare_app/features/sitter/services/sitter_services_api_service.dart';

// Dịch vụ NCC
class SitterServicesNotifier extends AsyncNotifier<SitterServices> {
  final _api = SitterServicesApiService();

  // Nhớ các loại đang bật khi tắt công tắc tổng
  Set<ServiceType>? _snapshotBat;

  @override
  Future<SitterServices> build() => _api.getServices();

  Future<void> _luu(SitterServices moi) async {
    state = AsyncData(moi);
    try {
      await _api.updateServices(moi);
    } catch (_) {
      ref.invalidateSelf();
    }
  }

  void capNhat(SitterServices moi) => _luu(moi);

  // Bật/tắt một loại
  void batTat(ServiceType type, bool bat) {
    final cur = state.value;
    if (cur == null) return;
    _luu(switch (type) {
      ServiceType.walking => cur.copyWith(
        walking: cur.walking.copyWith(enabled: bat),
      ),
      ServiceType.boarding => cur.copyWith(
        boarding: cur.boarding.copyWith(enabled: bat),
      ),
      ServiceType.grooming => cur.copyWith(
        grooming: cur.grooming.copyWith(enabled: bat),
      ),
    });
  }

  // Công tắc tổng tắt
  void tamNghi() {
    final cur = state.value;
    if (cur == null) return;
    _snapshotBat = {
      for (final t in ServiceType.values)
        if (cur.isEnabled(t)) t,
    };
    _luu(_datEnabled(cur, const {}));
  }

  // Công tắc tổng bật
  void moLai() {
    final cur = state.value;
    if (cur == null) return;
    final khoiPhuc = (_snapshotBat != null && _snapshotBat!.isNotEmpty)
        ? _snapshotBat!
        : cur.configuredTypes.toSet();
    _luu(_datEnabled(cur, khoiPhuc));
    _snapshotBat = null;
  }

  // Đặt enabled cho từng loại
  SitterServices _datEnabled(SitterServices s, Set<ServiceType> bat) =>
      s.copyWith(
        walking: s.walking.copyWith(
          enabled: s.walking.configured && bat.contains(ServiceType.walking),
        ),
        boarding: s.boarding.copyWith(
          enabled: s.boarding.configured && bat.contains(ServiceType.boarding),
        ),
        grooming: s.grooming.copyWith(
          enabled: s.grooming.configured && bat.contains(ServiceType.grooming),
        ),
      );
}

final sitterServicesProvider =
    AsyncNotifierProvider<SitterServicesNotifier, SitterServices>(
      SitterServicesNotifier.new,
    );
