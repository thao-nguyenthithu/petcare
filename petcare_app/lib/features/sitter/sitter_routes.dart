import 'package:go_router/go_router.dart';
import 'package:petcare_app/core/router/app_router.dart';
import 'package:petcare_app/shared/data/sitter_services.dart';
import 'package:petcare_app/features/sitter/screens/my_services_screen.dart';
import 'package:petcare_app/features/sitter/screens/service_form_screen.dart';
import 'package:petcare_app/features/sitter/screens/sitter_profile_edit_screen.dart';
import 'package:petcare_app/features/sitter/screens/sitter_all_photos_screen.dart';
import 'package:petcare_app/features/sitter/screens/sitter_availability_screen.dart';
import 'package:petcare_app/features/sitter/screens/sitter_home_screen.dart';
import 'package:petcare_app/features/sitter/screens/sitter_public_view_screen.dart';
import 'package:petcare_app/features/sitter/screens/sitter_service_area_screen.dart';

final sitterRoutes = <RouteBase>[
  GoRoute(
    path: AppRoutes.sitterHome,
    builder: (context, state) => const SitterHomeScreen(),
  ),
  GoRoute(
    path: AppRoutes.sitterServices,
    builder: (context, state) => const MyServicesScreen(),
  ),
  GoRoute(
    path: AppRoutes.sitterAddService,
    builder: (context, state) {
      final args = state.extra as (ServiceType, SitterServices);
      return ServiceFormScreen(type: args.$1, services: args.$2);
    },
  ),
  GoRoute(
    path: AppRoutes.sitterServiceArea,
    builder: (context, state) => const SitterServiceAreaScreen(),
  ),
  GoRoute(
    path: AppRoutes.sitterProfileEdit,
    builder: (context, state) => const SitterProfileEditScreen(),
  ),
  GoRoute(
    path: AppRoutes.sitterAvailability,
    builder: (context, state) =>
        SitterAvailabilityScreen(args: state.extra as SitterAvailabilityArgs),
  ),
  GoRoute(
    path: AppRoutes.sitterProfileView,
    builder: (context, state) => const SitterPublicViewScreen(),
  ),
  GoRoute(
    path: AppRoutes.sitterDetail,
    builder: (context, state) =>
        SitterPublicViewScreen(sitterId: state.pathParameters['id']),
  ),
  GoRoute(
    path: AppRoutes.sitterAllPhotos,
    builder: (context, state) => const SitterAllPhotosScreen(),
  ),
];
