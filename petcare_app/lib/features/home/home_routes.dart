import 'package:go_router/go_router.dart';
import 'package:petcare_app/core/router/app_router.dart';
import 'package:petcare_app/features/home/screens/home_screen.dart';

// Route cụm home (bottom nav 4 tab)
final homeRoutes = <RouteBase>[
  GoRoute(
    path: AppRoutes.home,
    builder: (context, state) => const HomeScreen(),
  ),
];
