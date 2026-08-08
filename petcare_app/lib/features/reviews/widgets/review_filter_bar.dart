import 'package:flutter/material.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_radius.dart';
import 'package:petcare_app/core/theme/app_spacing.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';
import 'package:petcare_app/features/reviews/data/review_filter.dart';
import 'package:petcare_app/shared/data/service_catalog.dart';
import 'package:petcare_app/shared/data/sitter_review.dart';
import 'package:petcare_app/shared/widgets/app_dong_ke.dart';

enum PanelLoc { khong, sao, dichVu }

// Hàng chip lọc đánh giá: Tất cả, Có ảnh, Sao, Dịch vụ
class ReviewFilterBar extends StatelessWidget {
  const ReviewFilterBar({
    super.key,
    required this.boLoc,
    required this.panel,
    required this.onDoiBoLoc,
    required this.onDoiPanel,
  });

  final BoLocDanhGia boLoc;
  final PanelLoc panel;
  final ValueChanged<BoLocDanhGia> onDoiBoLoc;
  final ValueChanged<PanelLoc> onDoiPanel;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
      child: Row(
        children: [
          _Chip(
            nhan: l10n.tatCa,
            dangChon: !boLoc.dangLoc,
            onTap: () {
              onDoiPanel(PanelLoc.khong);
              onDoiBoLoc(const BoLocDanhGia());
            },
          ),
          const SizedBox(width: AppSpacing.labelGap),
          _Chip(
            nhan: l10n.coAnh,
            dangChon: boLoc.coAnh,
            onTap: () {
              onDoiPanel(PanelLoc.khong);
              onDoiBoLoc(boLoc.copyWith(coAnh: !boLoc.coAnh));
            },
          ),
          const SizedBox(width: AppSpacing.labelGap),
          _Chip(
            nhan: l10n.sao,
            dangChon: boLoc.sao != null,
            coBang: true,
            dangMo: panel == PanelLoc.sao,
            icon: const Icon(
              Icons.star_rounded,
              size: 12,
              color: AppColors.accent,
            ),
            onTap: () => onDoiPanel(
              panel == PanelLoc.sao ? PanelLoc.khong : PanelLoc.sao,
            ),
          ),
          const SizedBox(width: AppSpacing.labelGap),
          _Chip(
            nhan: l10n.dichVu,
            dangChon: boLoc.dichVu != null,
            coBang: true,
            dangMo: panel == PanelLoc.dichVu,
            onTap: () => onDoiPanel(
              panel == PanelLoc.dichVu ? PanelLoc.khong : PanelLoc.dichVu,
            ),
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.nhan,
    required this.dangChon,
    required this.onTap,
    this.coBang = false,
    this.dangMo = false,
    this.icon,
  });

  final String nhan;
  final bool dangChon;
  final bool coBang;
  final bool dangMo;
  final Widget? icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final vien = dangMo || (dangChon && coBang);
    final toDac = dangChon && !coBang;
    final nen = toDac ? AppColors.primaryColor : AppColors.surface;
    final chu = toDac
        ? AppColors.textWhite
        : (vien ? AppColors.primaryColor : AppColors.textPrimary);

    return Material(
      color: nen,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.screenPadding,
            vertical: AppSpacing.labelGap,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: vien ? AppColors.primaryColor : AppColors.neutralLight,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(nhan, style: AppTextStyles.label.copyWith(color: chu)),
              if (icon case final i?) ...[
                const SizedBox(width: AppSpacing.textGap),
                i,
              ],
              if (coBang) ...[
                const SizedBox(width: AppSpacing.textGap),
                Icon(
                  dangMo
                      ? Icons.keyboard_arrow_up_rounded
                      : Icons.keyboard_arrow_down_rounded,
                  size: 18,
                  color: chu,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class ReviewFilterPanel extends StatelessWidget {
  const ReviewFilterPanel({
    super.key,
    required this.panel,
    required this.boLoc,
    required this.thongKe,
    required this.onChon,
  });

  final PanelLoc panel;
  final BoLocDanhGia boLoc;
  final ThongKeDanhGia thongKe;
  final ValueChanged<BoLocDanhGia> onChon;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final dong = switch (panel) {
      PanelLoc.sao => <_Dong>[
        _Dong(
          nhan: l10n.tatCaSao,
          so: thongKe.tongSo,
          dangChon: boLoc.sao == null,
          chon: boLoc.copyWith(xoaSao: true),
        ),
        for (var sao = 5; sao >= 1; sao--)
          _Dong(
            nhan: l10n.nSao('$sao'),
            so: thongKe.phanBoSao[sao] ?? 0,
            dangChon: boLoc.sao == sao,
            chon: boLoc.copyWith(sao: sao),
          ),
      ],
      PanelLoc.dichVu => <_Dong>[
        _Dong(
          nhan: l10n.tatCaDichVu,
          so: thongKe.tongSo,
          dangChon: boLoc.dichVu == null,
          chon: boLoc.copyWith(xoaDichVu: true),
        ),
        for (final dv in LoaiDichVu.values)
          _Dong(
            nhan: dv.ten(l10n),
            so: thongKe.phanBoDichVu[dv] ?? 0,
            dangChon: boLoc.dichVu == dv,
            chon: boLoc.copyWith(dichVu: dv),
          ),
      ],
      PanelLoc.khong => const <_Dong>[],
    };

    return Material(
      color: AppColors.surface,
      borderRadius: const BorderRadius.vertical(
        bottom: Radius.circular(AppRadius.radius14),
      ),
      clipBehavior: Clip.antiAlias,
      elevation: 3,
      shadowColor: AppColors.shadow,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final (i, d) in dong.indexed) ...[
            if (i > 1) const AppDongKe(thut: AppSpacing.screenPadding),
            _HangChon(dong: d, onChon: onChon),
          ],
        ],
      ),
    );
  }
}

class _Dong {
  const _Dong({
    required this.nhan,
    required this.so,
    required this.dangChon,
    required this.chon,
  });

  final String nhan;
  final int so;
  final bool dangChon;
  final BoLocDanhGia chon;
}

class _HangChon extends StatelessWidget {
  const _HangChon({required this.dong, required this.onChon});

  final _Dong dong;
  final ValueChanged<BoLocDanhGia> onChon;

  @override
  Widget build(BuildContext context) {
    final mau = dong.dangChon ? AppColors.primaryColor : AppColors.textPrimary;
    return InkWell(
      onTap: () => onChon(dong.chon),
      child: Container(
        color: dong.dangChon ? AppColors.cardMint : null,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.screenPadding,
          vertical: AppSpacing.stackGap,
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                dong.nhan,
                style: AppTextStyles.label.copyWith(color: mau),
              ),
            ),
            Text(
              '${dong.so}',
              style: AppTextStyles.captionSm.copyWith(
                color: dong.dangChon ? mau : AppColors.textSecondary,
              ),
            ),
            if (dong.dangChon) ...[
              const SizedBox(width: AppSpacing.labelGap),
              Icon(Icons.check_rounded, size: 18, color: mau),
            ],
          ],
        ),
      ),
    );
  }
}
