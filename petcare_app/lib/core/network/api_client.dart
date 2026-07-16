import 'package:dio/dio.dart';

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
);
