import 'dart:typed_data';

import 'package:petcare_app/shared/data/pet.dart';
import 'package:petcare_app/shared/data/prevention_record.dart';
import 'package:petcare_app/features/pets/services/pets_api_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'my_pets_provider.g.dart';

// Danh sách thú cưng của chủ nuôi đang đăng nhập
@Riverpod(keepAlive: true)
class MyPets extends _$MyPets {
  final _service = PetsApiService();

  @override
  Future<List<Pet>> build() => _service.danhSach();

  void _thay(Pet be) {
    final ds = [...?state.value];
    final viTri = ds.indexWhere((e) => e.id == be.id);
    if (viTri < 0) {
      ds.add(be);
    } else {
      ds[viTri] = be;
    }
    state = AsyncData(ds);
  }

  Future<void> taiLai() async {
    state = await AsyncValue.guard(_service.danhSach);
  }

  Future<Pet> them(Pet be) async {
    final moi = await _service.them(be);
    _thay(moi);
    return moi;
  }

  Future<Pet> capNhat(Pet be) async {
    final moi = await _service.capNhat(be);
    _thay(moi);
    return moi;
  }

  Future<void> xoa(String id) async {
    await _service.xoa(id);
    state = AsyncData([...?state.value?.where((e) => e.id != id)]);
  }

  Future<Pet> themAnh(String id, List<Uint8List> anh) async {
    final moi = await _service.themAnh(id, anh);
    _thay(moi);
    return moi;
  }

  Future<Pet> xoaAnh(String id, List<String> idsAnh) async {
    final moi = await _service.xoaAnh(id, idsAnh);
    _thay(moi);
    return moi;
  }

  Future<Pet> datAnhDaiDien(String id, String idAnh) async {
    final moi = await _service.datAnhDaiDien(id, idAnh);
    _thay(moi);
    return moi;
  }

  Future<Pet> themHangMuc(String id, PreventionRecord hangMuc) async {
    final moi = await _service.themHangMuc(id, hangMuc);
    _thay(moi);
    return moi;
  }

  Future<Pet> xoaHangMuc(String id, String idHangMuc) async {
    final moi = await _service.xoaHangMuc(id, idHangMuc);
    _thay(moi);
    return moi;
  }

  Future<Pet> themLan(String id, String idHangMuc, PreventionDose lan) async {
    final moi = await _service.themLan(id, idHangMuc, lan);
    _thay(moi);
    return moi;
  }

  Future<Pet> capNhatLan(
    String id,
    String idHangMuc,
    PreventionDose lan,
  ) async {
    final moi = await _service.capNhatLan(id, idHangMuc, lan);
    _thay(moi);
    return moi;
  }

  Future<Pet> xoaLan(String id, String idHangMuc, String idLan) async {
    final moi = await _service.xoaLan(id, idHangMuc, idLan);
    _thay(moi);
    return moi;
  }

  Future<Pet> themAnhLan(
    String id,
    String idHangMuc,
    String idLan,
    List<Uint8List> anh,
  ) async {
    final moi = await _service.themAnhLan(id, idHangMuc, idLan, anh);
    _thay(moi);
    return moi;
  }

  // Ghi hoặc sửa
  Future<PreventionRecord> ghiLanKemAnh({
    required String petId,
    required String idHangMuc,
    required PreventionDose lan,
    required List<Uint8List> anhMoi,
    required bool dangSua,
  }) async {
    var be = dangSua
        ? await capNhatLan(petId, idHangMuc, lan)
        : await themLan(petId, idHangMuc, lan);
    var hangMuc = be.phongBenh.firstWhere((e) => e.id == idHangMuc);
    if (anhMoi.isEmpty) return hangMuc;
    final lanTrenServer = hangMuc.lanThucHien.firstWhere(
      (e) => e.ngay == lan.ngay,
      orElse: () => hangMuc.lanGanNhat!,
    );
    be = await themAnhLan(petId, idHangMuc, lanTrenServer.id, anhMoi);
    hangMuc = be.phongBenh.firstWhere((e) => e.id == idHangMuc);
    return hangMuc;
  }

  // Lưu trọn hồ sơ lúc THÊM bé mới
  Future<Pet> luuHoSoDayDu({
    required Pet hoSo,
    required List<Uint8List> anhMoi,
    required List<PreventionRecord> hangMucTam,
    required bool dangSua,
  }) async {
    var be = dangSua ? await capNhat(hoSo) : await them(hoSo);
    if (anhMoi.isNotEmpty) be = await themAnh(be.id, anhMoi);
    for (final hangMuc in hangMucTam) {
      if (hangMuc.daLuuTrenServer) continue;
      be = await themHangMuc(be.id, hangMuc);
      final vuaTao = be.phongBenh.lastWhere(
        (e) => e.ma == hangMuc.ma,
        orElse: () => be.phongBenh.last,
      );
      for (final lan in hangMuc.lanThucHien) {
        await ghiLanKemAnh(
          petId: be.id,
          idHangMuc: vuaTao.id,
          lan: lan,
          anhMoi: [for (final a in lan.anh) ?a.bytes],
          dangSua: false,
        );
      }
    }
    return state.value?.firstWhere((e) => e.id == be.id) ?? be;
  }

  Future<Pet> xoaAnhLan(
    String id,
    String idHangMuc,
    String idLan,
    List<String> idsAnh,
  ) async {
    final moi = await _service.xoaAnhLan(id, idHangMuc, idLan, idsAnh);
    _thay(moi);
    return moi;
  }
}

// Hồ sơ một bé lấy thẳng từ danh sách đang giữ
@riverpod
Pet? petTheoId(Ref ref, String id) {
  final ds = ref.watch(myPetsProvider).value;
  if (ds == null) return null;
  for (final be in ds) {
    if (be.id == id) return be;
  }
  return null;
}
