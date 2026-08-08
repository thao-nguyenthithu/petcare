enum LoaiYeuCauSua { boSung, tuChoi }

// Lời nhắn sửa hồ sơ của quản trị viên, null nghĩa là hồ sơ đang chờ duyệt yên lành
class YeuCauSuaHoSo {
  const YeuCauSuaHoSo({required this.loai, this.lyDo});

  final LoaiYeuCauSua loai;
  final String? lyDo;

  static YeuCauSuaHoSo? tuHoSo(Map<String, dynamic> hoSo) {
    final tho = hoSo['editRequest'];
    if (tho is! Map) return null;
    final loai = switch (tho['kind'] as String?) {
      'SUPPLEMENT' => LoaiYeuCauSua.boSung,
      'REJECTED' => LoaiYeuCauSua.tuChoi,
      _ => null,
    };
    if (loai == null) return null;
    return YeuCauSuaHoSo(loai: loai, lyDo: tho['reason'] as String?);
  }
}
