import 'package:go_router/go_router.dart';
import 'package:petcare_app/core/router/app_router.dart';
import 'package:petcare_app/features/provider_profile/data/service_draft.dart';
import 'package:petcare_app/features/provider_profile/screens/commitment_screen.dart';
import 'package:petcare_app/features/provider_profile/screens/id_capture_screen.dart';
import 'package:petcare_app/features/provider_profile/screens/id_photos_screen.dart';
import 'package:petcare_app/features/provider_profile/screens/my_services_screen.dart';
import 'package:petcare_app/features/provider_profile/screens/personal_info_screen.dart';
import 'package:petcare_app/features/provider_profile/screens/profile_submitted_screen.dart';
import 'package:petcare_app/features/provider_profile/screens/provider_intro_screen.dart';
import 'package:petcare_app/features/provider_profile/screens/service_form_screen.dart';

// Route cụm hồ sơ NCC: intro, thông tin cá nhân, CCCD, cam kết, đã gửi, quản lý dịch vụ
final providerProfileRoutes = <RouteBase>[
  GoRoute(
    path: AppRoutes.providerIntro,
    builder: (context, state) => const ProviderIntroScreen(),
  ),
  GoRoute(
    path: AppRoutes.providerServices,
    builder: (context, state) => const MyServicesScreen(),
  ),
  GoRoute(
    path: AppRoutes.providerAddService,
    builder: (context, state) =>
        ServiceFormScreen(banDau: state.extra as ServiceDraft?),
  ),
  GoRoute(
    path: AppRoutes.providerPersonalInfo,
    builder: (context, state) => const PersonalInfoScreen(),
  ),
  GoRoute(
    path: AppRoutes.providerIdUpload,
    builder: (context, state) => const IdPhotosScreen(),
  ),
  GoRoute(
    path: AppRoutes.providerIdCapture,
    builder: (context, state) =>
        IdCaptureScreen(title: state.extra as String? ?? ''),
  ),
  GoRoute(
    path: AppRoutes.providerCommitment,
    builder: (context, state) => const CommitmentScreen(),
  ),
  GoRoute(
    path: AppRoutes.providerSubmitted,
    builder: (context, state) => const ProfileSubmittedScreen(),
  ),
];
