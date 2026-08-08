import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_spacing.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';

class MapTopBar extends StatelessWidget {
  const MapTopBar({
    super.key,
    required this.moTa,
    required this.moPanel,
    required this.onDoiPanel,
  });

  final String moTa;
  final bool moPanel;
  final VoidCallback onDoiPanel;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenPadding,
        AppSpacing.labelGap,
        AppSpacing.screenPadding,
        0,
      ),
      child: Row(
        children: [
          Material(
            color: AppColors.surface,
            elevation: 2,
            shadowColor: AppColors.shadow,
            shape: const CircleBorder(),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: () => context.pop(),
              child: const Padding(
                padding: EdgeInsets.all(AppSpacing.itemGap),
                child: Icon(Icons.arrow_back, size: 20),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.itemGap),
          Expanded(
            child: Material(
              color: AppColors.surface,
              elevation: 2,
              shadowColor: AppColors.shadow,
              shape: const StadiumBorder(),
              child: InkWell(
                customBorder: const StadiumBorder(),
                onTap: onDoiPanel,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.cardPadding,
                    vertical: 14,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          moTa,
                          style: AppTextStyles.label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Icon(
                        moPanel
                            ? Icons.keyboard_arrow_up_rounded
                            : Icons.keyboard_arrow_down_rounded,
                        color: AppColors.textSecondary,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class MapSearchAreaButton extends StatelessWidget {
  const MapSearchAreaButton({
    super.key,
    required this.onTap,
    this.dangTai = false,
  });

  final VoidCallback? onTap;
  final bool dangTai;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.primaryColor,
      elevation: 3,
      shadowColor: AppColors.shadow,
      shape: const StadiumBorder(),
      child: InkWell(
        customBorder: const StadiumBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.cardPadding,
            vertical: AppSpacing.labelGap,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (dangTai)
                const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.textWhite,
                  ),
                )
              else
                const Icon(
                  Icons.search_rounded,
                  size: 18,
                  color: AppColors.textWhite,
                ),
              const SizedBox(width: AppSpacing.labelGap),
              Text(
                context.l10n.timTrongVungNay,
                style: AppTextStyles.label.copyWith(color: AppColors.textWhite),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MapLocateButton extends StatelessWidget {
  const MapLocateButton({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      elevation: 3,
      shadowColor: AppColors.shadow,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: const Padding(
          padding: EdgeInsets.all(AppSpacing.itemGap),
          child: Icon(
            Icons.my_location_rounded,
            size: 22,
            color: AppColors.primaryColor,
          ),
        ),
      ),
    );
  }
}
