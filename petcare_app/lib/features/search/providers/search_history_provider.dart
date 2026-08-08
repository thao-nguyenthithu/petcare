import 'package:petcare_app/features/search/services/search_history_api_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'search_history_provider.g.dart';

// Lịch sử tìm kiếm của người đang đăng nhập
@Riverpod(keepAlive: true)
class LichSuTim extends _$LichSuTim {
  final _service = SearchHistoryApiService();

  @override
  Future<List<String>> build() => _service.danhSach();

  Future<void> them(String tuKhoa) async {
    final khoa = tuKhoa.trim();
    if (khoa.isEmpty) return;
    final hienTai = state.asData?.value ?? const <String>[];
    state = AsyncData([
      khoa,
      ...hienTai.where((e) => e.toLowerCase() != khoa.toLowerCase()),
    ]);
    try {
      state = AsyncData(await _service.them(khoa));
    } catch (_) {}
  }

  Future<void> xoaHet() async {
    state = await AsyncValue.guard(_service.xoaHet);
  }
}
