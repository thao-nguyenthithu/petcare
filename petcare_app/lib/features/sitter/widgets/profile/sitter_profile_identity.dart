import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';
import 'package:petcare_app/features/address/providers/khu_vuc_ngan_provider.dart';
import 'package:petcare_app/shared/data/sitter_profile.dart';
import 'package:petcare_app/shared/utils/khoang_cach.dart';
import 'package:petcare_app/shared/widgets/app_status_badge.dart';
import 'package:petcare_app/shared/widgets/user_avatar.dart';

// Avatar, tên, điểm sao, nhãn tin cậy và khu vực của NCC
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
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
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      if (coDanhGia)
                        Row(
                          mainAxisSize: MainAxisSize.min,
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
                              '(${view.totalReviews})',
                              style: AppTextStyles.captionSm,
                            ),
                          ],
                        )
                      else
                        Text(
                          l10n.chuaCoDanhGia,
                          style: AppTextStyles.captionSm.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      // Huy hiệu THÀNH TÍCH, không phải dấu xác minh (mục 9)
                      if (view.trusted)
                        AppStatusBadge(
                          label: l10n.nguoiChamTinCay,
                          background: AppColors.cardMint,
                          textColor: AppColors.primaryColor,
                          leading: const Icon(
                            Icons.verified_user_outlined,
                            size: 13,
                            color: AppColors.primaryColor,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        if (diaChi != null && diaChi.isNotEmpty) ...[
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 2),
                child: Icon(
                  Icons.location_on_outlined,
                  size: 15,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  view.distanceKm == null
                      ? diaChi
                      : '$diaChi · ${l10n.cachBan(l10n.soKm(soLeKm(view.distanceKm!)))}',
                  style: AppTextStyles.captionSm,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
