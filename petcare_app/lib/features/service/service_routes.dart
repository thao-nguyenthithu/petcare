import 'package:go_router/go_router.dart';
import 'package:petcare_app/core/router/app_router.dart';
import 'package:petcare_app/features/service/screens/service_catalog_screen.dart';

// Route cụm dịch vụ cho bé
final serviceRoutes = <RouteBase>[
  GoRoute(
    path: AppRoutes.services,
    builder: (context, state) => const ServiceCatalogScreen(),
  ),
];
