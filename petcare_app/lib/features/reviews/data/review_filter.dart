import 'package:petcare_app/shared/data/service_catalog.dart';
import 'package:petcare_app/shared/data/sitter_review.dart';

// Bộ lọc của màn Tất cả đánh giá
class BoLocDanhGia {
  const BoLocDanhGia({this.coAnh = false, this.sao, this.dichVu});

  final bool coAnh;
  final int? sao;
  final LoaiDichVu? dichVu;

  bool get dangLoc => coAnh || sao != null || dichVu != null;

  BoLocDanhGia copyWith({
    bool? coAnh,
    int? sao,
    LoaiDichVu? dichVu,
    bool xoaSao = false,
    bool xoaDichVu = false,
  }) => BoLocDanhGia(
    coAnh: coAnh ?? this.coAnh,
    sao: xoaSao ? null : (sao ?? this.sao),
    dichVu: xoaDichVu ? null : (dichVu ?? this.dichVu),
  );

  bool nhan(SitterReview r) {
    if (coAnh && !r.coAnh) return false;
    if (sao != null && r.stars != sao) return false;
    if (dichVu != null && r.loaiDichVu != dichVu) return false;
    return true;
  }
}
