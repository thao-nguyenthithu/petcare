import 'package:petcare_app/core/config/cau_hinh_nghiep_vu_provider.dart';
import 'package:petcare_app/features/address/providers/saved_addresses_provider.dart';
import 'package:petcare_app/shared/data/sitter_result.dart';
import 'package:petcare_app/shared/services/sitter_search_api_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'home_sitters_provider.g.dart';

const int _soNguoiChamHome = 10;

// Người chăm gần chỗ ở của chủ nuôi
@riverpod
Future<List<SitterResult>> nguoiChamGanBan(Ref ref) async {
  final diaChi = await ref.watch(savedAddressesProvider.future);
  final macDinh = diaChi.isEmpty
      ? null
      : diaChi.firstWhere((e) => e.isDefault, orElse: () => diaChi.first);
  final coToaDo = macDinh?.lat != null && macDinh?.lng != null;
  final banKinhToiDa = ref.watch(cauHinhNghiepVuProvider).banKinhTimToiDaKm;
  final trang = await SitterSearchApiService().tim(
    lat: coToaDo ? macDinh!.lat : null,
    lng: coToaDo ? macDinh!.lng : null,
    banKinhKm: coToaDo ? banKinhToiDa : null,
    sapXep: coToaDo ? 'nearest' : 'rating',
    moiTrang: _soNguoiChamHome,
  );
  return trang.items;
}

// Người chăm điểm cao nhất
@riverpod
Future<List<SitterResult>> nguoiChamDanhGiaCao(Ref ref) async {
  final trang = await SitterSearchApiService().tim(
    sapXep: 'rating',
    moiTrang: _soNguoiChamHome,
  );
  return trang.items;
}
