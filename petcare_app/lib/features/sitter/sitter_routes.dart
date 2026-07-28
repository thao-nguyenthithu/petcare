import 'package:go_router/go_router.dart';
import 'package:petcare_app/core/router/app_router.dart';
import 'package:petcare_app/features/booking/screens/sitter_bookings_screen.dart';
import 'package:petcare_app/features/booking/screens/sitter_order_confirmed_screen.dart';
import 'package:petcare_app/features/sitter/data/sitter_services.dart';
import 'package:petcare_app/features/sitter/screens/my_services_screen.dart';
import 'package:petcare_app/features/sitter/screens/service_form_screen.dart';
import 'package:petcare_app/features/sitter/screens/sitter_earnings_screen.dart';
import 'package:petcare_app/features/sitter/screens/sitter_profile_edit_screen.dart';
import 'package:petcare_app/features/sitter/screens/sitter_all_photos_screen.dart';
import 'package:petcare_app/features/sitter/screens/sitter_home_screen.dart';
import 'package:petcare_app/features/sitter/screens/sitter_public_view_screen.dart';
import 'package:petcare_app/features/sitter/screens/sitter_service_area_screen.dart';
import 'package:petcare_app/features/reviews/screens/sitter_reviews_screen.dart';
import 'package:petcare_app/features/service_session/screens/sitter_active_service_screen.dart';
import 'package:petcare_app/features/service_session/screens/sitter_evidence_screen.dart';
import 'package:petcare_app/features/service_session/screens/sitter_incident_screen.dart';
import 'package:petcare_app/features/service_session/screens/sitter_wait_confirm_screen.dart';

// Route Home người cung cấp
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
    path: AppRoutes.sitterEarnings,
    builder: (context, state) => const SitterEarningsScreen(),
  ),
  GoRoute(
    path: AppRoutes.sitterBookings,
    builder: (context, state) => const SitterBookingsScreen(),
  ),
  GoRoute(
    path: AppRoutes.sitterOrderConfirmed,
    builder: (context, state) => const SitterOrderConfirmedScreen(),
  ),
  GoRoute(
    path: AppRoutes.sitterReviews,
    builder: (context, state) => const SitterReviewsScreen(),
  ),
  GoRoute(
    path: AppRoutes.sitterProfileEdit,
    builder: (context, state) => const SitterProfileEditScreen(),
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
  GoRoute(
    path: AppRoutes.sitterIncident,
    builder: (context, state) => const SitterIncidentScreen(),
  ),
  GoRoute(
    path: AppRoutes.sitterActiveService,
    builder: (context, state) => const SitterActiveServiceScreen(),
  ),
  GoRoute(
    path: AppRoutes.sitterEvidence,
    builder: (context, state) => const SitterEvidenceScreen(),
  ),
  GoRoute(
    path: AppRoutes.sitterWaitConfirm,
    builder: (context, state) => const SitterWaitConfirmScreen(),
  ),
];
