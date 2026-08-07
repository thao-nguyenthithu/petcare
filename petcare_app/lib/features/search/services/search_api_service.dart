import 'package:petcare_app/core/utils/vn_date.dart';
import 'package:petcare_app/features/search/data/search_filter.dart';
import 'package:petcare_app/shared/data/service_catalog.dart';
import 'package:petcare_app/shared/data/sitter_result.dart';
import 'package:petcare_app/shared/services/sitter_search_api_service.dart';

// Đổi bộ lọc của màn tìm kiếm
class SearchApiService {
  final _api = SitterSearchApiService();

  Future<TrangKetQuaTim> timNguoiCham({
    required BoLocTimKiem boLoc,
    String? tuKhoa,
    double? lat,
    double? lng,
    int page = 1,
    int limit = 20,
  }) {
    final tu = boLoc.tuNgay;
    final den = boLoc.denNgay;
    return _api.tim(
      tuKhoa: tuKhoa,
      maDichVu: boLoc.dichVu?.loai.maApi,
      maGoi: boLoc.dichVu?.maGoi,
      lat: lat,
      lng: lng,
      banKinhKm: boLoc.banKinhKm.round(),
      soBe: boLoc.soBeHieuLuc,
      ngayTu: tu != null && den != null ? ngayJson(tu) : null,
      ngayDen: tu != null && den != null ? ngayJson(den) : null,
      diemToiThieu: boLoc.diemToiThieu,
      giaTu: boLoc.giaTu,
      giaDen: boLoc.giaDen,
      chiTinCay: boLoc.chiTinCay,
      loai: boLoc.maLoai,
      sapXep: _maSapXep(boLoc.sapXep),
      trang: page,
      moiTrang: limit,
    );
  }

  String _maSapXep(SapXepKetQua cach) => switch (cach) {
    SapXepKetQua.deXuat => 'recommended',
    SapXepKetQua.ganNhat => 'nearest',
    SapXepKetQua.danhGiaCao => 'rating',
    SapXepKetQua.nhieuDon => 'completed',
    SapXepKetQua.itHuyMuon => 'cancelRate',
  };
}
