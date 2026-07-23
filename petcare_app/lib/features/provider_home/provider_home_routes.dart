import 'package:go_router/go_router.dart';
import 'package:petcare_app/core/router/app_router.dart';
import 'package:petcare_app/features/provider_home/screens/provider_home_screen.dart';

// Route Home người cung cấp
final providerHomeRoutes = <RouteBase>[
  GoRoute(
    path: AppRoutes.providerHome,
    builder: (context, state) => const ProviderHomeScreen(),
  ),
];
