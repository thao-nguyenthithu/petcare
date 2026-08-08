import 'package:flutter/material.dart';
import 'package:petcare_app/features/sitter_order/data/sitter_order_detail.dart';
import 'package:go_router/go_router.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/router/app_router.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_spacing.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';
import 'package:petcare_app/shared/utils/money_format.dart';
import 'package:petcare_app/shared/widgets/app_button.dart';
import 'package:petcare_app/shared/widgets/app_screen_header.dart';
import 'package:petcare_app/shared/widgets/app_dong_ke.dart';
import 'package:petcare_app/shared/widgets/app_card.dart';
import 'package:petcare_app/shared/widgets/app_screen.dart';

// Màn Hoàn tất dịch vụ, chờ chủ nuôi xác nhận trong 48 giờ
class SitterWaitConfirmScreen extends StatelessWidget {
  const SitterWaitConfirmScreen({super.key, required this.don});

  final SitterOrderDetail don;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AppScreen(
      backgroundColor: AppColors.surface,
      header: Column(
        children: [
          AppScreenHeader(
            title: l10n.hoanTatDichVu,
            onBack: () => context.go(AppRoutes.sitterHome),
          ),
          const AppDongKe(),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.screenPadding,
          AppSpacing.groupGap,
          AppSpacing.screenPadding,
          AppSpacing.screenEdgeGap,
        ),
        children: [
          Center(
            child: Container(
              width: 96,
              height: 96,
              decoration: const BoxDecoration(
                color: AppColors.cardMint,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_rounded,
                size: 48,
                color: AppColors.primaryColor,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.blockGap),
          Text(
            l10n.daGuiXacNhan,
            textAlign: TextAlign.center,
            style: AppTextStyles.h2,
          ),
          const SizedBox(height: AppSpacing.labelGap),
          Text(
            l10n.choXacNhanMoTa('${don.gioGiuTien}'),
            textAlign: TextAlign.center,
            style: AppTextStyles.body,
          ),
          const SizedBox(height: AppSpacing.groupGap),
          AppCard(
            nen: AppColors.cardMint,
            vien: false,
            child: Column(
              children: [
                if (don.phutThucHien case final phut?) ...[
                  _Row(
                    label: l10n.thoiGianThucHien,
                    value: l10n.nPhut('$phut'),
                  ),
                  const SizedBox(height: 10),
                ],
                _Row(
                  label: l10n.anhMinhChung,
                  value: l10n.nAnh('${don.tongAnhNhatKy}'),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: AppDongKe(mau: AppColors.neutral),
                ),
                _Row(
                  label: l10n.thucNhanDuKien,
                  value: '+${dinhDangTien(don.thucNhan)}đ',
                  highlight: true,
                ),
              ],
            ),
          ),
        ],
      ),
      bottomBar: Container(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.screenPadding,
          12,
          AppSpacing.screenPadding,
          12,
        ),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border(top: BorderSide(color: AppColors.neutralLight)),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppButton(
                text: l10n.veTabCongViec,
                onTap: () => context.go(AppRoutes.sitterHome),
              ),
              const SizedBox(height: 6),
              AppButton(
                text: l10n.xemChiTietDon,
                flat: true,
                color: AppColors.textSecondary,
                onTap: () =>
                    context.go(AppRoutes.sitterOrderDetailPath(don.bookingId)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({
    required this.label,
    required this.value,
    this.highlight = false,
  });

  final String label;
  final String value;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: highlight ? AppTextStyles.label : AppTextStyles.body,
        ),
        Text(
          value,
          style: highlight
              ? AppTextStyles.h3.copyWith(color: AppColors.primaryColor)
              : AppTextStyles.label,
        ),
      ],
    );
  }
}
