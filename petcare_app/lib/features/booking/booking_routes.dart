import 'package:go_router/go_router.dart';
import 'package:petcare_app/core/router/app_router.dart';
import 'package:petcare_app/features/booking/data/booking_draft.dart';
import 'package:petcare_app/features/booking/data/owner_booking_detail.dart';
import 'package:petcare_app/features/booking/data/payment_result.dart';
import 'package:petcare_app/features/booking/data/payment_session.dart';
import 'package:petcare_app/features/booking/screens/boarding_early_end_screen.dart';
import 'package:petcare_app/features/booking/screens/boarding_stay_log_screen.dart';
import 'package:petcare_app/features/booking/screens/booking_boarding_screen.dart';
import 'package:petcare_app/features/booking/screens/booking_confirm_screen.dart';
import 'package:petcare_app/features/booking/screens/booking_datetime_screen.dart';
import 'package:petcare_app/features/booking/screens/booking_grooming_screen.dart';
import 'package:petcare_app/features/booking/screens/booking_walking_screen.dart';
import 'package:petcare_app/features/booking/screens/cancel_policy_screen.dart';
import 'package:petcare_app/features/booking/screens/order_pets_screen.dart';
import 'package:petcare_app/features/booking/screens/owner_booking_detail_screen.dart';
import 'package:petcare_app/features/booking/screens/mock_payment_screen.dart';
import 'package:petcare_app/features/booking/screens/payment_processing_screen.dart';
import 'package:petcare_app/features/booking/screens/payment_result_screen.dart';
import 'package:petcare_app/features/booking/screens/proof_photos_screen.dart';
import 'package:petcare_app/features/booking/screens/live_tracking_screen.dart';
import 'package:petcare_app/features/booking/screens/review_screen.dart';
import 'package:petcare_app/features/booking/screens/sitter_no_show_screen.dart';
import 'package:petcare_app/features/booking/screens/pickup_address_screen.dart';
import 'package:petcare_app/shared/data/booking_args.dart';

final bookingRoutes = <RouteBase>[
  GoRoute(
    path: AppRoutes.bookingWalking,
    builder: (context, state) =>
        BookingWalkingScreen(args: state.extra as BookingArgs),
  ),
  GoRoute(
    path: AppRoutes.bookingBoarding,
    builder: (context, state) =>
        BookingBoardingScreen(args: state.extra as BookingArgs),
  ),
  GoRoute(
    path: AppRoutes.bookingGrooming,
    builder: (context, state) =>
        BookingGroomingScreen(args: state.extra as BookingArgs),
  ),
  GoRoute(
    path: AppRoutes.bookingPickupAddress,
    builder: (context, state) =>
        PickupAddressScreen(args: state.extra as BookingArgs),
  ),
  GoRoute(
    path: AppRoutes.bookingDateTime,
    builder: (context, state) =>
        BookingDateTimeScreen(draft: state.extra as BookingDraft),
  ),
  GoRoute(
    path: AppRoutes.bookingConfirm,
    builder: (context, state) =>
        BookingConfirmScreen(draft: state.extra as BookingDraft),
  ),
  GoRoute(
    path: AppRoutes.bookingProcessing,
    builder: (context, state) =>
        PaymentProcessingScreen(args: state.extra as PaymentResultArgs),
  ),
  GoRoute(
    path: AppRoutes.bookingMockPayment,
    builder: (context, state) =>
        MockPaymentScreen(phien: state.extra as PaymentSession),
  ),
  GoRoute(
    path: AppRoutes.bookingPaymentResult,
    builder: (context, state) =>
        PaymentResultScreen(args: state.extra as PaymentResultArgs),
  ),
  GoRoute(
    path: AppRoutes.bookingPets,
    builder: (context, state) =>
        OrderPetsScreen(args: state.extra as OrderPetsArgs),
  ),
  GoRoute(
    path: AppRoutes.bookingNoShow,
    builder: (context, state) =>
        SitterNoShowScreen(banChup: state.extra as OwnerBookingDetail),
  ),
  GoRoute(
    path: AppRoutes.bookingLiveTracking,
    builder: (context, state) =>
        LiveTrackingScreen(banChup: state.extra as OwnerBookingDetail),
  ),
  GoRoute(
    path: AppRoutes.cancelPolicy,
    builder: (context, state) => const CancelPolicyScreen(),
  ),
  GoRoute(
    path: AppRoutes.sitterCancelPolicy,
    builder: (context, state) => const SitterCancelPolicyScreen(),
  ),
  GoRoute(
    path: AppRoutes.bookingStayLog,
    builder: (context, state) =>
        BoardingStayLogScreen(banChup: state.extra as OwnerBookingDetail),
  ),
  GoRoute(
    path: AppRoutes.bookingEarlyEnd,
    builder: (context, state) =>
        BoardingEarlyEndScreen(banChup: state.extra as OwnerBookingDetail),
  ),
  GoRoute(
    path: AppRoutes.bookingProofPhotos,
    builder: (context, state) =>
        ProofPhotosScreen(banChup: state.extra as OwnerBookingDetail),
  ),
  GoRoute(
    path: AppRoutes.bookingReview,
    builder: (context, state) {
      final args = state.extra as ({DonDeDanhGia don, int sao});
      return ReviewScreen(don: args.don, saoBanDau: args.sao);
    },
  ),
  GoRoute(
    path: AppRoutes.bookingDetail,
    builder: (context, state) =>
        OwnerBookingDetailScreen(bookingId: state.extra as String),
  ),
];
