import 'dart:async';
import 'package:petcare_app/core/storage/token_storage.dart';
import 'package:petcare_app/core/services/notify_socket_service.dart';
import 'package:petcare_app/core/services/push_service.dart';
import 'package:petcare_app/features/auth/services/auth_api_service.dart';
import 'package:petcare_app/features/auth/services/social_auth_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:petcare_app/features/address/providers/saved_addresses_provider.dart';
import 'package:petcare_app/features/booking/providers/owner_booking_detail_provider.dart';
import 'package:petcare_app/features/sitter_order/providers/sitter_orders_provider.dart';
import 'package:petcare_app/features/booking/providers/owner_bookings_provider.dart';
import 'package:petcare_app/features/pets/providers/my_pets_provider.dart';
import 'package:petcare_app/features/auth/providers/current_user_provider.dart';
import 'package:petcare_app/features/sitter/providers/sitter_profile_provider.dart';
import 'package:petcare_app/features/sitter/providers/sitter_schedule_provider.dart';
import 'package:petcare_app/features/sitter/providers/sitter_services_provider.dart';
import 'package:petcare_app/features/dksitter/providers/dksitter_provider.dart';
import 'package:petcare_app/features/messaging/providers/conversations_provider.dart';
import 'package:petcare_app/features/notification/providers/notifications_provider.dart';
import 'package:petcare_app/features/home/providers/owner_home_provider.dart';
import 'package:petcare_app/features/sitter/providers/sitter_home_provider.dart';
import 'package:petcare_app/features/wallet/providers/wallet_provider.dart';
import 'package:petcare_app/features/owner_wallet/providers/owner_payments_provider.dart';
import 'package:petcare_app/features/reviews/providers/reviews_provider.dart';
import 'package:petcare_app/features/search/providers/search_history_provider.dart';
import 'package:petcare_app/features/sitter_order/services/walk_tracking_controller.dart';

part 'auth_provider.g.dart';

// Điều phối toàn bộ nghiệp vụ auth (đăng ký, xác minh, đăng nhập).
@Riverpod(keepAlive: true)
class AuthNotifier extends _$AuthNotifier {
  final _api = AuthApiService();
  final _social = SocialAuthService();
  final _tokenStorage = TokenStorageService();

  @override
  Future<bool> build() async {
    final coPhien = await _tokenStorage.hasToken();
    if (coPhien) {
      unawaited(PushService.instance.dangKy());
      unawaited(NotifySocketService.instance.ketNoi());
    }
    return coPhien;
  }

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
    await WalkTrackingController.dungPhien();
    NotifySocketService.instance.dong();
    await PushService.instance.huyDangKy();
    await _tokenStorage.clearTokens();
    _resetPhienNguoiDung();
    state = const AsyncData(false);
  }

  // Lưu access token và đánh dấu đã đăng nhập
  Future<void> _luuPhien(Map<String, dynamic> res) async {
    final token = res['accessToken'] as String?;
    if (token != null) {
      await _tokenStorage.saveAccessToken(token);
      _resetPhienNguoiDung();
      state = const AsyncData(true);
      unawaited(PushService.instance.dangKy());
      unawaited(NotifySocketService.instance.ketNoi());
    }
  }

  void _resetPhienNguoiDung() => ref.refreshUserData();
}

final _providerNguoiDung = <ProviderOrFamily>[
  currentUserProvider,
  savedAddressesProvider,
  myPetsProvider,
  ownerBookingsProvider,
  bookingDetailProvider,
  sitterBookingsProvider,
  tomTatDonNccProvider,
  chiTietDonNccProvider,
  sitterStatusProvider,
  thongBaoCuaToiProvider,
  sitterMeProvider,
  sitterServicesProvider,
  sitterServiceAreaProvider,
  sitterScheduleProvider,
  hoiThoaiChuNuoiProvider,
  hoiThoaiNguoiChamProvider,
  trangChuCuaToiProvider,
  trangChuNguoiChamProvider,
  viCuaToiProvider,
  taiKhoanNhanTienProvider,
  tienDangTamGiuProvider,
  danhGiaVeToiProvider,
  danhGiaCuaToiProvider,
  donChoDanhGiaCuaToiProvider,
  lichSuTimProvider,
  dkSitterProvider,
];

// Làm mới dữ liệu gắn với người dùng đang đăng nhập
extension UserDataRefreshRef on Ref {
  void refreshUserData() => _providerNguoiDung.forEach(invalidate);
}

extension UserDataRefreshWidgetRef on WidgetRef {
  void refreshUserData() => _providerNguoiDung.forEach(invalidate);
}
