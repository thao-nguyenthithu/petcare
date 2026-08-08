import 'package:petcare_app/features/home/data/owner_home.dart';
import 'package:petcare_app/features/home/services/home_api_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'owner_home_provider.g.dart';

// Home của chủ nuôi: đơn đang chạy và dải người chăm từng đặt
@Riverpod(keepAlive: true)
class TrangChuCuaToi extends _$TrangChuCuaToi {
  final _api = HomeApiService();

  @override
  Future<TrangChuChuNuoi> build() => _api.trangChu();

  Future<void> taiLai() async {
    state = await AsyncValue.guard(_api.trangChu);
  }
}
