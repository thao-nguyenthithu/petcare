import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:petcare_app/core/network/api_client.dart';

// Upload ảnh CCCD qua API, trả về path lưu trên server
class IdCardUploadService {
  Future<String> upload(Uint8List bytes, {required String mat}) async {
    final form = FormData.fromMap({
      'mat': mat,
      'file': MultipartFile.fromBytes(bytes, filename: '$mat.jpg'),
    });
    final res = await apiClient.post('/sitter-profile/cccd', data: form);
    final map = Map<String, dynamic>.from(res.data as Map);
    return map['path'] as String;
  }
}
