import 'package:dio/dio.dart';

// Đọc lỗi backend trả về ({code, message, meta}) từ DioException.
// Dùng chung cho mọi cụm; auth có bản riêng cũ, không đụng tới.
Map<dynamic, dynamic>? _dataFromError(Object error) {
  if (error is! DioException) return null;
  final data = error.response?.data;
  return data is Map ? data : null;
}

// Mã lỗi ổn định để client tự dịch, null nếu backend không trả code
String? codeFromError(Object error) {
  final code = _dataFromError(error)?['code'];
  return code is String ? code : null;
}

// Message backend trả về, null nếu không có
String? messageFromError(Object error) {
  final message = _dataFromError(error)?['message'];
  if (message is String) return message;
  if (message is List && message.isNotEmpty) return message.first.toString();
  return null;
}
