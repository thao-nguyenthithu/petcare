import 'package:go_router/go_router.dart';
import 'package:petcare_app/core/providers/app_container.dart';
import 'package:petcare_app/core/storage/token_storage.dart';
import 'package:petcare_app/features/account/account_routes.dart';
import 'package:petcare_app/features/address/address_routes.dart';
import 'package:petcare_app/features/auth/auth_routes.dart';
import 'package:petcare_app/features/auth/providers/current_user_provider.dart';
import 'package:petcare_app/features/booking/booking_routes.dart';
import 'package:petcare_app/features/dksitter/dksitter_routes.dart';
import 'package:petcare_app/features/home/home_routes.dart';
import 'package:petcare_app/features/messaging/messaging_routes.dart';
import 'package:petcare_app/features/notification/notification_routes.dart';
import 'package:petcare_app/features/owner_wallet/owner_wallet_routes.dart';
import 'package:petcare_app/features/pets/pets_routes.dart';
import 'package:petcare_app/features/reviews/reviews_routes.dart';
import 'package:petcare_app/features/search/search_routes.dart';
import 'package:petcare_app/features/service/service_routes.dart';
import 'package:petcare_app/features/sitter/sitter_routes.dart';
import 'package:petcare_app/features/sitter_order/sitter_order_routes.dart';
import 'package:petcare_app/features/wallet/wallet_routes.dart';

class AppRoutes {
  AppRoutes._();

  // Khởi động và giới thiệu
  static const String splash = '/';
  static const String language = '/language';
  static const String onboarding = '/onboarding';

  // Xác thực tài khoản
  static const String login = '/login';
  static const String register = '/register';
  static const String verifyEmail = '/verify-email';
  static const String verifySuccess = '/verify-success';
  static const String forgotPassword = '/forgot-password';
  static const String otp = '/otp';
  static const String resetPassword = '/reset-password';

  // Trang chủ và thông báo dùng chung hai vai
  static const String home = '/home';
  static const String notifications = '/notifications';

  static String notificationsPath({bool laNcc = false}) =>
      laNcc ? '$notifications?che-do=ncc' : notifications;

  // Tin nhắn
  static const String chatThread = '/messages/thread';

  // Tìm kiếm người chăm
  static const String search = '/search';
  static const String searchFilter = '/search/filter';
  static const String searchMap = '/search/map';
  static const String services = '/services';

  static String searchPath({String? dichVu, String? sapXep}) => Uri(
    path: search,
    queryParameters: {'service': ?dichVu, 'sort': ?sapXep},
  ).toString();

  // Thú cưng của chủ nuôi
  static const String myPets = '/pets';
  static const String petDetail = '/pets/detail';
  static const String addPet = '/pets/add';
  static const String addPetHealth = '/pets/add/health';
  static const String preventionDetail = '/pets/add/health/prevention';
  static const String preventionDose = '/pets/add/health/prevention/dose';

  // Địa chỉ của chủ nuôi
  static const String addresses = '/address';
  static const String addAddress = '/address/add';
  static const String locationPicker = '/address/pick-location';

  // Hồ sơ và đánh giá của chủ nuôi
  static const String ownerProfile = '/profile';
  static const String ownerProfileEdit = '/profile/edit';
  static const String ownerReviews = '/my-reviews';

  // Trợ giúp và hỗ trợ, hai vai dùng chung
  static const String helpCenter = '/help';

  // Luồng đặt lịch phía chủ nuôi
  static const String bookingWalking = '/booking/walking';
  static const String bookingBoarding = '/booking/boarding';
  static const String bookingGrooming = '/booking/grooming';
  static const String bookingPickupAddress = '/booking/pickup-address';
  static const String bookingDateTime = '/booking/date-time';
  static const String bookingConfirm = '/booking/confirm';
  static const String bookingProcessing = '/booking/processing';
  static const String bookingMockPayment = '/booking/mock-payment';
  static const String bookingPaymentResult = '/booking/payment-result';
  static const String cancelPolicy = '/booking/cancel-policy';

  // Đơn đã đặt phía chủ nuôi
  static const String bookingDetail = '/booking/detail';
  static const String bookingPets = '/booking/detail/pets';
  static const String bookingNoShow = '/booking/detail/no-show';
  static const String bookingLiveTracking = '/booking/detail/live';
  static const String bookingProofPhotos = '/booking/detail/photos';
  static const String bookingEarlyEnd = '/booking/detail/early-end';
  static const String bookingStayLog = '/booking/detail/stay-log';
  static const String bookingReview = '/booking/detail/review';
  static const String bookingDispute = '/booking/detail/dispute';
  static const String bookingDisputeDetail = '/booking/detail/dispute/:ma';

  static String bookingDisputePath(String ma) => '/booking/detail/dispute/$ma';

  // Ví và chi tiêu của chủ nuôi
  static const String ownerWallet = '/wallet';
  static const String ownerWalletHolding = '/wallet/holding';
  static const String ownerTransactions = '/wallet/transactions';
  static const String ownerSpending = '/wallet/spending';
  static const String ownerTransactionDetail = '/wallet/transaction';

  static String ownerTransactionPath(String maGiaoDich) =>
      '$ownerTransactionDetail?gd=$maGiaoDich';

  // Hồ sơ người chăm bất kỳ
  static const String sitterDetail = '/sitters/:id';
  static const String sitterAvailability = '/sitters/availability';

  // Toàn bộ đánh giá của một người chăm
  static const String sitterAllReviews = '/sitters/reviews';

  static String sitterDetailPath(String id) => '/sitters/$id';

  // Luồng đăng ký làm người chăm
  static const String sitterIntro = '/sitter-profile/intro';
  static const String sitterPersonalInfo = '/sitter-profile/personal-info';
  static const String sitterIdUpload = '/sitter-profile/id-upload';
  static const String sitterIdCapture = '/sitter-profile/id-capture';
  static const String sitterCommitment = '/sitter-profile/commitment';
  static const String sitterSubmitted = '/sitter-profile/submitted';

  // Trang chủ và dịch vụ của người chăm
  static const String sitterHome = '/sitter-home';
  static const String sitterServices = '/sitter-home/services';
  static const String sitterAddService = '/sitter-home/add-service';
  static const String sitterServiceArea = '/sitter-home/service-area';
  static const String sitterEarnings = '/sitter-home/earnings';

  // Hồ sơ, đánh giá và thư viện ảnh của người chăm
  static const String sitterProfileView = '/sitter-home/profile';
  static const String sitterProfileEdit = '/sitter-home/profile-edit';
  static const String sitterReviews = '/sitter-home/reviews';
  static const String sitterAllPhotos = '/sitter-home/all-photos';

  // Cụm ví và thu nhập của người chăm
  static const String sitterWallet = '/sitter-home/wallet';
  static const String sitterWithdraw = '/sitter-home/wallet/withdraw';
  static const String sitterWalletHolding = '/sitter-home/wallet/holding';
  static const String sitterTransactions = '/sitter-home/wallet/transactions';
  static const String sitterBankAccount = '/sitter-home/wallet/bank-account';

  // Mở theo mã giao dịch
  static const String sitterTransactionDetail =
      '/sitter-home/wallet/transaction';

  static const String sitterDispute = '/sitter-home/wallet/dispute';

  static String sitterTransactionPath(String maGiaoDich) =>
      '$sitterTransactionDetail?gd=$maGiaoDich';

  static String sitterDisputePath(String maHoSo) => '$sitterDispute?ma=$maHoSo';

  // Danh sách đơn của người chăm
  static const String sitterBookings = '/sitter-home/bookings';
  static const String sitterBookingSearch = '/sitter-home/bookings/search';
  static const String sitterCancelPolicy = '/sitter/cancel-policy';

  static String sitterBookingsPath({String? trangThai}) => Uri(
    path: sitterBookings,
    queryParameters: {'status': ?trangThai},
  ).toString();

  static const String sitterOrderDetail = '/sitter-home/orders/:id';

  static String _don(String id) => '/sitter-home/orders/$id';

  static String sitterOrderDetailPath(String id) => _don(id);

  // Cụm màn nhận thú và ghi nhận trước khi vào phiên
  static const String sitterCheckIn = '$sitterOrderDetail/check-in';
  static const String sitterCheckInCamera =
      '$sitterOrderDetail/check-in/camera';
  static const String sitterAiScan = '$sitterOrderDetail/check-in/ai-scan';

  static String sitterCheckInPath(String id) => '${_don(id)}/check-in';

  static String sitterAiScanPath(String id) => '${_don(id)}/check-in/ai-scan';

  static String sitterCheckInCameraPath(String id, {int? o, int? conLai}) =>
      Uri(
        path: '${_don(id)}/check-in/camera',
        queryParameters: {
          if (o != null) 'o': '$o',
          if (conLai != null) 'conLai': '$conLai',
        },
      ).toString();

  // Cụm màn phiên dắt đang chạy
  static const String sitterActiveService = '$sitterOrderDetail/walk';
  static const String sitterWalkReturn = '$sitterOrderDetail/walk/return';
  static const String sitterFinishWalk = '$sitterOrderDetail/walk/finish';
  static const String sitterEvidence = '$sitterOrderDetail/photos';

  static String sitterActiveServicePath(String id) => '${_don(id)}/walk';

  static String sitterWalkReturnPath(String id) => '${_don(id)}/walk/return';

  static String sitterFinishWalkPath(String id) => '${_don(id)}/walk/finish';

  static String sitterEvidencePath(String id) => '${_don(id)}/photos';

  // Cụm màn kỳ trông giữ
  static const String sitterHandoverCamera =
      '$sitterOrderDetail/handover/camera';
  static const String sitterHandover = '$sitterOrderDetail/handover';
  static const String sitterActiveBoarding = '$sitterOrderDetail/boarding';
  static const String sitterDailyUpdate = '$sitterOrderDetail/boarding/update';
  static const String sitterFinishBoarding =
      '$sitterOrderDetail/boarding/finish';

  static String sitterHandoverCameraPath(String id, String maLoai) =>
      '${_don(id)}/handover/camera?loai=$maLoai';

  static String sitterHandoverPath(String id) => '${_don(id)}/handover';

  static String sitterActiveBoardingPath(String id) => '${_don(id)}/boarding';

  static String sitterDailyUpdatePath(String id) =>
      '${_don(id)}/boarding/update';

  static String sitterFinishBoardingPath(String id) =>
      '${_don(id)}/boarding/finish';

  // Cụm màn buổi tắm và cắt tỉa
  static const String sitterGroomingStart = '$sitterOrderDetail/grooming-start';
  static const String sitterGroomingPhotos =
      '$sitterOrderDetail/grooming-start/camera';
  static const String sitterActiveGrooming = '$sitterOrderDetail/grooming';
  static const String sitterFinishGrooming =
      '$sitterOrderDetail/grooming/finish';

  static String sitterGroomingStartPath(String id) =>
      '${_don(id)}/grooming-start';

  static String sitterGroomingPhotosPath(String id) =>
      '${_don(id)}/grooming-start/camera';

  static String sitterActiveGroomingPath(String id) => '${_don(id)}/grooming';

  static String sitterFinishGroomingPath(String id) =>
      '${_don(id)}/grooming/finish';

  // Cụm màn xử lý sự cố trong phiên
  static const String sitterAbsence = '$sitterOrderDetail/absence';
  static const String sitterWaitConfirm = '$sitterOrderDetail/wait-confirm';
  static const String sitterIncident = '$sitterOrderDetail/incident';

  static String sitterAbsencePath(String id, String maLoai) =>
      '${_don(id)}/absence?tt=$maLoai';

  static String sitterWaitConfirmPath(String id) => '${_don(id)}/wait-confirm';

  static String sitterIncidentPath(String id) => '${_don(id)}/incident';
}

// Màn không cần đăng nhập
const _manCongKhai = {
  AppRoutes.splash,
  AppRoutes.language,
  AppRoutes.onboarding,
  AppRoutes.login,
  AppRoutes.register,
  AppRoutes.verifyEmail,
  AppRoutes.verifySuccess,
  AppRoutes.forgotPassword,
  AppRoutes.otp,
  AppRoutes.resetPassword,
};

// Cụm màn chỉ người chăm đã duyệt mới vào được
const _tienToManNguoiCham = '/sitter-home';

Future<String?> _guardDangNhap(_, GoRouterState state) async {
  if (_manCongKhai.contains(state.matchedLocation)) return null;
  final coToken = await TokenStorageService().hasToken();
  if (!coToken) return AppRoutes.login;
  if (!state.matchedLocation.startsWith(_tienToManNguoiCham)) return null;

  try {
    final toi = await appContainer.read(currentUserProvider.future);
    return toi.laNguoiCham ? null : AppRoutes.home;
  } catch (_) {
    return null;
  }
}

final appRouter = GoRouter(
  initialLocation: AppRoutes.splash,
  redirect: _guardDangNhap,
  routes: [
    // Chung hai vai
    ...authRoutes,
    ...homeRoutes,
    ...notificationRoutes,
    ...messagingRoutes,
    ...accountRoutes,

    // Phía chủ nuôi
    ...searchRoutes,
    ...serviceRoutes,
    ...petsRoutes,
    ...addressRoutes,
    ...bookingRoutes,
    ...reviewsRoutes,
    ...ownerWalletRoutes,

    // Phía người chăm
    ...dkSitterRoutes,
    ...sitterRoutes,
    ...sitterOrderRoutes,
    ...walletRoutes,
  ],
);
