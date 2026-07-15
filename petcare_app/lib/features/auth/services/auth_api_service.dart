import 'package:dio/dio.dart';
import 'package:petcare_app/core/network/api_client.dart';

/// Gọi các API luồng đăng ký
class AuthApiService {
  Future<void> register({
    required String fullName,
    required String email,
    required String phone,
    required String password,
  }) => apiClient.post(
    '/auth/register',
    data: {
      'fullName': fullName,
      'email': email,
      'phone': phone,
      'password': password,
    },
  );

  Future<void> verifyEmail({required String email, required String otp}) =>
      apiClient.post('/auth/verify-email', data: {'email': email, 'otp': otp});

  Future<void> resendVerifyOtp(String email) =>
      apiClient.post('/auth/resend-verify-otp', data: {'email': email});

  // Lấy message backend trả về từ lỗi Dio
  static String? messageFromError(Object error) {
    final data = _dataFromError(error);
    if (data == null) return null;
    final message = data['message'];
    if (message is String) return message;
    if (message is List && message.isNotEmpty) return message.first.toString();
    return null;
  }

  // Mã lỗi ổn định để client tự dịch (i18n), null nếu backend không trả code
  static String? codeFromError(Object error) {
    final code = _dataFromError(error)?['code'];
    return code is String ? code : null;
  }

  // Tham số động cho câu dịch trong trường meta
  static int? metaInt(Object error, String key) {
    final meta = _dataFromError(error)?['meta'];
    if (meta is! Map) return null;
    final value = meta[key];
    return value is num ? value.toInt() : null;
  }

  static Map<dynamic, dynamic>? _dataFromError(Object error) {
    if (error is! DioException) return null;
    final data = error.response?.data;
    return data is Map ? data : null;
  }
}
