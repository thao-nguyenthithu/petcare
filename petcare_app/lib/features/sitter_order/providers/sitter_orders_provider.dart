import 'package:petcare_app/features/sitter_order/data/sitter_order_api.dart';
import 'package:petcare_app/features/sitter_order/services/sitter_orders_api_service.dart';
import 'package:petcare_app/shared/data/sitter_services.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'sitter_orders_provider.g.dart';

@riverpod
Future<TrangDonNcc> sitterBookings(
  Ref ref,
  ChipDonNcc chip,
  ServiceType? loai,
) => SitterOrdersApiService().danhSach(chip: chip, loai: loai);

@riverpod
Future<TomTatDonNcc> tomTatDonNcc(Ref ref) => SitterOrdersApiService().tomTat();

@riverpod
class ChiTietDonNcc extends _$ChiTietDonNcc {
  final _service = SitterOrdersApiService();

  @override
  Future<ChiTietDonNccApi> build(String bookingId) =>
      _service.chiTiet(bookingId);

  Future<void> chay(
    Future<void> Function(SitterOrdersApiService s) viec,
  ) async {
    await viec(_service);
    ref.invalidateSelf();
    await future;
  }

  Future<T> chayLay<T>(
    Future<T> Function(SitterOrdersApiService s) viec,
  ) async {
    final ketQua = await viec(_service);
    ref.invalidateSelf();
    await future;
    return ketQua;
  }
}
