import 'package:dio/dio.dart';
import 'package:petcare_app/core/network/api_client.dart';
import 'package:petcare_app/features/reviews/data/pending_review.dart';
import 'package:petcare_app/shared/data/service_catalog.dart';
import 'package:petcare_app/shared/data/sitter_review.dart';

typedef TrangDanhGia = ({
  List<SitterReview> items,
  ThongKeDanhGia? thongKe,
  int? tong,
  String? truocTiep,
});

class ReviewsApiService {
  // Đánh giá của MỘT người chăm, dùng ở trang hồ sơ công khai
  Future<TrangDanhGia> cuaNguoiCham(
    String sitterId, {
    String? truoc,
    int? sao,
    LoaiDichVu? dichVu,
    bool coAnh = false,
  }) async {
    final res = await apiClient.get(
      '/sitters/$sitterId/reviews',
      queryParameters: {
        'truoc': ?truoc,
        'rating': ?sao,
        if (dichVu != null) 'service': dichVu.maApi,
        if (coAnh) 'coAnh': true,
      },
    );
    return _docTrang(res.data);
  }

  // Đánh giá VỀ TÔI, nhìn từ người chăm
  Future<TrangDanhGia> veToi({String? truoc}) async {
    final res = await apiClient.get(
      '/sitter/reviews',
      queryParameters: {'truoc': ?truoc},
    );
    return _docTrang(res.data);
  }

  // Đánh giá CHÍNH TÔI đã viết, nhìn từ chủ nuôi
  Future<TrangDanhGia> cuaToi({String? truoc}) async {
    final res = await apiClient.get(
      '/reviews/mine',
      queryParameters: {'truoc': ?truoc},
    );
    return _docTrang(res.data);
  }

  // Đơn đã xong mà chủ nuôi chưa đánh giá
  Future<List<DonChoDanhGia>> donChoDanhGia() async {
    final res = await apiClient.get('/reviews/pending');
    return [
      for (final e in res.data as List)
        DonChoDanhGia.fromJson(Map<String, dynamic>.from(e as Map)),
    ];
  }

  Future<SitterReview> viet({
    required String bookingId,
    required int sao,
    String? nhanXet,
    List<MultipartFile> anh = const [],
    List<String> maKhen = const [],
  }) async {
    final form = FormData.fromMap({
      'rating': sao,
      'comment': ?nhanXet,
      if (maKhen.isNotEmpty) 'praiseTags': maKhen.join(','),
      'photos': anh,
    });
    final res = await apiClient.post('/bookings/$bookingId/review', data: form);
    return SitterReview.fromJson(Map<String, dynamic>.from(res.data as Map));
  }

  Future<SitterReview> phanHoi(String reviewId, String noiDung) async {
    final res = await apiClient.post(
      '/sitter/reviews/$reviewId/reply',
      data: {'content': noiDung},
    );
    return SitterReview.fromJson(Map<String, dynamic>.from(res.data as Map));
  }

  TrangDanhGia _docTrang(Object? data) {
    final map = Map<String, dynamic>.from(data as Map);
    return (
      items: [
        for (final e in map['items'] as List)
          SitterReview.fromJson(Map<String, dynamic>.from(e as Map)),
      ],
      thongKe: map['stats'] == null
          ? null
          : ThongKeDanhGia.fromJson(
              Map<String, dynamic>.from(map['stats'] as Map),
            ),
      tong: (map['total'] as num?)?.toInt(),
      truocTiep: map['truocTiep'] as String?,
    );
  }
}
