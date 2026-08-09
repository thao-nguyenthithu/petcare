import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:petcare_app/core/router/app_router.dart';
import 'package:petcare_app/core/storage/token_storage.dart';

const String apiUrl = String.fromEnvironment(
  'API_URL',
  defaultValue: 'http://localhost:3000/api/v1',
);

final String serverGoc = apiUrl.replaceFirst(RegExp(r'/api/v\d+$'), '');

void canhBaoApiUrl() {
  debugPrint('API_URL đang dùng: $apiUrl');
  if (!apiUrl.contains('localhost') && !apiUrl.contains('127.0.0.1')) return;
  debugPrint(
    'CẢNH BÁO: máy thật và máy ảo không gọi được localhost, '
    'build kèm --dart-define-from-file=secrets.env',
  );
}

final Dio apiClient = Dio(
  BaseOptions(
    baseUrl: apiUrl,
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

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final coGanToken = err.requestOptions.headers.containsKey('Authorization');
    if (err.response?.statusCode == 401 && coGanToken) {
      await _tokenStorage.clearTokens();
      appRouter.go(AppRoutes.login);
    }
    handler.next(err);
  }
}
