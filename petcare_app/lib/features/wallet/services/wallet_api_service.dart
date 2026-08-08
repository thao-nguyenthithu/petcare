import 'package:dio/dio.dart';
import 'package:petcare_app/core/network/api_client.dart';
import 'package:petcare_app/features/wallet/data/wallet_api.dart';

// Cụm ví của người chăm
class WalletApiService {
  Future<ViApi> vi() async {
    final res = await apiClient.get('/sitter/wallet');
    return ViApi.fromJson(Map<String, dynamic>.from(res.data as Map));
  }

  Future<TrangGiaoDichVi> lichSu({String? loai, String? truoc}) async {
    final res = await apiClient.get(
      '/sitter/wallet/transactions',
      queryParameters: {'loai': ?loai, 'truoc': ?truoc},
    );
    return TrangGiaoDichVi.fromJson(Map<String, dynamic>.from(res.data as Map));
  }

  Future<ChiTietGiaoDichApi> chiTiet(String ma) async {
    final res = await apiClient.get('/sitter/wallet/transactions/$ma');
    return ChiTietGiaoDichApi.fromJson(
      Map<String, dynamic>.from(res.data as Map),
    );
  }

  Future<TaiKhoanNganHangApi?> taiKhoan() async {
    final res = await apiClient.get('/sitter/wallet/bank-account');
    final data = res.data;
    // Chưa liên kết ngân hàng thì server trả rỗng
    if (data == null || data is! Map) return null;
    return TaiKhoanNganHangApi.fromJson(Map<String, dynamic>.from(data));
  }

  Future<TaiKhoanNganHangApi> luuTaiKhoan({
    required String tenNganHang,
    required String soTaiKhoan,
    required String tenChuTaiKhoan,
  }) async {
    final res = await apiClient.put(
      '/sitter/wallet/bank-account',
      data: {
        'bankName': tenNganHang,
        'accountNumber': soTaiKhoan,
        'accountHolder': tenChuTaiKhoan,
      },
    );
    return TaiKhoanNganHangApi.fromJson(
      Map<String, dynamic>.from(res.data as Map),
    );
  }

  Future<KetQuaRutTien> rut(int soTien) async {
    final res = await apiClient.post(
      '/sitter/wallet/withdrawals',
      data: {'amount': soTien},
    );
    return KetQuaRutTien.fromJson(Map<String, dynamic>.from(res.data as Map));
  }

  Future<List<HoSoKhieuNaiApi>> khieuNai() async {
    final res = await apiClient.get('/sitter/wallet/disputes');
    return [
      for (final e in res.data as List)
        HoSoKhieuNaiApi.fromJson(Map<String, dynamic>.from(e as Map)),
    ];
  }

  Future<HoSoKhieuNaiApi> khieuNaiTheoMa(String ma) async {
    final res = await apiClient.get('/disputes/$ma');
    return HoSoKhieuNaiApi.fromJson(Map<String, dynamic>.from(res.data as Map));
  }

  // Ảnh gửi kèm luôn, không có API tải ảnh riêng
  Future<HoSoKhieuNaiApi> phanHoiKhieuNai(
    String ma,
    String noiDung, {
    List<MultipartFile> anh = const [],
  }) async {
    final form = FormData.fromMap({'content': noiDung, 'photos': anh});
    final res = await apiClient.post(
      '/sitter/wallet/disputes/$ma/reply',
      data: form,
    );
    return HoSoKhieuNaiApi.fromJson(Map<String, dynamic>.from(res.data as Map));
  }

  // Kỳ: tuần, tháng hoặc năm
  Future<ThuNhapApi> thuNhap(String ky) async {
    final res = await apiClient.get(
      '/provider/earnings',
      queryParameters: {'period': ky},
    );
    return ThuNhapApi.fromJson(Map<String, dynamic>.from(res.data as Map));
  }
}
