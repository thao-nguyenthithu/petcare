import 'dart:async';

import 'package:latlong2/latlong.dart';
import 'package:petcare_app/features/search/data/search_filter.dart';
import 'package:petcare_app/shared/data/sitter_result.dart';
import 'package:petcare_app/features/search/services/search_api_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'search_results_provider.g.dart';

// Trọn bộ điều kiện của một lần tìm
class YeuCauTim {
  const YeuCauTim({required this.boLoc, this.tuKhoa, this.lat, this.lng});

  final BoLocTimKiem boLoc;
  final String? tuKhoa;
  final double? lat;
  final double? lng;

  LatLng? get tam => lat != null && lng != null ? LatLng(lat!, lng!) : null;

  @override
  bool operator ==(Object other) =>
      other is YeuCauTim &&
      other.tuKhoa == tuKhoa &&
      other.lat == lat &&
      other.lng == lng &&
      other.boLoc == boLoc;

  @override
  int get hashCode => Object.hash(tuKhoa, lat, lng, boLoc);
}

// Kết quả tìm người chăm
@riverpod
class KetQuaTim extends _$KetQuaTim {
  final _service = SearchApiService();

  static const int _moiTrang = 20;

  @override
  Future<TrangKetQuaTim> build(YeuCauTim yeuCau) {
    final giuCache = ref.keepAlive();
    final hen = Timer(const Duration(seconds: 30), giuCache.close);
    ref.onDispose(() {
      hen.cancel();
      giuCache.close();
    });
    return _goi(1);
  }

  Future<TrangKetQuaTim> _goi(int trang) => _service.timNguoiCham(
    boLoc: yeuCau.boLoc,
    tuKhoa: yeuCau.tuKhoa,
    lat: yeuCau.lat,
    lng: yeuCau.lng,
    page: trang,
    limit: _moiTrang,
  );

  Future<void> taiThem() async {
    final hienTai = state.asData?.value;
    if (hienTai == null || !hienTai.conTrangSau || hienTai.dangTaiThem) return;
    state = AsyncData(hienTai.copyWith(dangTaiThem: true));
    try {
      final tiep = await _goi(hienTai.page + 1);
      state = AsyncData(hienTai.noiThem(tiep));
    } catch (_) {
      state = AsyncData(hienTai.copyWith(dangTaiThem: false));
    }
  }
}
