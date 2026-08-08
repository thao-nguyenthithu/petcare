import 'package:petcare_app/core/config/cau_hinh_nghiep_vu_provider.dart';
import 'package:petcare_app/features/address/providers/saved_addresses_provider.dart';
import 'package:petcare_app/shared/data/sitter_result.dart';
import 'package:petcare_app/shared/services/sitter_search_api_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'home_sitters_provider.g.dart';

const int _soNguoiChamHome = 10;

// Toạ độ địa chỉ mặc định, dùng để đo khoảng cách trên thẻ người chăm
Future<({double? lat, double? lng})> _diemMoc(Ref ref) async {
  final diaChi = await ref.watch(savedAddressesProvider.future);
  if (diaChi.isEmpty) return (lat: null, lng: null);
  final macDinh = diaChi.firstWhere(
    (e) => e.isDefault,
    orElse: () => diaChi.first,
  );
  return (lat: macDinh.lat, lng: macDinh.lng);
}

// Người chăm gần chỗ ở của chủ nuôi
@riverpod
Future<List<SitterResult>> nguoiChamGanBan(Ref ref) async {
  final moc = await _diemMoc(ref);
  final coToaDo = moc.lat != null && moc.lng != null;
  final banKinhToiDa = ref.watch(cauHinhNghiepVuProvider).banKinhTimToiDaKm;
  final trang = await SitterSearchApiService().tim(
    lat: moc.lat,
    lng: moc.lng,
    banKinhKm: coToaDo ? banKinhToiDa : null,
    sapXep: coToaDo ? 'nearest' : 'rating',
    moiTrang: _soNguoiChamHome,
  );
  return trang.items;
}

// Cửa vào khối do máy chủ giữ, toạ độ gửi kèm chỉ để đo đường chứ không lọc
@riverpod
Future<List<SitterResult>> nguoiChamDanhGiaCao(Ref ref) async {
  final moc = await _diemMoc(ref);
  final trang = await SitterSearchApiService().tim(
    lat: moc.lat,
    lng: moc.lng,
    sapXep: 'topRated',
    moiTrang: _soNguoiChamHome,
  );
  return trang.items;
}
