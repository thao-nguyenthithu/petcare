import 'package:petcare_app/features/auth/services/auth_api_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'current_user_provider.g.dart';

// Hồ sơ người dùng đang đăng nhập, lấy từ GET /auth/me
class CurrentUser {
  const CurrentUser({required this.fullName, this.avatarUrl});

  final String fullName;
  final String? avatarUrl;

  factory CurrentUser.fromJson(Map<String, dynamic> json) => CurrentUser(
    fullName: (json['fullName'] as String?) ?? '',
    avatarUrl: json['avatarUrl'] as String?,
  );
}

@Riverpod(keepAlive: true)
Future<CurrentUser> currentUser(Ref ref) async {
  return CurrentUser.fromJson(await AuthApiService().getMe());
}
