import 'package:go_router/go_router.dart';
import 'package:petcare_app/features/auth/screens/forgot_password_screen.dart';
import 'package:petcare_app/features/auth/screens/language_screen.dart';
import 'package:petcare_app/features/auth/screens/login_screen.dart';
import 'package:petcare_app/features/auth/screens/onboarding_screen.dart';
import 'package:petcare_app/features/auth/screens/otp_screen.dart';
import 'package:petcare_app/features/auth/screens/register_screen.dart';
import 'package:petcare_app/features/auth/screens/reset_password_screen.dart';
import 'package:petcare_app/features/auth/screens/splash_screen.dart';
import 'package:petcare_app/features/auth/screens/verify_email_screen.dart';
import 'package:petcare_app/features/auth/screens/verify_success_screen.dart';
import 'package:petcare_app/features/provider_profile/screens/add_service_screen.dart';
import 'package:petcare_app/features/provider_profile/screens/commitment_screen.dart';
import 'package:petcare_app/features/provider_profile/screens/id_upload_screen.dart';
import 'package:petcare_app/features/provider_profile/screens/personal_info_screen.dart';
import 'package:petcare_app/features/provider_profile/screens/profile_submitted_screen.dart';
import 'package:petcare_app/features/provider_profile/screens/service_list_screen.dart';

/// Đường dẫn các màn hình trong app
class AppRoutes {
  AppRoutes._();

  static const String splash = '/';
  static const String language = '/language';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String register = '/register';
  static const String verifyEmail = '/verify-email';
  static const String verifySuccess = '/verify-success';
  static const String forgotPassword = '/forgot-password';
  static const String otp = '/otp';
  static const String resetPassword = '/reset-password';
  static const String providerServices = '/provider-profile/services';
  static const String providerAddService = '/provider-profile/add-service';
  static const String providerPersonalInfo = '/provider-profile/personal-info';
  static const String providerIdUpload = '/provider-profile/id-upload';
  static const String providerCommitment = '/provider-profile/commitment';
  static const String providerSubmitted = '/provider-profile/submitted';
}

final appRouter = GoRouter(
  initialLocation: AppRoutes.splash,
  routes: [
    GoRoute(
      path: AppRoutes.splash,
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: AppRoutes.language,
      builder: (context, state) => const LanguageScreen(),
    ),
    GoRoute(
      path: AppRoutes.onboarding,
      builder: (context, state) => const OnboardingScreen(),
    ),
    GoRoute(
      path: AppRoutes.login,
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: AppRoutes.register,
      builder: (context, state) => const RegisterScreen(),
    ),
    GoRoute(
      path: AppRoutes.verifyEmail,
      builder: (context, state) {
        final email = state.extra as String?;
        return VerifyEmailScreen(email: email ?? '');
      },
    ),
    GoRoute(
      path: AppRoutes.verifySuccess,
      builder: (context, state) => const VerifySuccessScreen(),
    ),
    GoRoute(
      path: AppRoutes.forgotPassword,
      builder: (context, state) => const ForgotPasswordScreen(),
    ),
    GoRoute(
      path: AppRoutes.otp,
      builder: (context, state) => const OtpScreen(),
    ),
    GoRoute(
      path: AppRoutes.resetPassword,
      builder: (context, state) => const ResetPasswordScreen(),
    ),
    GoRoute(
      path: AppRoutes.providerServices,
      builder: (context, state) => const ServiceListScreen(),
    ),
    GoRoute(
      path: AppRoutes.providerAddService,
      builder: (context, state) => const AddServiceScreen(),
    ),
    GoRoute(
      path: AppRoutes.providerPersonalInfo,
      builder: (context, state) => const PersonalInfoScreen(),
    ),
    GoRoute(
      path: AppRoutes.providerIdUpload,
      builder: (context, state) => const IdUploadScreen(),
    ),
    GoRoute(
      path: AppRoutes.providerCommitment,
      builder: (context, state) => const CommitmentScreen(),
    ),
    GoRoute(
      path: AppRoutes.providerSubmitted,
      builder: (context, state) => const ProfileSubmittedScreen(),
    ),
  ],
);
