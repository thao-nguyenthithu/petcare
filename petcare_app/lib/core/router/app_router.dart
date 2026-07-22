import 'package:go_router/go_router.dart';
import 'package:petcare_app/core/storage/token_storage.dart';
import 'package:petcare_app/features/address/address_routes.dart';
import 'package:petcare_app/features/article/article_routes.dart';
import 'package:petcare_app/features/auth/auth_routes.dart';
import 'package:petcare_app/features/home/home_routes.dart';
import 'package:petcare_app/features/notification/notification_routes.dart';
import 'package:petcare_app/features/provider_profile/provider_profile_routes.dart';
import 'package:petcare_app/features/search/search_routes.dart';
import 'package:petcare_app/features/service/service_routes.dart';

// Đường dẫn các màn — tập trung một chỗ để tra nhanh + tránh trùng.
class AppRoutes {
  AppRoutes._();

  static const String splash = '/';
  static const String language = '/language';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String verifyEmail = '/verify-email';
  static const String verifySuccess = '/verify-success';
  static const String forgotPassword = '/forgot-password';
  static const String otp = '/otp';
  static const String resetPassword = '/reset-password';
  static const String articles = '/articles';
  static const String notifications = '/notifications';
  static const String search = '/search';
  static const String services = '/services';
  static const String addresses = '/address';
  static const String addAddress = '/address/add';
  static const String locationPicker = '/address/pick-location';
  static const String providerIntro = '/provider-profile/intro';
  static const String providerServices = '/provider-profile/services';
  static const String providerAddService = '/provider-profile/add-service';
  static const String providerPersonalInfo = '/provider-profile/personal-info';
  static const String providerIdUpload = '/provider-profile/id-upload';
  static const String providerIdCapture = '/provider-profile/id-capture';
  static const String providerCommitment = '/provider-profile/commitment';
  static const String providerSubmitted = '/provider-profile/submitted';
}

// Màn không cần đăng nhập
const _manCongKhai = {
  AppRoutes.splash,
  AppRoutes.language,
  AppRoutes.onboarding,
  AppRoutes.login,
  AppRoutes.register,
  AppRoutes.verifyEmail,
  AppRoutes.verifySuccess,
  AppRoutes.forgotPassword,
  AppRoutes.otp,
  AppRoutes.resetPassword,
};

Future<String?> _guardDangNhap(_, GoRouterState state) async {
  if (_manCongKhai.contains(state.matchedLocation)) return null;
  final coToken = await TokenStorageService().hasToken();
  return coToken ? null : AppRoutes.login;
}

final appRouter = GoRouter(
  initialLocation: AppRoutes.home,
  redirect: _guardDangNhap,
  routes: [
    ...authRoutes,
    ...homeRoutes,
    ...addressRoutes,
    ...providerProfileRoutes,
    ...articleRoutes,
    ...notificationRoutes,
    ...searchRoutes,
    ...serviceRoutes,
  ],
);
