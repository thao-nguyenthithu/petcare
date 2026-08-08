import 'package:go_router/go_router.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/router/app_router.dart';
import 'package:petcare_app/shared/data/sitter_booking.dart';
import 'package:petcare_app/features/sitter_order/data/ai_scan.dart';
import 'package:petcare_app/features/sitter_order/data/boarding_session.dart';
import 'package:petcare_app/features/sitter_order/data/sitter_session_map.dart';
import 'package:petcare_app/features/sitter_order/screens/sitter_absence_screen.dart';
import 'package:petcare_app/features/sitter_order/screens/sitter_ai_scan_screen.dart';
import 'package:petcare_app/features/sitter_order/screens/sitter_boarding_session_screen.dart';
import 'package:petcare_app/features/sitter_order/screens/sitter_booking_search_screen.dart';
import 'package:petcare_app/features/sitter_order/screens/sitter_bookings_screen.dart';
import 'package:petcare_app/features/sitter_order/screens/sitter_check_in_camera_screen.dart';
import 'package:petcare_app/features/sitter_order/screens/sitter_check_in_screen.dart';
import 'package:petcare_app/features/sitter_order/screens/sitter_daily_update_screen.dart';
import 'package:petcare_app/features/sitter_order/screens/sitter_evidence_screen.dart';
import 'package:petcare_app/features/sitter_order/screens/sitter_finish_boarding_screen.dart';
import 'package:petcare_app/features/sitter_order/screens/sitter_finish_grooming_screen.dart';
import 'package:petcare_app/features/sitter_order/screens/sitter_finish_walk_screen.dart';
import 'package:petcare_app/features/sitter_order/screens/sitter_grooming_photo_screen.dart';
import 'package:petcare_app/features/sitter_order/screens/sitter_grooming_session_screen.dart';
import 'package:petcare_app/features/sitter_order/screens/sitter_grooming_start_screen.dart';
import 'package:petcare_app/features/sitter_order/screens/sitter_handover_photo_screen.dart';
import 'package:petcare_app/features/sitter_order/screens/sitter_handover_screen.dart';
import 'package:petcare_app/features/sitter_order/screens/sitter_incident_screen.dart';
import 'package:petcare_app/features/sitter_order/screens/sitter_order_detail_screen.dart';
import 'package:petcare_app/features/sitter_order/screens/sitter_order_loader.dart';
import 'package:petcare_app/features/sitter_order/screens/sitter_wait_confirm_screen.dart';
import 'package:petcare_app/features/sitter_order/screens/sitter_walk_return_screen.dart';
import 'package:petcare_app/features/sitter_order/screens/sitter_walking_session_screen.dart';

String _id(GoRouterState state) => state.pathParameters['id'] ?? '';

final sitterOrderRoutes = <RouteBase>[
  GoRoute(
    path: AppRoutes.sitterBookings,
    builder: (context, state) => SitterBookingsScreen(
      chipBanDau: chipDonTuMa(state.uri.queryParameters['status']),
    ),
  ),
  GoRoute(
    path: AppRoutes.sitterBookingSearch,
    builder: (context, state) => const SitterBookingSearchScreen(),
  ),
  GoRoute(
    path: AppRoutes.sitterOrderDetail,
    builder: (context, state) => TaiDonNcc(
      bookingId: _id(state),
      builder: (context, don, api) =>
          SitterOrderDetailScreen(don: don, bookingId: _id(state)),
    ),
  ),

  GoRoute(
    path: AppRoutes.sitterHandoverCamera,
    builder: (context, state) {
      final loai = LoaiBanGiao.values.firstWhere(
        (l) => l.ma == state.uri.queryParameters['loai'],
        orElse: () => LoaiBanGiao.nhanBe,
      );
      return TaiDonNcc(
        bookingId: _id(state),
        builder: (context, don, api) =>
            SitterHandoverPhotoScreen(phien: kyGiuTuDon(don, api), loai: loai),
      );
    },
  ),
  GoRoute(
    path: AppRoutes.sitterHandover,
    builder: (context, state) {
      final anh = state.extra as AnhBanGiao?;
      return TaiDonNcc(
        bookingId: _id(state),
        builder: (context, don, api) => SitterHandoverScreen(
          args:
              anh ??
              (
                phien: kyGiuTuDon(don, api),
                loai: LoaiBanGiao.nhanBe,
                anhBe: const [],
                anhDoDung: const [],
              ),
        ),
      );
    },
  ),
  GoRoute(
    path: AppRoutes.sitterActiveBoarding,
    builder: (context, state) => TaiDonNcc(
      bookingId: _id(state),
      builder: (context, don, api) =>
          SitterBoardingSessionScreen(phien: kyGiuTuDon(don, api)),
    ),
  ),
  GoRoute(
    path: AppRoutes.sitterDailyUpdate,
    builder: (context, state) => TaiDonNcc(
      bookingId: _id(state),
      builder: (context, don, api) =>
          SitterDailyUpdateScreen(phien: kyGiuTuDon(don, api)),
    ),
  ),
  GoRoute(
    path: AppRoutes.sitterFinishBoarding,
    builder: (context, state) {
      final anh = state.extra as AnhBanGiao?;
      return TaiDonNcc(
        bookingId: _id(state),
        builder: (context, don, api) => SitterFinishBoardingScreen(
          args:
              anh ??
              (
                phien: kyGiuTuDon(don, api),
                loai: LoaiBanGiao.traBe,
                anhBe: const [],
                anhDoDung: const [],
              ),
        ),
      );
    },
  ),

  GoRoute(
    path: AppRoutes.sitterGroomingStart,
    builder: (context, state) => TaiDonNcc(
      bookingId: _id(state),
      builder: (context, don, api) => SitterGroomingStartScreen(don: don),
    ),
  ),
  GoRoute(
    path: AppRoutes.sitterGroomingPhotos,
    builder: (context, state) => TaiDonNcc(
      bookingId: _id(state),
      builder: (context, don, api) => SitterGroomingPhotoScreen(don: don),
    ),
  ),
  GoRoute(
    path: AppRoutes.sitterActiveGrooming,
    builder: (context, state) => TaiDonNcc(
      bookingId: _id(state),
      builder: (context, don, api) => SitterGroomingSessionScreen(
        phien: buoiGroomingTuDon(context.l10n, don, api),
      ),
    ),
  ),
  GoRoute(
    path: AppRoutes.sitterFinishGrooming,
    builder: (context, state) => TaiDonNcc(
      bookingId: _id(state),
      builder: (context, don, api) => SitterFinishGroomingScreen(
        phien: buoiGroomingTuDon(context.l10n, don, api),
      ),
    ),
  ),

  GoRoute(
    path: AppRoutes.sitterCheckIn,
    builder: (context, state) => TaiDonNcc(
      bookingId: _id(state),
      builder: (context, don, api) =>
          SitterCheckInScreen(args: checkInTuDon(don, api)),
    ),
  ),
  GoRoute(
    path: AppRoutes.sitterCheckInCamera,
    builder: (context, state) {
      final q = state.uri.queryParameters;
      return TaiDonNcc(
        bookingId: _id(state),
        builder: (context, don, api) => SitterCheckInCameraScreen(
          args: checkInTuDon(don, api),
          chupLaiO: int.tryParse(q['o'] ?? ''),
          conLai: int.tryParse(q['conLai'] ?? ''),
        ),
      );
    },
  ),
  GoRoute(
    path: AppRoutes.sitterAiScan,
    builder: (context, state) {
      final args = state.extra as KetQuaQuetArgs?;
      return TaiDonNcc(
        bookingId: _id(state),
        builder: (context, don, api) => SitterAiScanScreen(
          args: args?.checkIn ?? checkInTuDon(don, api),
          batchId: args?.batchId,
        ),
      );
    },
  ),

  GoRoute(
    path: AppRoutes.sitterActiveService,
    builder: (context, state) => TaiDonNcc(
      bookingId: _id(state),
      builder: (context, don, api) => SitterWalkingSessionScreen(
        phien: phienDatTuDon(context.l10n, _id(state), don, api),
      ),
    ),
  ),
  GoRoute(
    path: AppRoutes.sitterWalkReturn,
    builder: (context, state) => TaiDonNcc(
      bookingId: _id(state),
      builder: (context, don, api) => SitterWalkReturnScreen(
        phien: phienDatTuDon(context.l10n, _id(state), don, api),
      ),
    ),
  ),
  GoRoute(
    path: AppRoutes.sitterFinishWalk,
    builder: (context, state) => TaiDonNcc(
      bookingId: _id(state),
      builder: (context, don, api) => SitterFinishWalkScreen(
        phien: phienDatTuDon(context.l10n, _id(state), don, api),
      ),
    ),
  ),

  GoRoute(
    path: AppRoutes.sitterAbsence,
    builder: (context, state) => TaiDonNcc(
      bookingId: _id(state),
      builder: (context, don, api) =>
          SitterAbsenceScreen(bao: baoVangMatTuDon(don, api)),
    ),
  ),
  GoRoute(
    path: AppRoutes.sitterIncident,
    builder: (context, state) => TaiDonNcc(
      bookingId: _id(state),
      builder: (context, don, api) => SitterIncidentScreen(don: don),
    ),
  ),
  GoRoute(
    path: AppRoutes.sitterEvidence,
    builder: (context, state) => TaiDonNcc(
      bookingId: _id(state),
      builder: (context, don, api) => SitterEvidenceScreen(don: don),
    ),
  ),
  GoRoute(
    path: AppRoutes.sitterWaitConfirm,
    builder: (context, state) => TaiDonNcc(
      bookingId: _id(state),
      builder: (context, don, api) => SitterWaitConfirmScreen(don: don),
    ),
  ),
];
