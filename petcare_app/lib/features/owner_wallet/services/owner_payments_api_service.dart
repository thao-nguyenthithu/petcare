import 'package:petcare_app/core/network/api_client.dart';
import 'package:petcare_app/features/owner_wallet/data/owner_payment_api.dart';

// Cụm THANH TOÁN của chủ nuôi
class OwnerPaymentsApiService {
  Future<TienDangGiuApi> dangTamGiu() async {
    final res = await apiClient.get('/payments/holding');
    return TienDangGiuApi.fromJson(Map<String, dynamic>.from(res.data as Map));
  }

  Future<List<GiaoDichChuNuoiApi>> lichSu({String? loai}) async {
    final res = await apiClient.get(
      '/payments/transactions',
      queryParameters: {'loai': ?loai},
    );
    final map = Map<String, dynamic>.from(res.data as Map);
    return [
      for (final e in map['items'] as List)
        GiaoDichChuNuoiApi.fromJson(Map<String, dynamic>.from(e as Map)),
    ];
  }

  Future<ChiTietThanhToanApi> chiTiet(String ma) async {
    final res = await apiClient.get('/payments/transactions/$ma');
    return ChiTietThanhToanApi.fromJson(
      Map<String, dynamic>.from(res.data as Map),
    );
  }

  Future<ChiTieuApi> chiTieu(String ky) async {
    final res = await apiClient.get(
      '/payments/spending',
      queryParameters: {'period': ky},
    );
    return ChiTieuApi.fromJson(Map<String, dynamic>.from(res.data as Map));
  }
}
