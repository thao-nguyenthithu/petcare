import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petcare_app/core/network/api_client.dart';
import 'package:petcare_app/shared/data/service_catalog.dart';

class DanhMucDichVuApi {
  Future<Map<LoaiDichVu, String>> doc() async {
    final res = await apiClient.get('/config/dich-vu');
    final than = res.data;
    if (than is! List) return const {};
    final ket = <LoaiDichVu, String>{};
    for (final dong in than) {
      if (dong is! Map) continue;
      final loai = _theoMaApi(dong['type']);
      final moTa = dong['description'];
      if (loai != null && moTa is String && moTa.trim().isNotEmpty) {
        ket[loai] = moTa.trim();
      }
    }
    return ket;
  }

  LoaiDichVu? _theoMaApi(Object? ma) => switch (ma) {
    'WALKING' => LoaiDichVu.datDiDao,
    'BOARDING' => LoaiDichVu.trongGiu,
    'GROOMING' => LoaiDichVu.catTia,
    _ => null,
  };
}

final danhMucDichVuApiProvider = Provider<DanhMucDichVuApi>(
  (ref) => DanhMucDichVuApi(),
);

// Rỗng nghĩa là chưa tải xong hoặc quản trị chưa nhập, màn dùng câu trong ARB
class MoTaDichVuNotifier extends Notifier<Map<LoaiDichVu, String>> {
  @override
  Map<LoaiDichVu, String> build() {
    Future.microtask(nap);
    return const {};
  }

  Future<void> nap() async {
    try {
      final moi = await ref.read(danhMucDichVuApiProvider).doc();
      if (moi.isNotEmpty) state = moi;
    } catch (_) {
      return;
    }
  }
}

final moTaDichVuProvider =
    NotifierProvider<MoTaDichVuNotifier, Map<LoaiDichVu, String>>(
      MoTaDichVuNotifier.new,
    );
