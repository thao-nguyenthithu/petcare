import 'package:go_router/go_router.dart';
import 'package:petcare_app/features/auth/screens/language_screen.dart';
import 'package:petcare_app/features/auth/screens/login_screen.dart';
import 'package:petcare_app/features/auth/screens/onboarding_screen.dart';
import 'package:petcare_app/features/auth/screens/splash_screen.dart';

/// Đường dẫn các màn hình trong app
class AppRoutes {
  AppRoutes._();

  static const String splash = '/';
  static const String language = '/language';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String register = '/register';
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
  ],
);
