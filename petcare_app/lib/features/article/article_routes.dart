import 'package:go_router/go_router.dart';
import 'package:petcare_app/core/router/app_router.dart';
import 'package:petcare_app/features/article/screens/article_screen.dart';

// Route cụm bài viết / mẹo chăm sóc
final articleRoutes = <RouteBase>[
  GoRoute(
    path: AppRoutes.articles,
    builder: (context, state) => const ArticleScreen(),
  ),
];
