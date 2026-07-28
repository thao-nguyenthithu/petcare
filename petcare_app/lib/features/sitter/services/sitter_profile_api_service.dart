import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:petcare_app/core/network/api_client.dart';
import 'package:petcare_app/features/sitter/data/sitter_profile.dart';

// Gọi API trang cá nhân NCC
class SitterProfileApiService {
  Future<SitterProfile> getProfile() async {
    final res = await apiClient.get('/sitter/profile');
    return SitterProfile.fromJson(Map<String, dynamic>.from(res.data as Map));
  }

  // Hồ sơ NCC khác
  Future<SitterProfile> getSitter(String id) async {
    final res = await apiClient.get('/sitters/$id');
    return SitterProfile.fromJson(Map<String, dynamic>.from(res.data as Map));
  }

  Future<SitterProfile> updateProfile({
    required String fullName,
    String? bio,
    String? phone,
  }) async {
    final res = await apiClient.put(
      '/sitter/profile',
      data: {'fullName': fullName, 'bio': bio, 'phone': phone},
    );
    return SitterProfile.fromJson(Map<String, dynamic>.from(res.data as Map));
  }

  // Tải ảnh đại diện
  Future<String> uploadAvatar(Uint8List bytes) async {
    final form = FormData.fromMap({
      'file': MultipartFile.fromBytes(bytes, filename: 'avatar.jpg'),
    });
    final res = await apiClient.post('/sitter/profile/avatar', data: form);
    return Map<String, dynamic>.from(res.data as Map)['avatarUrl'] as String;
  }

  // Thêm nhiều ảnh
  Future<List<SitterPhotoItem>> addPhotos(List<Uint8List> anh) async {
    final form = FormData.fromMap({
      'files': [
        for (final (i, bytes) in anh.indexed)
          MultipartFile.fromBytes(bytes, filename: 'photo_$i.jpg'),
      ],
    });
    final res = await apiClient.post('/sitter/profile/photos', data: form);
    return _mapAnh(res.data);
  }

  // Xoá 1 hoặc nhiều ảnh
  Future<List<SitterPhotoItem>> deletePhotos(List<String> ids) async {
    final res = await apiClient.delete(
      '/sitter/profile/photos',
      data: {'ids': ids},
    );
    return _mapAnh(res.data);
  }

  List<SitterPhotoItem> _mapAnh(Object? data) => (data as List)
      .map((e) => SitterPhotoItem.fromJson(Map<String, dynamic>.from(e as Map)))
      .toList();
}
