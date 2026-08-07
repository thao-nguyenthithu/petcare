import 'package:flutter/material.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_radius.dart';
import 'package:petcare_app/core/theme/app_spacing.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';
import 'package:petcare_app/shared/utils/money_format.dart';
import 'package:petcare_app/shared/widgets/green_title_header.dart';

final Color _nenMo = AppColors.textWhite.withValues(alpha: 0.14);
final Color _chuMo = AppColors.textWhite.withValues(alpha: 0.85);

// Header màn Tất cả đơn: tiêu đề, nút công cụ và thẻ tóm tắt
class SitterBookingsHeader extends StatelessWidget {
  const SitterBookingsHeader({
    super.key,
    required this.nhanKy,
    required this.soDon,
    required this.tongThucNhan,
    required this.dangLoc,
    required this.onBack,
    required this.onTimKiem,
    required this.onMoLoc,
    required this.onChonKy,
  });

  final String nhanKy;
  final int soDon;
  final int tongThucNhan;
  final bool dangLoc;

  final VoidCallback onBack;
  final VoidCallback onTimKiem;
  final VoidCallback onMoLoc;
  final VoidCallback onChonKy;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return GreenTitleHeader(
      title: l10n.tatCaDonNhan,
      onBack: onBack,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            onPressed: onTimKiem,
            icon: const Icon(Icons.search, color: AppColors.textWhite),
            tooltip: l10n.traCuuDon,
          ),
          IconButton(
            onPressed: onMoLoc,
            icon: _IconLoc(dangLoc: dangLoc),
            tooltip: l10n.locDon,
          ),
        ],
      ),
      bottom: Row(
        children: [
          Expanded(
            child: _TheTomTat(
              nhan: nhanKy,
              giaTri: l10n.soDon('$soDon'),
              onTap: onChonKy,
            ),
          ),
          const SizedBox(width: AppSpacing.labelGap),
          Expanded(
            child: _TheTomTat(
              nhan: l10n.thucNhanSauPhi,
              giaTri: '${dinhDangTien(tongThucNhan)}đ',
            ),
          ),
        ],
      ),
    );
  }
}

class _IconLoc extends StatelessWidget {
  const _IconLoc({required this.dangLoc});

  final bool dangLoc;

  static const double _coCham = 8;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        const Icon(Icons.tune_rounded, color: AppColors.textWhite),
        if (dangLoc)
          Positioned(
            top: -2,
            right: -2,
            child: Container(
              width: _coCham,
              height: _coCham,
              decoration: const BoxDecoration(
                color: AppColors.accent,
                shape: BoxShape.circle,
              ),
            ),
          ),
      ],
    );
  }
}

class _TheTomTat extends StatelessWidget {
  const _TheTomTat({required this.nhan, required this.giaTri, this.onTap});

  final String nhan;
  final String giaTri;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final noiDung = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Flexible(
                child: Text(
                  nhan,
                  style: AppTextStyles.captionSm.copyWith(color: _chuMo),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (onTap != null) ...[
                const SizedBox(width: AppSpacing.textGap),
                Icon(Icons.expand_more_rounded, size: 16, color: _chuMo),
              ],
            ],
          ),
          const SizedBox(height: AppSpacing.textGap),
          Text(
            giaTri,
            style: AppTextStyles.h3.copyWith(color: AppColors.textWhite),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );

    return Material(
      color: _nenMo,
      borderRadius: BorderRadius.circular(AppRadius.radius14),
      child: onTap == null
          ? noiDung
          : InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(AppRadius.radius14),
              child: noiDung,
            ),
    );
  }
}
