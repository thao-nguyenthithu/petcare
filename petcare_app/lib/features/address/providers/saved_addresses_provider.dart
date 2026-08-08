import 'package:petcare_app/shared/data/saved_address.dart';
import 'package:petcare_app/features/address/services/address_api_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'saved_addresses_provider.g.dart';

// Danh sách địa chỉ đã lưu, lấy từ API /addresses
@Riverpod(keepAlive: true)
class SavedAddresses extends _$SavedAddresses {
  final _service = AddressApiService();

  @override
  Future<List<SavedAddress>> build() => _service.danhSach();

  Future<void> _taiLai() async {
    state = await AsyncValue.guard(_service.danhSach);
  }

  Future<void> chonMacDinh(String id) async {
    await _service.chonMacDinh(id);
    await _taiLai();
  }

  Future<void> them(SavedAddress diaChi) async {
    await _service.them(diaChi);
    await _taiLai();
  }

  Future<void> capNhat(SavedAddress diaChi) async {
    await _service.capNhat(diaChi);
    await _taiLai();
  }

  Future<void> xoa(String id) async {
    await _service.xoa(id);
    await _taiLai();
  }

  Future<void> xoaNhieu(Set<String> ids) async {
    for (final id in ids) {
      await _service.xoa(id);
    }
    await _taiLai();
  }
}
