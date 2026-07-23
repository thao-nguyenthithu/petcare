import 'package:flutter/material.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';
import 'package:petcare_app/features/provider_home/data/mock_provider_home.dart';
import 'package:petcare_app/shared/widgets/pet_avatar.dart';
import 'package:petcare_app/features/provider_home/widgets/section_empty.dart';
import 'package:petcare_app/shared/utils/placeholder_action.dart';
import 'package:petcare_app/shared/widgets/app_status_badge.dart';

// Lịch hôm nay các đơn đã xác nhận, phân theo trạng thái trong ngày.
class TodayScheduleSection extends StatelessWidget {
  const TodayScheduleSection({super.key, required this.items});

  final List<MockScheduleItem> items;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.lichHomNay, style: AppTextStyles.h3),
        const SizedBox(height: 8),
        if (items.isEmpty)
          SectionEmpty(icon: Icons.event_busy, message: l10n.chuaCoLichHomNay)
        else
          for (final item in items) ...[
            _ScheduleRow(item: item),
            if (item != items.last)
              const Divider(
                height: 1,
                thickness: 1,
                color: AppColors.neutralLight,
              ),
          ],
      ],
    );
  }
}

class _ScheduleRow extends StatelessWidget {
  const _ScheduleRow({required this.item});

  final MockScheduleItem item;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final (label, bg, txt) = switch (item.status) {
      ScheduleStatus.daXong => (
        l10n.daXong,
        AppColors.neutralLight,
        AppColors.textSecondary,
      ),
      ScheduleStatus.dangDienRa => (
        l10n.dangDienRa,
        AppColors.primaryColor.withValues(alpha: 0.12),
        AppColors.primaryColor,
      ),
      ScheduleStatus.sapToi => (
        l10n.sapToi,
        AppColors.accent.withValues(alpha: 0.12),
        AppColors.accent,
      ),
    };
    return InkWell(
      onTap: () => baoDangPhatTrien(context),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            SizedBox(
              width: 48,
              child: Text(
                item.time,
                style: AppTextStyles.label.copyWith(
                  fontSize: 15,
                  color: AppColors.primaryColor,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                softWrap: false,
              ),
            ),
            const SizedBox(width: 12),
            PetAvatar(imageUrl: item.petAvatar, size: 38),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.serviceInfo,
                    style: AppTextStyles.label.copyWith(fontSize: 13),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    item.ownerInfo,
                    style: AppTextStyles.captionSm.copyWith(fontSize: 11),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            AppStatusBadge(label: label, background: bg, textColor: txt),
          ],
        ),
      ),
    );
  }
}
