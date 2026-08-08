import 'package:petcare_app/features/owner_wallet/data/owner_payment_api.dart';
import 'package:petcare_app/features/owner_wallet/services/owner_payments_api_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'owner_payments_provider.g.dart';

// Cụm thanh toán chủ nuôi

@Riverpod(keepAlive: true)
class TienDangTamGiu extends _$TienDangTamGiu {
  final _service = OwnerPaymentsApiService();

  @override
  Future<TienDangGiuApi> build() => _service.dangTamGiu();

  Future<void> taiLai() async {
    state = await AsyncValue.guard(_service.dangTamGiu);
  }
}

@riverpod
Future<List<GiaoDichChuNuoiApi>> lichSuThanhToan(Ref ref, String? loai) =>
    OwnerPaymentsApiService().lichSu(loai: loai);

@riverpod
Future<ChiTietThanhToanApi> chiTietThanhToan(Ref ref, String ma) =>
    OwnerPaymentsApiService().chiTiet(ma);

@riverpod
Future<ChiTieuApi> chiTieuTheoKy(Ref ref, String ky) =>
    OwnerPaymentsApiService().chiTieu(ky);
