import 'package:go_router/go_router.dart';
import 'package:petcare_app/core/router/app_router.dart';
import 'package:petcare_app/features/wallet/screens/sitter_bank_account_screen.dart';
import 'package:petcare_app/features/wallet/screens/sitter_earnings_screen.dart';
import 'package:petcare_app/features/wallet/screens/sitter_holding_screen.dart';
import 'package:petcare_app/features/wallet/screens/sitter_transactions_screen.dart';
import 'package:petcare_app/features/wallet/screens/sitter_wallet_screen.dart';
import 'package:petcare_app/features/wallet/screens/sitter_withdraw_screen.dart';
import 'package:petcare_app/features/wallet/screens/wallet_loaders.dart';

final walletRoutes = <RouteBase>[
  GoRoute(
    path: AppRoutes.sitterWallet,
    builder: (context, state) => const SitterWalletScreen(),
  ),
  GoRoute(
    path: AppRoutes.sitterEarnings,
    builder: (context, state) => const SitterEarningsScreen(),
  ),
  GoRoute(
    path: AppRoutes.sitterWithdraw,
    builder: (context, state) => const SitterWithdrawScreen(),
  ),
  GoRoute(
    path: AppRoutes.sitterWalletHolding,
    builder: (context, state) => const SitterHoldingScreen(),
  ),
  GoRoute(
    path: AppRoutes.sitterTransactions,
    builder: (context, state) => const SitterTransactionsScreen(),
  ),
  GoRoute(
    path: AppRoutes.sitterTransactionDetail,
    builder: (context, state) =>
        TaiChiTietGiaoDich(ma: state.uri.queryParameters['gd'] ?? ''),
  ),
  GoRoute(
    path: AppRoutes.sitterBankAccount,
    builder: (context, state) => const SitterBankAccountScreen(),
  ),
  GoRoute(
    path: AppRoutes.sitterDispute,
    builder: (context, state) =>
        TaiHoSoKhieuNai(ma: state.uri.queryParameters['ma'] ?? ''),
  ),
];
