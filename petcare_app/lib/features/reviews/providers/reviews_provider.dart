import 'package:dio/dio.dart';
import 'package:petcare_app/features/reviews/data/pending_review.dart';
import 'package:petcare_app/features/reviews/services/reviews_api_service.dart';
import 'package:petcare_app/shared/data/sitter_review.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'reviews_provider.g.dart';

// Đánh giá của một người chăm
@riverpod
Future<TrangDanhGia> danhGiaNguoiCham(Ref ref, String sitterId) =>
    ReviewsApiService().cuaNguoiCham(sitterId);

@Riverpod(keepAlive: true)
class DanhGiaVeToi extends _$DanhGiaVeToi {
  final _service = ReviewsApiService();

  @override
  Future<TrangDanhGia> build() => _service.veToi();

  Future<void> taiLai() async {
    state = await AsyncValue.guard(_service.veToi);
  }

  Future<void> phanHoi(String reviewId, String noiDung) async {
    final moi = await _service.phanHoi(reviewId, noiDung);
    final cu = state.value;
    if (cu == null) return;
    state = AsyncData((
      items: [for (final d in cu.items) d.bookingId == moi.bookingId ? moi : d],
      thongKe: cu.thongKe,
      tong: cu.tong,
      truocTiep: cu.truocTiep,
    ));
  }
}

// Đánh giá tôi đã viết chủ nuôi
@Riverpod(keepAlive: true)
class DanhGiaCuaToi extends _$DanhGiaCuaToi {
  final _service = ReviewsApiService();

  @override
  Future<TrangDanhGia> build() => _service.cuaToi();

  Future<void> taiLai() async {
    state = await AsyncValue.guard(_service.cuaToi);
  }
}

// Đơn đã xong mà chủ nuôi chưa đánh giá
@Riverpod(keepAlive: true)
class DonChoDanhGiaCuaToi extends _$DonChoDanhGiaCuaToi {
  final _service = ReviewsApiService();

  @override
  Future<List<DonChoDanhGia>> build() => _service.donChoDanhGia();

  Future<void> taiLai() async {
    state = await AsyncValue.guard(_service.donChoDanhGia);
  }

  Future<SitterReview> viet({
    required String bookingId,
    required int sao,
    String? nhanXet,
    List<MultipartFile> anh = const [],
    List<String> maKhen = const [],
  }) async {
    final bai = await _service.viet(
      bookingId: bookingId,
      sao: sao,
      nhanXet: nhanXet,
      anh: anh,
      maKhen: maKhen,
    );
    state = AsyncData([
      ...?state.value?.where((d) => d.bookingId != bookingId),
    ]);
    ref.invalidate(danhGiaCuaToiProvider);
    return bai;
  }
}
