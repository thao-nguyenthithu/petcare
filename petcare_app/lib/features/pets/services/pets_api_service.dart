import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:petcare_app/core/network/api_client.dart';
import 'package:petcare_app/features/pets/data/pet.dart';
import 'package:petcare_app/features/pets/data/prevention_record.dart';

// Gọi API hồ sơ thú cưng và sổ phòng bệnh
class PetsApiService {
  Future<List<Pet>> danhSach() async {
    final res = await apiClient.get('/pets');
    return [
      for (final e in res.data as List)
        Pet.fromJson(Map<String, dynamic>.from(e as Map)),
    ];
  }

  Future<Pet> chiTiet(String id) async {
    final res = await apiClient.get('/pets/$id');
    return _doc(res.data);
  }

  Future<Pet> them(Pet be) async {
    final res = await apiClient.post('/pets', data: be.toJson());
    return _doc(res.data);
  }

  Future<Pet> capNhat(Pet be) async {
    final res = await apiClient.put('/pets/${be.id}', data: be.toJson());
    return _doc(res.data);
  }

  Future<void> xoa(String id) => apiClient.delete('/pets/$id');

  // Ảnh của bé
  Future<Pet> themAnh(String id, List<Uint8List> anh) async {
    final res = await apiClient.post(
      '/pets/$id/photos',
      data: _formAnh(anh, 'pet'),
    );
    return _doc(res.data);
  }

  Future<Pet> xoaAnh(String id, List<String> idsAnh) async {
    final res = await apiClient.delete(
      '/pets/$id/photos',
      data: {'ids': idsAnh},
    );
    return _doc(res.data);
  }

  Future<Pet> datAnhDaiDien(String id, String idAnh) async {
    final res = await apiClient.patch('/pets/$id/photos/$idAnh/avatar');
    return _doc(res.data);
  }

  // Hạng mục phòng bệnh
  Future<Pet> themHangMuc(String id, PreventionRecord hangMuc) async {
    final res = await apiClient.post(
      '/pets/$id/preventions',
      data: hangMuc.toJson(),
    );
    return _doc(res.data);
  }

  Future<Pet> xoaHangMuc(String id, String idHangMuc) async {
    final res = await apiClient.delete('/pets/$id/preventions/$idHangMuc');
    return _doc(res.data);
  }

  // Lần thực hiện của một hạng mục
  Future<Pet> themLan(String id, String idHangMuc, PreventionDose lan) async {
    final res = await apiClient.post(
      '/pets/$id/preventions/$idHangMuc/doses',
      data: lan.toJson(),
    );
    return _doc(res.data);
  }

  Future<Pet> capNhatLan(
    String id,
    String idHangMuc,
    PreventionDose lan,
  ) async {
    final res = await apiClient.put(
      '/pets/$id/preventions/$idHangMuc/doses/${lan.id}',
      data: lan.toJson(),
    );
    return _doc(res.data);
  }

  Future<Pet> xoaLan(String id, String idHangMuc, String idLan) async {
    final res = await apiClient.delete(
      '/pets/$id/preventions/$idHangMuc/doses/$idLan',
    );
    return _doc(res.data);
  }

  // Ảnh phiếu của một lần
  Future<Pet> themAnhLan(
    String id,
    String idHangMuc,
    String idLan,
    List<Uint8List> anh,
  ) async {
    final res = await apiClient.post(
      '/pets/$id/preventions/$idHangMuc/doses/$idLan/photos',
      data: _formAnh(anh, 'phieu'),
    );
    return _doc(res.data);
  }

  Future<Pet> xoaAnhLan(
    String id,
    String idHangMuc,
    String idLan,
    List<String> idsAnh,
  ) async {
    final res = await apiClient.delete(
      '/pets/$id/preventions/$idHangMuc/doses/$idLan/photos',
      data: {'ids': idsAnh},
    );
    return _doc(res.data);
  }

  Pet _doc(Object? data) =>
      Pet.fromJson(Map<String, dynamic>.from(data as Map));

  FormData _formAnh(List<Uint8List> anh, String ten) => FormData.fromMap({
    'files': [
      for (final (i, bytes) in anh.indexed)
        MultipartFile.fromBytes(bytes, filename: '${ten}_$i.jpg'),
    ],
  });
}
