import 'package:petcare_app/core/network/api_client.dart';
import 'package:petcare_app/shared/data/saved_address.dart';

// Gọi API địa chỉ đã lưu (/addresses)
class AddressApiService {
  Future<List<SavedAddress>> danhSach() async {
    final res = await apiClient.get('/addresses');
    final data = res.data as List;
    return data
        .map((e) => SavedAddress.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  Future<SavedAddress> them(SavedAddress diaChi) async {
    final res = await apiClient.post('/addresses', data: diaChi.toJson());
    return SavedAddress.fromJson(Map<String, dynamic>.from(res.data as Map));
  }

  Future<SavedAddress> capNhat(SavedAddress diaChi) async {
    final res = await apiClient.put(
      '/addresses/${diaChi.id}',
      data: diaChi.toJson(),
    );
    return SavedAddress.fromJson(Map<String, dynamic>.from(res.data as Map));
  }

  Future<void> chonMacDinh(String id) =>
      apiClient.patch('/addresses/$id/default');

  Future<void> xoa(String id) => apiClient.delete('/addresses/$id');
}
