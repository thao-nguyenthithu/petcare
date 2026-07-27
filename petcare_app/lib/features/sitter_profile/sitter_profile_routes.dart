import 'package:go_router/go_router.dart';
import 'package:petcare_app/core/router/app_router.dart';
import 'package:petcare_app/features/sitter_profile/screens/commitment_screen.dart';
import 'package:petcare_app/features/sitter_profile/screens/id_capture_screen.dart';
import 'package:petcare_app/features/sitter_profile/screens/id_photos_screen.dart';
import 'package:petcare_app/features/sitter_profile/screens/personal_info_screen.dart';
import 'package:petcare_app/features/sitter_profile/screens/profile_submitted_screen.dart';
import 'package:petcare_app/features/sitter_profile/screens/sitter_intro_screen.dart';

final sitterProfileRoutes = <RouteBase>[
  GoRoute(
    path: AppRoutes.sitterIntro,
    builder: (context, state) => const ProviderIntroScreen(),
  ),
  GoRoute(
    path: AppRoutes.sitterPersonalInfo,
    builder: (context, state) => const PersonalInfoScreen(),
  ),
  GoRoute(
    path: AppRoutes.sitterIdUpload,
    builder: (context, state) => const IdPhotosScreen(),
  ),
  GoRoute(
    path: AppRoutes.sitterIdCapture,
    builder: (context, state) =>
        IdCaptureScreen(title: state.extra as String? ?? ''),
  ),
  GoRoute(
    path: AppRoutes.sitterCommitment,
    builder: (context, state) => const CommitmentScreen(),
  ),
  GoRoute(
    path: AppRoutes.sitterSubmitted,
    builder: (context, state) => const ProfileSubmittedScreen(),
  ),
];
