import 'dart:typed_data';

enum Gender { male, female, other }

// Hồ sơ NCC qua bước đăng ký
class DkSitterDraft {
  // Bước 1 thông tin cá nhân
  final String? legalName;
  final Gender? gender;
  final DateTime? dateOfBirth;
  final String? nationalId;
  final String? idIssuedPlace;
  final DateTime? idIssuedDate;
  final String? province;
  final String? addressDetail;

  // Bước 2 ảnh CCCD
  final Uint8List? idCardFront;
  final Uint8List? idCardBack;

  const DkSitterDraft({
    this.legalName,
    this.gender,
    this.dateOfBirth,
    this.nationalId,
    this.idIssuedPlace,
    this.idIssuedDate,
    this.province,
    this.addressDetail,
    this.idCardFront,
    this.idCardBack,
  });

  DkSitterDraft copyWith({
    String? legalName,
    Gender? gender,
    DateTime? dateOfBirth,
    String? nationalId,
    String? idIssuedPlace,
    DateTime? idIssuedDate,
    String? province,
    String? addressDetail,
    Uint8List? idCardFront,
    Uint8List? idCardBack,
  }) => DkSitterDraft(
    legalName: legalName ?? this.legalName,
    gender: gender ?? this.gender,
    dateOfBirth: dateOfBirth ?? this.dateOfBirth,
    nationalId: nationalId ?? this.nationalId,
    idIssuedPlace: idIssuedPlace ?? this.idIssuedPlace,
    idIssuedDate: idIssuedDate ?? this.idIssuedDate,
    province: province ?? this.province,
    addressDetail: addressDetail ?? this.addressDetail,
    idCardFront: idCardFront ?? this.idCardFront,
    idCardBack: idCardBack ?? this.idCardBack,
  );
}
