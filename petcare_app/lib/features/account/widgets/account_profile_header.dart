import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/l10n/locale_provider.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_radius.dart';
import 'package:petcare_app/core/theme/app_spacing.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';
import 'package:petcare_app/shared/widgets/user_avatar.dart';

// Header xanh của tab Tài khoản
class AccountProfileHeader extends StatelessWidget {
  const AccountProfileHeader({
    super.key,
    required this.roleLabel,
    required this.statusText,
    this.name,
    this.avatarUrl,
  });

  final String roleLabel;
  final String statusText;
  final String? name;
  final String? avatarUrl;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final ten = (name == null || name!.isEmpty) ? l10n.taiKhoan : name!;
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.primaryColor,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 4, 24, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.taiKhoan,
                    style: AppTextStyles.h3.copyWith(
                      color: AppColors.textWhite,
                    ),
                  ),
                ),
                const _LanguageToggle(),
              ],
            ),
            const SizedBox(height: AppSpacing.stackGap),
            Row(
              children: [
                UserAvatar(
                  name: ten,
                  imageUrl: avatarUrl,
                  size: 64,
                  bordered: true,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ten,
                        style: AppTextStyles.h3.copyWith(
                          color: AppColors.textWhite,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: AppSpacing.textGap),
                      Row(
                        children: [
                          const Icon(
                            Icons.verified_rounded,
                            size: 14,
                            color: AppColors.textWhite,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            roleLabel,
                            style: AppTextStyles.captionSm.copyWith(
                              color: AppColors.textWhite,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.labelGap),
                      _StatusPill(text: statusText),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _LanguageToggle extends ConsumerWidget {
  const _LanguageToggle();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final code = ref.watch(localeProvider).languageCode;
    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: Color.alphaBlend(
          Colors.black.withValues(alpha: 0.18),
          AppColors.primaryColor,
        ),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _seg(ref, 'VI', 'vi', code == 'vi'),
          _seg(ref, 'EN', 'en', code == 'en'),
        ],
      ),
    );
  }

  Widget _seg(WidgetRef ref, String label, String maNgonNgu, bool dangChon) {
    return GestureDetector(
      onTap: dangChon
          ? null
          : () => ref.read(localeProvider.notifier).setLocale(maNgonNgu),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
        decoration: BoxDecoration(
          color: dangChon ? AppColors.textWhite : Colors.transparent,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          label,
          style: AppTextStyles.label.copyWith(
            color: dangChon ? AppColors.primaryColor : AppColors.textWhite,
          ),
        ),
      ),
    );
  }
}

// Pill trạng thái vai trò đang dùng.
class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.textWhite.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(AppRadius.radius20),
        border: Border.all(color: AppColors.textWhite.withValues(alpha: 0.24)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: AppColors.textWhite,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: AppTextStyles.captionSm.copyWith(color: AppColors.textWhite),
          ),
        ],
      ),
    );
  }
}
