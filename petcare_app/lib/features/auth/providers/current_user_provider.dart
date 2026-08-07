import 'package:petcare_app/core/utils/vn_date.dart';
import 'package:petcare_app/features/auth/services/auth_api_service.dart';
import 'package:petcare_app/shared/data/vai_tro.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'current_user_provider.g.dart';

// Hồ sơ người dùng đang đăng nhập, lấy từ GET /auth/me
class CurrentUser {
  const CurrentUser({
    required this.fullName,
    this.avatarUrl,
    this.email,
    this.phone,
    this.dateOfBirth,
    this.emailVerified = false,
    this.roles = const [VaiTro.chuNuoi],
    this.sitterStatus,
  });

  final String fullName;
  final String? avatarUrl;
  final String? email;
  final String? phone;
  final List<String> roles;
  final String? sitterStatus;

  bool get laNguoiCham => roles.contains(VaiTro.nguoiCham);

  final DateTime? dateOfBirth;
  final bool emailVerified;

  factory CurrentUser.fromJson(Map<String, dynamic> json) => CurrentUser(
    fullName: (json['fullName'] as String?) ?? '',
    avatarUrl: json['avatarUrl'] as String?,
    email: json['email'] as String?,
    phone: json['phone'] as String?,
    dateOfBirth: docMocVn(json['dateOfBirth'] as String?),
    emailVerified: (json['isVerified'] as bool?) ?? false,
    roles: [
      for (final v in (json['roles'] as List?) ?? const [VaiTro.chuNuoi])
        v as String,
    ],
    sitterStatus: json['sitterStatus'] as String?,
  );
}

@Riverpod(keepAlive: true)
Future<CurrentUser> currentUser(Ref ref) async {
  return CurrentUser.fromJson(await AuthApiService().getMe());
}
