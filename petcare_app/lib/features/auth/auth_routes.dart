import 'package:go_router/go_router.dart';
import 'package:petcare_app/core/router/app_router.dart';
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

// Route cụm auth: splash, chọn ngôn ngữ, onboarding, đăng nhập/ký, OTP, quên mật khẩu
final authRoutes = <RouteBase>[
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
    path: AppRoutes.verifySuccess,
    builder: (context, state) => const VerifySuccessScreen(),
  ),
  GoRoute(
    path: AppRoutes.forgotPassword,
    builder: (context, state) => const ForgotPasswordScreen(),
  ),
  GoRoute(
    path: AppRoutes.otp,
    builder: (context, state) => OtpScreen(email: state.extra as String? ?? ''),
  ),
  GoRoute(
    path: AppRoutes.resetPassword,
    builder: (context, state) =>
        ResetPasswordScreen(resetToken: state.extra as String? ?? ''),
  ),
];
