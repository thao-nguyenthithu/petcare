import 'package:go_router/go_router.dart';
import 'package:petcare_app/core/router/app_router.dart';
import 'package:petcare_app/features/search/screens/search_screen.dart';

// Route cụm tìm kiếm
final searchRoutes = <RouteBase>[
  GoRoute(
    path: AppRoutes.search,
    builder: (context, state) => const SearchScreen(),
  ),
];
