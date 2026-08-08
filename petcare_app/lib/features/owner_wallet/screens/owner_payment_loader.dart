import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/features/owner_wallet/data/owner_payment_map.dart';
import 'package:petcare_app/features/owner_wallet/providers/owner_payments_provider.dart';
import 'package:petcare_app/features/owner_wallet/screens/owner_transaction_detail_screen.dart';
import 'package:petcare_app/shared/widgets/app_network_error.dart';
import 'package:petcare_app/shared/widgets/app_screen.dart';
import 'package:petcare_app/shared/widgets/app_screen_header.dart';
import 'package:petcare_app/shared/widgets/app_skeleton.dart';

// Lớp bọc tải chi tiết giao dịch chủ nuôi theo mã, mở được bằng đường dẫn
class TaiChiTietThanhToan extends ConsumerWidget {
  const TaiChiTietThanhToan({super.key, required this.ma});

  final String ma;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final trangThai = ref.watch(chiTietThanhToanProvider(ma));
    return trangThai.when(
      loading: () => AppScreen(
        header: AppScreenHeader(title: l10n.chiTietGiaoDich),
        body: const AppSkeletonList(soThe: 4, caoThe: 88),
      ),
      error: (_, _) => AppScreen(
        header: AppScreenHeader(title: l10n.chiTietGiaoDich),
        body: AppNetworkError(
          onRetry: () => ref.invalidate(chiTietThanhToanProvider(ma)),
        ),
      ),
      data: (api) => OwnerTransactionDetailScreen(
        chiTiet: chiTietThanhToanTuApi(l10n, api),
      ),
    );
  }
}
