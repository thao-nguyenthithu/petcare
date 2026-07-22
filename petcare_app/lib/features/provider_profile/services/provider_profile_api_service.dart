import 'package:dio/dio.dart';
import 'package:petcare_app/core/network/api_client.dart';
import 'package:petcare_app/features/provider_profile/data/provider_profile_draft.dart';

// Gọi API hồ sơ NCC
class ProviderProfileApiService {
  // Gửi hồ sơ đăng ký
  Future<void> submit({
    required String legalName,
    required Gender gender,
    required DateTime dateOfBirth,
    required String nationalId,
    required String idIssuedPlace,
    required DateTime idIssuedDate,
    required String province,
    required String addressDetail,
    required String cccdFrontPath,
    required String cccdBackPath,
  }) => apiClient.post(
    '/provider-profile',
    data: {
      'legalName': legalName,
      'gender': _mapGender(gender),
      'dateOfBirth': _isoDate(dateOfBirth),
      'nationalId': nationalId,
      'idIssuedPlace': idIssuedPlace,
      'idIssuedDate': _isoDate(idIssuedDate),
      'province': province,
      'addressDetail': addressDetail,
      'cccdFrontPath': cccdFrontPath,
      'cccdBackPath': cccdBackPath,
    },
  );

  // Kiểm tra CCCD đã đăng ký ở hồ sơ người khác chưa
  Future<bool> isCccdAvailable(String nationalId) async {
    final res = await apiClient.get(
      '/provider-profile/check-cccd',
      queryParameters: {'nationalId': nationalId},
    );
    final data = Map<String, dynamic>.from(res.data as Map);
    return data['available'] == true;
  }

  // Trạng thái hồ sơ NCC: null nếu chưa có hồ sơ
  Future<String?> profileStatus() async {
    try {
      final res = await apiClient.get('/provider-profile/me');
      final data = Map<String, dynamic>.from(res.data as Map);
      return data['status'] as String?;
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      rethrow;
    }
  }

  // Trạng thái hồ sơ hiện tại
  Future<Map<String, dynamic>> getMine() async {
    final res = await apiClient.get('/provider-profile/me');
    return Map<String, dynamic>.from(res.data as Map);
  }

  static String _mapGender(Gender gender) => switch (gender) {
    Gender.male => 'MALE',
    Gender.female => 'FEMALE',
    Gender.other => 'OTHER',
  };

  // yyyy-mm-dd cho backend
  static String _isoDate(DateTime ngay) =>
      '${ngay.year.toString().padLeft(4, '0')}-'
      '${ngay.month.toString().padLeft(2, '0')}-'
      '${ngay.day.toString().padLeft(2, '0')}';
}
