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

/// Đường dẫn các màn hình trong app
class AppRoutes {
  AppRoutes._();

  static const String splash = '/';
  static const String language = '/language';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String register = '/register';
  static const String verifyEmail = '/verify-email';
  static const String forgotPassword = '/forgot-password';
  static const String otp = '/otp';
  static const String resetPassword = '/reset-password';
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
      builder: (context, state) =>
          VerifyEmailScreen(email: state.extra as String? ?? ''),
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
  ],
);
