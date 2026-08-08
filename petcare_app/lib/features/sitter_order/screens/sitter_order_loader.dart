import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petcare_app/core/config/cau_hinh_nghiep_vu_provider.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/features/sitter_order/data/sitter_order_api.dart';
import 'package:petcare_app/features/sitter_order/data/sitter_order_detail.dart';
import 'package:petcare_app/features/sitter_order/data/sitter_order_map.dart';
import 'package:petcare_app/features/sitter_order/providers/sitter_orders_provider.dart';
import 'package:petcare_app/shared/widgets/app_network_error.dart';
import 'package:petcare_app/shared/widgets/app_screen.dart';
import 'package:petcare_app/shared/widgets/app_screen_header.dart';
import 'package:petcare_app/shared/widgets/app_skeleton.dart';

// Giao cho builder cả bản thô lẫn bản đã dựng chữ
class TaiDonNcc extends ConsumerWidget {
  const TaiDonNcc({
    super.key,
    required this.bookingId,
    required this.builder,
    this.tieuDeKhiCho,
  });

  final String bookingId;
  final Widget Function(
    BuildContext context,
    SitterOrderDetail don,
    ChiTietDonNccApi api,
  )
  builder;

  // Tiêu đề khung chờ và khung lỗi, bỏ trống thì dùng chữ chung
  final String? tieuDeKhiCho;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final tieuDe = tieuDeKhiCho ?? l10n.chiTietDon;
    final trangThai = ref.watch(chiTietDonNccProvider(bookingId));
    return trangThai.when(
      loading: () => AppScreen(
        header: AppScreenHeader(title: tieuDe),
        body: const AppSkeletonList(soThe: 4, caoThe: 96),
      ),
      error: (_, _) => AppScreen(
        header: AppScreenHeader(title: tieuDe),
        body: AppNetworkError(
          onRetry: () => ref.invalidate(chiTietDonNccProvider(bookingId)),
        ),
      ),
      data: (api) => builder(
        context,
        donNccTuApi(context, api, ref.watch(cauHinhNghiepVuProvider)),
        api,
      ),
    );
  }
}
