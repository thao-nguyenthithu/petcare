import 'package:petcare_app/core/storage/token_storage.dart';
import 'package:petcare_app/features/auth/services/auth_api_service.dart';
import 'package:petcare_app/features/auth/services/social_auth_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:petcare_app/features/auth/providers/current_user_provider.dart';
import 'package:petcare_app/features/address/providers/saved_addresses_provider.dart';

part 'auth_provider.g.dart';

// Điều phối toàn bộ nghiệp vụ auth (đăng ký, xác minh, đăng nhập).
@Riverpod(keepAlive: true)
class AuthNotifier extends _$AuthNotifier {
  final _api = AuthApiService();
  final _social = SocialAuthService();
  final _tokenStorage = TokenStorageService();

  @override
  Future<bool> build() => _tokenStorage.hasToken();

  // Đăng ký tài khoản mới
  Future<void> register({
    required String fullName,
    required String email,
    required String phone,
    required String password,
  }) => _api.register(
    fullName: fullName,
    email: email,
    phone: phone,
    password: password,
  );

  Future<void> verifyEmail({required String email, required String otp}) =>
      _api.verifyEmail(email: email, otp: otp);

  Future<void> resendVerifyOtp(String email) => _api.resendVerifyOtp(email);

  Future<void> forgotPassword(String email) => _api.forgotPassword(email);

  Future<String> verifyResetOtp({required String email, required String otp}) =>
      _api.verifyResetOtp(email: email, otp: otp);

  Future<void> resetPassword({
    required String resetToken,
    required String newPassword,
  }) => _api.resetPassword(resetToken: resetToken, newPassword: newPassword);

  Future<void> login({required String email, required String password}) async {
    await _luuPhien(await _api.login(email: email, password: password));
  }

  Future<bool> loginGoogle() async {
    final idToken = await _social.signInWithGoogle();
    if (idToken == null) return false;
    await _luuPhien(await _api.loginGoogle(idToken));
    return true;
  }

  Future<bool> loginFacebook() async {
    final idToken = await _social.signInWithFacebook();
    if (idToken == null) return false;
    await _luuPhien(await _api.loginFacebook(idToken));
    return true;
  }

  // Đăng xuất
  Future<void> logout() async {
    await _tokenStorage.clearTokens();
    ref.invalidate(currentUserProvider);
    state = const AsyncData(false);
  }

  // Lưu access token và đánh dấu đã đăng nhập
  Future<void> _luuPhien(Map<String, dynamic> res) async {
    final token = res['accessToken'] as String?;
    if (token != null) {
      await _tokenStorage.saveAccessToken(token);
      ref.invalidate(currentUserProvider);
      ref.invalidate(savedAddressesProvider);
      state = const AsyncData(true);
    }
  }
}
