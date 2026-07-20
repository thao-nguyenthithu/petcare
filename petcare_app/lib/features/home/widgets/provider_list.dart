import 'package:flutter/material.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_radius.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';
import 'package:petcare_app/features/home/data/mock_home_data.dart';
import 'package:petcare_app/shared/utils/placeholder_action.dart';
import 'package:petcare_app/features/home/widgets/provider_card.dart';

// Danh sách ngang các card người cung cấp
class ProviderList extends StatelessWidget {
  const ProviderList({super.key, required this.providers, this.onSeeMore});

  final List<MockProviderCard> providers;
  final VoidCallback? onSeeMore;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (var i = 0; i < providers.length; i++) ...[
              if (i > 0) const SizedBox(width: 12),
              ProviderCard(
                data: providers[i],
                onTap: () => baoDangPhatTrien(context),
              ),
            ],
            if (onSeeMore != null) ...[
              const SizedBox(width: 12),
              _SeeMoreCard(onTap: onSeeMore!),
            ],
          ],
        ),
      ),
    );
  }
}

// Card cuối danh sách
class _SeeMoreCard extends StatelessWidget {
  const _SeeMoreCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 164,
      child: Material(
        color: AppColors.cardMint,
        elevation: 3,
        shadowColor: AppColors.shadow,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.radius14),
        ),
        child: InkWell(
          onTap: onTap,
          splashColor: AppColors.primaryColor.withValues(alpha: 0.12),
          highlightColor: AppColors.primaryColor.withValues(alpha: 0.06),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 48,
                height: 48,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.chevron_right,
                  color: AppColors.primaryColor,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                context.l10n.xemThem,
                style: AppTextStyles.label.copyWith(
                  color: AppColors.primaryColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
