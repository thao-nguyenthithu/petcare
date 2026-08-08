import 'package:dio/dio.dart';
import 'package:petcare_app/core/network/api_client.dart';
import 'package:petcare_app/features/sitter_order/data/sitter_order_api.dart';
import 'package:petcare_app/shared/data/sitter_services.dart';

// Chip màn Công việc, gửi tên chip lên server chứ không gửi trạng thái
enum ChipDonNcc {
  tatCa,
  choXacNhan,
  sapToi,
  dangChay,
  choChot,
  hoanThanh,
  daHuy,
}

extension ChipDonNccApi on ChipDonNcc {
  String? get maApi => switch (this) {
    ChipDonNcc.tatCa => null,
    ChipDonNcc.choXacNhan => 'pending',
    ChipDonNcc.sapToi => 'upcoming',
    ChipDonNcc.dangChay => 'ongoing',
    ChipDonNcc.choChot => 'waitConfirm',
    ChipDonNcc.hoanThanh => 'completed',
    ChipDonNcc.daHuy => 'cancelled',
  };
}

// Gọi API cụm đơn phía người chăm
class SitterOrdersApiService {
  Future<TrangDonNcc> danhSach({
    ChipDonNcc chip = ChipDonNcc.tatCa,
    ServiceType? loai,
    int page = 1,
    int limit = 20,
  }) async {
    final res = await apiClient.get(
      '/sitter/bookings',
      queryParameters: {
        if (chip.maApi != null) 'status': chip.maApi,
        if (loai != null) 'serviceType': loai.name,
        'page': page,
        'limit': limit,
      },
    );
    return TrangDonNcc.fromJson(Map<String, dynamic>.from(res.data as Map));
  }

  Future<TomTatDonNcc> tomTat() async {
    final res = await apiClient.get('/sitter/bookings/summary');
    return TomTatDonNcc.fromJson(Map<String, dynamic>.from(res.data as Map));
  }

  Future<ChiTietDonNccApi> chiTiet(String id) async {
    final res = await apiClient.get('/sitter/bookings/$id');
    return ChiTietDonNccApi.fromJson(
      Map<String, dynamic>.from(res.data as Map),
    );
  }

  Future<void> nhanDon(String id, {bool camKetDungCu = false}) =>
      _post(id, 'accept', {'safetyCommitted': camKetDungCu});

  Future<void> tuChoi(String id, {required String lyDo, String moTa = ''}) =>
      _post(id, 'reject', _lyDo(lyDo, moTa));

  Future<void> xuatPhat(String id) => _post(id, 'depart', const {});

  Future<void> daToi(String id, {required double lat, required double lng}) =>
      _post(id, 'arrive', {'lat': lat, 'lng': lng});

  Future<void> baoMuon(String id, {required int phut}) =>
      _post(id, 'late', {'minutes': phut});

  Future<void> baoThieuDungCu(String id, {required List<MultipartFile> anh}) =>
      _postAnh(id, 'gear-missing', anh, const {});

  Future<void> huyViThieuDungCu(String id) =>
      _post(id, 'gear-cancel', const {});

  Future<void> baoVangMat(String id, {required List<MultipartFile> anh}) =>
      _postAnh(id, 'no-show', anh, const {});

  Future<void> huyDon(String id, {required String lyDo, String moTa = ''}) =>
      _post(id, 'cancel', _lyDo(lyDo, moTa));

  Future<void> khongTheTiepNhan(
    String id, {
    required String lyDo,
    required String moTa,
    required List<MultipartFile> anh,
  }) => _postAnh(id, 'abort', anh, _lyDo(lyDo, moTa));

  Future<void> batDauPhien(
    String id, {
    List<MultipartFile> anh = const [],
    List<MultipartFile> anhDoDung = const [],
    String moTa = '',
  }) {
    final phanChu = {if (moTa.isNotEmpty) 'note': moTa};
    return anh.isEmpty && anhDoDung.isEmpty
        ? _post(id, 'check-in', phanChu)
        : _postAnh(id, 'check-in', anh, phanChu, anhDoDung: anhDoDung);
  }

  Future<String> ketThucLayTrangThai(
    String id, {
    required List<MultipartFile> anh,
    List<MultipartFile> anhDoDung = const [],
    String ghiChu = '',
    double? km,
    List<String> nhanTinhTrang = const [],
  }) async {
    final res = await _postAnhLayData(id, 'finish', anh, {
      if (ghiChu.isNotEmpty) 'note': ghiChu,
      'distanceKm': ?km,
      if (nhanTinhTrang.isNotEmpty) 'conditions': nhanTinhTrang.join(','),
    }, anhDoDung: anhDoDung);
    return res is Map ? res['status'] as String? ?? '' : '';
  }

  Future<void> baoSuCo(
    String id, {
    required String moTa,
    required String maLyDo,
    List<MultipartFile> anh = const [],
  }) {
    final phanChu = {'description': moTa, 'reason': maLyDo};
    return anh.isEmpty
        ? _post(id, 'incident', phanChu)
        : _postAnh(id, 'incident', anh, phanChu);
  }

  Future<void> guiAnhPhien(String id, {required List<MultipartFile> anh}) =>
      _postAnh(id, 'photos', anh, const {});

  Future<void> capNhatNgay(
    String id, {
    required List<MultipartFile> anh,
    String loiNhan = '',
    List<String> nhanTinhTrang = const [],
  }) => _postAnh(id, 'daily-update', anh, {
    if (loiNhan.isNotEmpty) 'message': loiNhan,
    if (nhanTinhTrang.isNotEmpty) 'conditions': nhanTinhTrang.join(','),
  });

  Map<String, dynamic> _lyDo(String lyDo, String moTa) => {
    'reason': lyDo,
    if (moTa.trim().isNotEmpty) 'note': moTa.trim(),
  };

  Future<void> _post(String id, String duong, Map<String, dynamic> body) async {
    await apiClient.post('/sitter/bookings/$id/$duong', data: body);
  }

  Future<void> _postAnh(
    String id,
    String duong,
    List<MultipartFile> anh,
    Map<String, dynamic> phanChu, {
    List<MultipartFile> anhDoDung = const [],
  }) => _postAnhLayData(id, duong, anh, phanChu, anhDoDung: anhDoDung);

  Future<dynamic> _postAnhLayData(
    String id,
    String duong,
    List<MultipartFile> anh,
    Map<String, dynamic> phanChu, {
    List<MultipartFile> anhDoDung = const [],
  }) async {
    final form = FormData.fromMap({
      ...phanChu,
      'photos': anh,
      if (anhDoDung.isNotEmpty) 'itemPhotos': anhDoDung,
    });
    final res = await apiClient.post('/sitter/bookings/$id/$duong', data: form);
    return res.data;
  }
}
