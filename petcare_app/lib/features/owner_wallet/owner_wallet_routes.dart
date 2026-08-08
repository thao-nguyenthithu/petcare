import 'package:go_router/go_router.dart';
import 'package:petcare_app/core/router/app_router.dart';
import 'package:petcare_app/features/owner_wallet/screens/owner_holding_screen.dart';
import 'package:petcare_app/features/owner_wallet/screens/owner_spending_screen.dart';
import 'package:petcare_app/features/owner_wallet/screens/owner_transactions_screen.dart';
import 'package:petcare_app/features/owner_wallet/screens/owner_wallet_screen.dart';
import 'package:petcare_app/features/owner_wallet/screens/owner_payment_loader.dart';

final ownerWalletRoutes = <RouteBase>[
  GoRoute(
    path: AppRoutes.ownerWallet,
    builder: (context, state) => const OwnerWalletScreen(),
  ),
  GoRoute(
    path: AppRoutes.ownerWalletHolding,
    builder: (context, state) => const OwnerHoldingScreen(),
  ),
  GoRoute(
    path: AppRoutes.ownerTransactions,
    builder: (context, state) => const OwnerTransactionsScreen(),
  ),
  GoRoute(
    path: AppRoutes.ownerSpending,
    builder: (context, state) => const OwnerSpendingScreen(),
  ),
  GoRoute(
    path: AppRoutes.ownerTransactionDetail,
    builder: (context, state) =>
        TaiChiTietThanhToan(ma: state.uri.queryParameters['gd'] ?? ''),
  ),
];
