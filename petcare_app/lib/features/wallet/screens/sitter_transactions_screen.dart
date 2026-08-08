import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/router/app_router.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/features/wallet/data/wallet.dart';
import 'package:petcare_app/features/wallet/data/wallet_map.dart';
import 'package:petcare_app/features/wallet/providers/wallet_provider.dart';
import 'package:petcare_app/features/wallet/widgets/transaction_card.dart';
import 'package:petcare_app/shared/utils/money_format.dart';
import 'package:petcare_app/shared/widgets/app_empty_state.dart';
import 'package:petcare_app/shared/widgets/app_refresh_indicator.dart';
import 'package:petcare_app/shared/widgets/app_screen.dart';
import 'package:petcare_app/shared/widgets/app_network_error.dart';
import 'package:petcare_app/shared/widgets/app_screen_header.dart';
import 'package:petcare_app/shared/widgets/app_skeleton.dart';
import 'package:petcare_app/shared/widgets/transaction_month_list.dart';

class SitterTransactionsScreen extends ConsumerStatefulWidget {
  const SitterTransactionsScreen({super.key});

  @override
  ConsumerState<SitterTransactionsScreen> createState() =>
      _SitterTransactionsScreenState();
}

class _SitterTransactionsScreenState
    extends ConsumerState<SitterTransactionsScreen> {
  LoaiGiaoDich? _loai;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final nguon = lichSuViProvider(
      _loai == null ? null : maLoaiGiaoDich(_loai!),
    );
    final trang = ref.watch(nguon);
    final hienThi = [
      for (final g in trang.value?.items ?? const []) giaoDichTuApi(l10n, g),
    ]..sort((a, b) => b.thoiDiem.compareTo(a.thoiDiem));

    return AppScreen(
      header: Column(
        children: [
          AppScreenHeader(title: l10n.lichSuGiaoDich),
          TransactionFilterChips(
            loai: LoaiGiaoDich.values,
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
              onRefresh: () async => ref.invalidate(nguon),
              child: TransactionMonthList<GiaoDichVi>(
                giaoDich: hienThi,
                mocThoiGian: (g) => g.thoiDiem,
                dongTong: (muc) => l10n.vaoViRaKhoiVi(
                  dinhDangTien(
                    muc
                        .where((g) => g.laTienVao)
                        .fold(0, (t, g) => t + g.soTien),
                  ),
                  dinhDangTien(
                    muc
                        .where((g) => !g.laTienVao)
                        .fold(0, (t, g) => t + g.soTien.abs()),
                  ),
                ),
                dungThe: (g) => TransactionCard(
                  giaoDich: g,
                  onTap: () =>
                      context.push(AppRoutes.sitterTransactionPath(g.ma)),
                ),
              ),
            ),
    );
  }
}
