import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/router/app_router.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/features/owner_wallet/data/owner_payment_map.dart';
import 'package:petcare_app/features/owner_wallet/providers/owner_payments_provider.dart';
import 'package:petcare_app/features/owner_wallet/data/owner_wallet.dart';
import 'package:petcare_app/features/owner_wallet/widgets/owner_wallet_blocks.dart';
import 'package:petcare_app/shared/utils/money_format.dart';
import 'package:petcare_app/shared/widgets/app_empty_state.dart';
import 'package:petcare_app/shared/widgets/app_refresh_indicator.dart';
import 'package:petcare_app/shared/widgets/app_screen.dart';
import 'package:petcare_app/shared/widgets/app_network_error.dart';
import 'package:petcare_app/shared/widgets/app_screen_header.dart';
import 'package:petcare_app/shared/widgets/app_skeleton.dart';
import 'package:petcare_app/shared/widgets/transaction_month_list.dart';

// Màn Lịch sử giao dịch của chủ nuôi
class OwnerTransactionsScreen extends ConsumerStatefulWidget {
  const OwnerTransactionsScreen({super.key});

  @override
  ConsumerState<OwnerTransactionsScreen> createState() =>
      _OwnerTransactionsScreenState();
}

class _OwnerTransactionsScreenState
    extends ConsumerState<OwnerTransactionsScreen> {
  LoaiGiaoDichChuNuoi? _loai;

  String? get _maLoai => switch (_loai) {
    LoaiGiaoDichChuNuoi.thanhToan => 'thanhToan',
    LoaiGiaoDichChuNuoi.hoanTien => 'hoanTien',
    null => null,
  };

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final nguon = lichSuThanhToanProvider(_maLoai);
    final trang = ref.watch(nguon);
    final hienThi = [
      for (final g in trang.value ?? const []) giaoDichChuNuoiTuApi(l10n, g),
    ]..sort((a, b) => b.thoiDiem.compareTo(a.thoiDiem));

    return AppScreen(
      header: Column(
        children: [
          AppScreenHeader(title: l10n.lichSuGiaoDich),
          TransactionFilterChips(
            loai: LoaiGiaoDichChuNuoi.values,
            dangChon: _loai,
            nhan: (l) => l.nhan(l10n),
            onChon: (l) => setState(() => _loai = l),
          ),
        ],
      ),
      body: trang.hasError
          ? AppNetworkError(onRetry: () => ref.invalidate(nguon))
          : trang.isLoading && !trang.hasValue
          ? const AppSkeletonList(soThe: 6, caoThe: 72)
          : hienThi.isEmpty
          ? Center(
              child: AppEmptyState(
                icon: Icons.receipt_long_outlined,
                title: l10n.chuaCoGiaoDich,
                message: l10n.chuaCoGiaoDichLoc,
                circleColor: AppColors.cardMint,
              ),
            )
          : AppRefreshIndicator(
              child: TransactionMonthList<GiaoDichChuNuoi>(
                giaoDich: hienThi,
                mocThoiGian: (g) => g.thoiDiem,
                dongTong: (muc) => l10n.daChiDaHoan(
                  dinhDangTien(
                    muc
                        .where((g) => !g.laTienVao)
                        .fold(0, (t, g) => t + g.soTien.abs()),
                  ),
                  dinhDangTien(
                    muc
                        .where((g) => g.laTienVao)
                        .fold(0, (t, g) => t + g.soTien),
                  ),
                ),
                dungThe: (g) => OwnerTransactionCard(
                  giaoDich: g,
                  onTap: () =>
                      context.push(AppRoutes.ownerTransactionPath(g.ma)),
                ),
              ),
            ),
    );
  }
}
