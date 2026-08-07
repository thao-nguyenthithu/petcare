import 'package:go_router/go_router.dart';
import 'package:petcare_app/core/router/app_router.dart';
import 'package:petcare_app/features/reviews/screens/owner_reviews_screen.dart';
import 'package:petcare_app/features/reviews/screens/sitter_all_reviews_screen.dart';
import 'package:petcare_app/features/reviews/screens/sitter_reviews_screen.dart';

final reviewsRoutes = <RouteBase>[
  GoRoute(
    path: AppRoutes.sitterReviews,
    builder: (context, state) => const SitterReviewsScreen(),
  ),
  GoRoute(
    path: AppRoutes.sitterAllReviews,
    builder: (context, state) =>
        SitterAllReviewsScreen(args: state.extra as SitterAllReviewsArgs),
  ),
  GoRoute(
    path: AppRoutes.ownerReviews,
    builder: (context, state) => const OwnerReviewsScreen(),
  ),
];
