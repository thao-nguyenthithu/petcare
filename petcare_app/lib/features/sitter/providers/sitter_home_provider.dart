import 'package:petcare_app/features/sitter/data/sitter_dashboard.dart';
import 'package:petcare_app/features/sitter/services/sitter_home_api_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'sitter_home_provider.g.dart';

// Số liệu tab Công việc
@Riverpod(keepAlive: true)
class TrangChuNguoiCham extends _$TrangChuNguoiCham {
  final _service = SitterHomeApiService();

  @override
  Future<SitterDashboard> build() => _service.dashboard();

  Future<void> taiLai() async {
    state = await AsyncValue.guard(_service.dashboard);
  }
}
