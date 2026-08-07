import 'package:go_router/go_router.dart';
import 'package:petcare_app/core/router/app_router.dart';
import 'package:petcare_app/features/notification/screens/notification_screen.dart';

// Route cụm thông báo
final notificationRoutes = <RouteBase>[
  GoRoute(
    path: AppRoutes.notifications,
    builder: (context, state) => NotificationScreen(
      dangCheDoNcc: state.uri.queryParameters['che-do'] == 'ncc',
    ),
  ),
];
