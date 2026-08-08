import 'package:petcare_app/core/network/api_client.dart';

// Lịch sử tìm kiếm lưu ở server để đổi máy vẫn còn
class SearchHistoryApiService {
  static const String _duong = '/search/history';

  Future<List<String>> danhSach() async {
    final res = await apiClient.get(_duong);
    return _docDanhSach(res.data);
  }

  Future<List<String>> them(String tuKhoa) async {
    final res = await apiClient.post(_duong, data: {'keyword': tuKhoa});
    return _docDanhSach(res.data);
  }

  Future<List<String>> xoaHet() async {
    final res = await apiClient.delete(_duong);
    return _docDanhSach(res.data);
  }

  List<String> _docDanhSach(dynamic data) {
    if (data is! Map) return const [];
    final items = data['items'];
    if (items is! List) return const [];
    return items.map((e) => e.toString()).toList();
  }
}
