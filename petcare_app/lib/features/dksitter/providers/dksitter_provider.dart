import 'dart:typed_data';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:petcare_app/features/dksitter/data/dksitter_draft.dart';
import 'package:petcare_app/features/dksitter/services/id_card_upload_service.dart';
import 'package:petcare_app/features/dksitter/services/dksitter_api_service.dart';

part 'dksitter_provider.g.dart';

// Gom dữ liệu hồ sơ NCC rồi gửi lên ở bước cam kết
@Riverpod(keepAlive: true)
class DkSitterNotifier extends _$DkSitterNotifier {
  final _api = DkSitterApiService();
  final _upload = IdCardUploadService();

  @override
  DkSitterDraft build() => const DkSitterDraft();

  // Bước 1 lưu thông tin cá nhân
  void luuThongTinCaNhan({
    required String legalName,
    required Gender gender,
    required DateTime dateOfBirth,
    required String nationalId,
    required String idIssuedPlace,
    required DateTime idIssuedDate,
    required String province,
    required String addressDetail,
  }) {
    state = state.copyWith(
      legalName: legalName,
      gender: gender,
      dateOfBirth: dateOfBirth,
      nationalId: nationalId,
      idIssuedPlace: idIssuedPlace,
      idIssuedDate: idIssuedDate,
      province: province,
      addressDetail: addressDetail,
    );
  }

  // Kiểm tra CCCD trùng ở bước nhập thông tin
  Future<bool> kiemTraCccd(String nationalId) =>
      _api.isCccdAvailable(nationalId);

  // Bước 2 lưu bytes ảnh CCCD
  void luuAnhCccd({Uint8List? matTruoc, Uint8List? matSau}) {
    state = state.copyWith(idCardFront: matTruoc, idCardBack: matSau);
  }

  // Bước 3 upload ảnh rồi gửi hồ sơ
  Future<void> guiHoSo() async {
    final d = state;
    final pathTruoc = await _upload.upload(d.idCardFront!, mat: 'front');
    final pathSau = await _upload.upload(d.idCardBack!, mat: 'back');
    await _api.submit(
      legalName: d.legalName!,
      gender: d.gender!,
      dateOfBirth: d.dateOfBirth!,
      nationalId: d.nationalId!,
      idIssuedPlace: d.idIssuedPlace!,
      idIssuedDate: d.idIssuedDate!,
      province: d.province!,
      addressDetail: d.addressDetail!,
      cccdFrontPath: pathTruoc,
      cccdBackPath: pathSau,
    );
    ref.invalidate(sitterStatusProvider);
  }
}

// Trạng thái hồ sơ NCC của user hiện tại
@Riverpod(keepAlive: true)
Future<String?> sitterStatus(Ref ref) => DkSitterApiService().profileStatus();
