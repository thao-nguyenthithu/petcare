import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';
import 'package:petcare_app/features/address/providers/khu_vuc_ngan_provider.dart';
import 'package:petcare_app/features/sitter/data/sitter_profile.dart';
import 'package:petcare_app/shared/widgets/user_avatar.dart';

// Avatar, tên, điểm sao và khu vực của NCC
class SitterProfileIdentity extends ConsumerWidget {
  const SitterProfileIdentity({super.key, required this.view});

  final SitterProfile view;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final area = view.serviceArea;
    final diaChi = (area != null && area.daDat)
        ? ref
              .watch(khuVucNganProvider((lat: area.lat!, lng: area.lng!)))
              .asData
              ?.value
        : null;
    final coDanhGia = view.totalReviews > 0;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        UserAvatar(
          name: view.fullName,
          imageUrl: view.avatarUrl,
          size: 64,
          bordered: true,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(view.fullName, style: AppTextStyles.h2, maxLines: 1),
              const SizedBox(height: 6),
              if (coDanhGia)
                Row(
                  children: [
                    const Icon(
                      Icons.star_rounded,
                      size: 15,
                      color: AppColors.accent,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      view.ratingAvg.toStringAsFixed(1),
                      style: AppTextStyles.label,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '(${view.totalReviews} ${l10n.luotDanhGia.toLowerCase()})',
                      style: AppTextStyles.caption,
                    ),
                  ],
                )
              else
                Text(
                  l10n.chuaCoDanhGia,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              if (diaChi != null && diaChi.isNotEmpty) ...[
                const SizedBox(height: 4),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: SvgPicture.asset(
                        'assets/icons/icon_location.svg',
                        width: 14,
                        height: 14,
                        colorFilter: const ColorFilter.mode(
                          AppColors.primaryColor,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    // Phường, tỉnh
                    Expanded(child: Text(diaChi, style: AppTextStyles.caption)),
                  ],
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
