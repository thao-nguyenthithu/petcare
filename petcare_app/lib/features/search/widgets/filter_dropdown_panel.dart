import 'package:flutter/material.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_radius.dart';
import 'package:petcare_app/core/theme/app_spacing.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';

class MucChonLoc<T> {
  const MucChonLoc({required this.giaTri, required this.nhan, this.dauDong});

  final T giaTri;
  final String nhan;
  final Widget? dauDong;
}

class FilterDropdownPanel<T> extends StatelessWidget {
  const FilterDropdownPanel({
    super.key,
    required this.muc,
    required this.dangChon,
    required this.onChon,
    required this.onDong,
  });

  final List<MucChonLoc<T>> muc;
  final T? dangChon;
  final ValueChanged<T?> onChon;
  final VoidCallback onDong;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Material(
          color: AppColors.surface,
          elevation: 3,
          shadowColor: AppColors.shadow,
          borderRadius: const BorderRadius.vertical(
            bottom: Radius.circular(AppRadius.radius14),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final m in muc)
                _DongChon<T>(
                  muc: m,
                  dangChon: m.giaTri == dangChon,
                  onTap: () => onChon(m.giaTri == dangChon ? null : m.giaTri),
                ),
            ],
          ),
        ),
        Expanded(
          child: GestureDetector(
            onTap: onDong,
            child: Container(color: Colors.black.withValues(alpha: 0.35)),
          ),
        ),
      ],
    );
  }
}

class _DongChon<T> extends StatelessWidget {
  const _DongChon({
    required this.muc,
    required this.dangChon,
    required this.onTap,
  });

  final MucChonLoc<T> muc;
  final bool dangChon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        color: dangChon ? AppColors.cardMint : AppColors.surface,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.screenPadding,
          vertical: AppSpacing.itemGap,
        ),
        child: Row(
          children: [
            if (muc.dauDong != null) ...[
              muc.dauDong!,
              const SizedBox(width: AppSpacing.itemGap),
            ],
            Expanded(
              child: Text(
                muc.nhan,
                style: (dangChon ? AppTextStyles.label : AppTextStyles.body)
                    .copyWith(
                      color: dangChon
                          ? AppColors.primaryColor
                          : AppColors.textPrimary,
                    ),
              ),
            ),
            if (dangChon)
              const Icon(
                Icons.check_rounded,
                size: 20,
                color: AppColors.primaryColor,
              ),
          ],
        ),
      ),
    );
  }
}

class DaySao extends StatelessWidget {
  const DaySao({super.key, required this.so});

  final int so;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 1; i <= 5; i++)
          Icon(
            Icons.star_rounded,
            size: 16,
            color: i <= so ? AppColors.honey : AppColors.neutral,
          ),
      ],
    );
  }
}
