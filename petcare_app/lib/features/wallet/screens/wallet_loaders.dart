import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/features/wallet/data/wallet_map.dart';
import 'package:petcare_app/features/wallet/providers/wallet_provider.dart';
import 'package:petcare_app/features/wallet/screens/sitter_dispute_screen.dart';
import 'package:petcare_app/features/wallet/screens/sitter_transaction_detail_screen.dart';
import 'package:petcare_app/shared/widgets/app_network_error.dart';
import 'package:petcare_app/shared/widgets/app_screen.dart';
import 'package:petcare_app/shared/widgets/app_screen_header.dart';
import 'package:petcare_app/shared/widgets/app_skeleton.dart';

// Lớp bọc tải theo mã, để mở màn chi tiết bằng đường dẫn
class TaiChiTietGiaoDich extends ConsumerWidget {
  const TaiChiTietGiaoDich({super.key, required this.ma});

  final String ma;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final trangThai = ref.watch(chiTietGiaoDichViProvider(ma));
    return trangThai.when(
      loading: () => _DangTai(tieuDe: l10n.chiTietGiaoDich),
      error: (_, _) => _Loi(
        tieuDe: l10n.chiTietGiaoDich,
        onRetry: () => ref.invalidate(chiTietGiaoDichViProvider(ma)),
      ),
      data: (api) => SitterTransactionDetailScreen(
        chiTiet: chiTietGiaoDichTuApi(l10n, api),
      ),
    );
  }
}

class TaiHoSoKhieuNai extends ConsumerWidget {
  const TaiHoSoKhieuNai({super.key, required this.ma});

  final String ma;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final trangThai = ref.watch(hoSoKhieuNaiProvider(ma));
    return trangThai.when(
      loading: () => _DangTai(tieuDe: l10n.hoSoKhieuNai),
      error: (_, _) => _Loi(
        tieuDe: l10n.hoSoKhieuNai,
        onRetry: () => ref.invalidate(hoSoKhieuNaiProvider(ma)),
      ),
      data: (api) => SitterDisputeScreen(hoSo: khieuNaiTuApi(l10n, api)),
    );
  }
}

class _DangTai extends StatelessWidget {
  const _DangTai({required this.tieuDe});

  final String tieuDe;

  @override
  Widget build(BuildContext context) => AppScreen(
    header: AppScreenHeader(title: tieuDe),
    body: const AppSkeletonList(soThe: 4, caoThe: 88),
  );
}

class _Loi extends StatelessWidget {
  const _Loi({required this.tieuDe, required this.onRetry});

  final String tieuDe;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => AppScreen(
    header: AppScreenHeader(title: tieuDe),
    body: AppNetworkError(onRetry: onRetry),
  );
}
