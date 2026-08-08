import 'package:petcare_app/features/wallet/data/wallet_api.dart';
import 'package:petcare_app/features/wallet/providers/wallet_refresh.dart';
import 'package:petcare_app/features/wallet/services/wallet_api_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'wallet_provider.g.dart';

// Cụm ví của người chăm

@Riverpod(keepAlive: true)
class ViCuaToi extends _$ViCuaToi {
  final _service = WalletApiService();

  @override
  Future<ViApi> build() => _service.vi();

  Future<void> taiLai() async {
    state = await AsyncValue.guard(_service.vi);
  }
}

@riverpod
Future<TrangGiaoDichVi> lichSuVi(Ref ref, String? loai) =>
    WalletApiService().lichSu(loai: loai);

@riverpod
Future<ChiTietGiaoDichApi> chiTietGiaoDichVi(Ref ref, String ma) =>
    WalletApiService().chiTiet(ma);

@Riverpod(keepAlive: true)
class TaiKhoanNhanTien extends _$TaiKhoanNhanTien {
  final _service = WalletApiService();

  @override
  Future<TaiKhoanNganHangApi?> build() => _service.taiKhoan();

  Future<void> luu({
    required String tenNganHang,
    required String soTaiKhoan,
    required String tenChuTaiKhoan,
  }) async {
    final moi = await _service.luuTaiKhoan(
      tenNganHang: tenNganHang,
      soTaiKhoan: soTaiKhoan,
      tenChuTaiKhoan: tenChuTaiKhoan,
    );
    state = AsyncData(moi);
    ref.refreshWalletData(boQua: [taiKhoanNhanTienProvider]);
  }
}

@riverpod
Future<HoSoKhieuNaiApi> hoSoKhieuNai(Ref ref, String ma) =>
    WalletApiService().khieuNaiTheoMa(ma);

@riverpod
Future<ThuNhapApi> thuNhapTheoKy(Ref ref, String ky) =>
    WalletApiService().thuNhap(ky);

@riverpod
WalletApiService walletApi(Ref ref) => WalletApiService();
