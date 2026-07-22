import 'package:dio/dio.dart';
import 'package:petcare_app/core/storage/token_storage.dart';

const String _apiUrl = String.fromEnvironment(
  'API_URL',
  defaultValue: 'http://localhost:3000/api/v1',
);

final Dio apiClient = Dio(
  BaseOptions(
    baseUrl: _apiUrl,
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 15),
  ),
)..interceptors.add(_AuthInterceptor());

// Đính JWT vào mọi request, bỏ qua nếu chưa đăng nhập
class _AuthInterceptor extends Interceptor {
  final _tokenStorage = TokenStorageService();

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _tokenStorage.getAccessToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }
}
