import 'package:go_router/go_router.dart';
import 'package:petcare_app/core/router/app_router.dart';
import 'package:petcare_app/features/messaging/screens/chat_detail_screen.dart';

// Định tuyến màn chat chi tiết
final messagingRoutes = <RouteBase>[
  GoRoute(
    path: AppRoutes.chatThread,
    builder: (context, state) {
      final args = state.extra as ChatArgs;
      return ChatDetailScreen(
        conversation: args.conversation,
        isOwner: args.isOwner,
      );
    },
  ),
];
