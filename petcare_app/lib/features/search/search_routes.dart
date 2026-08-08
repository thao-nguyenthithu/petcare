import 'package:go_router/go_router.dart';
import 'package:petcare_app/core/router/app_router.dart';
import 'package:petcare_app/features/search/data/search_filter.dart';
import 'package:petcare_app/features/search/screens/search_filter_screen.dart';
import 'package:petcare_app/features/search/screens/search_map_screen.dart';
import 'package:petcare_app/features/search/screens/search_screen.dart';

// Route cụm tìm kiếm
final searchRoutes = <RouteBase>[
  GoRoute(
    path: AppRoutes.search,
    builder: (context, state) => SearchScreen(
      maDichVu: state.uri.queryParameters['service'],
      maSapXep: state.uri.queryParameters['sort'],
    ),
  ),
  GoRoute(
    path: AppRoutes.searchFilter,
    builder: (context, state) =>
        SearchFilterScreen(boLoc: state.extra as BoLocTimKiem),
  ),
  GoRoute(
    path: AppRoutes.searchMap,
    builder: (context, state) =>
        SearchMapScreen(boLoc: state.extra as BoLocTimKiem),
  ),
];
