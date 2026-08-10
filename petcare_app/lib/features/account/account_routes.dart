import 'package:go_router/go_router.dart';
import 'package:petcare_app/core/router/app_router.dart';
import 'package:petcare_app/features/account/screens/help_center_screen.dart';
import 'package:petcare_app/features/account/screens/owner_profile_edit_screen.dart';
import 'package:petcare_app/features/account/screens/owner_profile_screen.dart';

// Màn hồ sơ của chủ nuôi
final accountRoutes = <RouteBase>[
  GoRoute(
    path: AppRoutes.ownerProfile,
    builder: (context, state) => const OwnerProfileScreen(),
  ),
  GoRoute(
    path: AppRoutes.ownerProfileEdit,
    builder: (context, state) => const OwnerProfileEditScreen(),
  ),
  GoRoute(
    path: AppRoutes.helpCenter,
    builder: (context, state) => const HelpCenterScreen(),
  ),
];
