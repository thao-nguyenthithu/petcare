import 'dart:typed_data';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:petcare_app/core/utils/vn_date.dart';
import 'package:petcare_app/features/dksitter/data/dksitter_draft.dart';
import 'package:petcare_app/features/auth/providers/current_user_provider.dart';
import 'package:petcare_app/features/dksitter/services/id_card_upload_service.dart';
import 'package:petcare_app/features/dksitter/services/dksitter_api_service.dart';
import 'package:petcare_app/features/auth/providers/profile_refresh.dart';

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

  // Nạp lại hồ sơ đã nộp để sửa, ảnh cũ giữ theo đường dẫn chứ không tải về
  Future<void> napHoSoDaGui() async {
    final hoSo = await _api.getMine();
    state = DkSitterDraft(
      legalName: hoSo['legalName'] as String?,
      gender: _docGioiTinh(hoSo['gender'] as String?),
      dateOfBirth: docMocVn(hoSo['dateOfBirth'] as String?),
      nationalId: hoSo['nationalId'] as String?,
      idIssuedPlace: hoSo['idIssuedPlace'] as String?,
      idIssuedDate: docMocVn(hoSo['idIssuedDate'] as String?),
      province: hoSo['province'] as String?,
      addressDetail: hoSo['addressDetail'] as String?,
    );
  }

  static Gender? _docGioiTinh(String? ma) => switch (ma) {
    'MALE' => Gender.male,
    'FEMALE' => Gender.female,
    'OTHER' => Gender.other,
    _ => null,
  };

  // Bước 3 upload ảnh rồi gửi hồ sơ
  Future<void> guiHoSo() async {
    final d = state;
    final [pathTruoc, pathSau] = await Future.wait([
      _upload.upload(d.idCardFront!, mat: 'front'),
      _upload.upload(d.idCardBack!, mat: 'back'),
    ]);
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
    state = const DkSitterDraft();
    ref.refreshProfileData();
  }
}

@Riverpod(keepAlive: true)
Future<String?> sitterStatus(Ref ref) async =>
    (await ref.watch(currentUserProvider.future)).sitterStatus;
