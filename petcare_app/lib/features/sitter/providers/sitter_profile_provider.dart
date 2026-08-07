import 'package:petcare_app/features/booking/services/bookings_api_service.dart';
import 'package:petcare_app/core/utils/vn_date.dart';
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petcare_app/shared/data/sitter_profile.dart';
import 'package:petcare_app/features/sitter/services/sitter_profile_api_service.dart';
import 'package:petcare_app/shared/utils/chon_anh.dart';

// Kết quả chọn ảnh từ máy rồi tải lên thư viện
enum KetQuaThemAnh { thanhCong, motPhan, huy, dayAnh, quaNang, loi }

// Trang cá nhân của chính người đăng nhập, nạp từ /sitter/profile
class SitterMeNotifier extends AsyncNotifier<SitterProfile> {
  final _api = SitterProfileApiService();

  @override
  Future<SitterProfile> build() => _api.getProfile();

  // Lưu họ tên, giới thiệu, số điện thoại
  Future<void> luuHoSo({
    required String fullName,
    String? bio,
    String? phone,
  }) async {
    final moi = await _api.updateProfile(
      fullName: fullName,
      bio: bio,
      phone: phone,
    );
    state = AsyncData(moi);
  }

  // Đổi ảnh đại diện
  Future<void> doiAvatar(Uint8List bytes) async {
    final url = await _api.uploadAvatar(bytes);
    final cur = state.value;
    if (cur != null) state = AsyncData(cur.copyWith(avatarUrl: url));
  }

  // Chọn ảnh đại diện từ máy rồi upload ngay
  Future<KetQuaThemAnh> chonVaDoiAvatar() async {
    final chon = await chonMotAnh();
    if (chon.quaNang) return KetQuaThemAnh.quaNang;
    if (chon.anh == null) return KetQuaThemAnh.huy;
    await doiAvatar(chon.anh!);
    return KetQuaThemAnh.thanhCong;
  }

  // Chọn nhiều ảnh từ máy rồi upload ngay
  Future<KetQuaThemAnh> chonVaThemAnh() async {
    final daCo = state.value?.photos.length ?? 0;
    if (daCo >= maxSitterPhotos) return KetQuaThemAnh.dayAnh;
    final chon = await chonNhieuAnh(maxSitterPhotos - daCo);
    if (chon.anh.isEmpty) {
      return chon.quaNang > 0 ? KetQuaThemAnh.quaNang : KetQuaThemAnh.huy;
    }
    try {
      await themAnh(chon.anh);
    } catch (_) {
      return KetQuaThemAnh.loi;
    }
    if (chon.quaNang > 0) return KetQuaThemAnh.quaNang;
    return chon.du ? KetQuaThemAnh.motPhan : KetQuaThemAnh.thanhCong;
  }

  // Thêm ảnh, trả danh sách ảnh mới nhất
  Future<List<SitterPhotoItem>> themAnh(List<Uint8List> anh) async {
    final ds = await _api.addPhotos(anh);
    _capNhatAnh(ds);
    return ds;
  }

  // Xoá 1 hoặc nhiều ảnh
  Future<void> xoaAnh(List<String> ids) async {
    final ds = await _api.deletePhotos(ids);
    _capNhatAnh(ds);
  }

  void _capNhatAnh(List<SitterPhotoItem> ds) {
    final cur = state.value;
    if (cur != null) state = AsyncData(cur.copyWith(photos: ds));
  }
}

final sitterMeProvider = AsyncNotifierProvider<SitterMeNotifier, SitterProfile>(
  SitterMeNotifier.new,
);

// Hồ sơ công khai của một NCC khác theo id
final sitterPublicProvider = FutureProvider.family<SitterProfile, String>(
  (ref, id) => SitterProfileApiService().getSitter(id),
);

typedef LichBanNcc = ({List<DateTime> nghi, List<DateTime> kinDon});

final ngayKinCuaNccProvider = FutureProvider.family<LichBanNcc, String>((
  ref,
  sitterId,
) async {
  final homNay = homNayVn();
  final lich = await BookingsApiService().lichTrong(
    sitterId: sitterId,
    tu: homNay,
    den: homNay.add(const Duration(days: 60)),
  );
  return (
    nghi: lich.ngayNghi(),
    kinDon: [
      for (final e in lich.theoNgay.values)
        if (e.kinCaNgay) e.ngay,
    ],
  );
});
