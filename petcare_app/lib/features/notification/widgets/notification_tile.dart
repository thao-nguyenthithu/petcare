import 'package:flutter/material.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_radius.dart';
import 'package:petcare_app/core/theme/app_spacing.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';
import 'package:petcare_app/features/notification/data/mock_notification_data.dart';
import 'package:petcare_app/shared/utils/placeholder_action.dart';
import 'package:petcare_app/shared/utils/relative_time.dart';

// Một dòng thông báo
class NotificationTile extends StatelessWidget {
  const NotificationTile({
    super.key,
    required this.notification,
    this.daDocGhiDe,
  });

  static const double _canhIcon = 40;

  final MockNotification notification;

  final bool? daDocGhiDe;

  @override
  Widget build(BuildContext context) {
    final chuaDoc = !(daDocGhiDe ?? notification.daDoc);
    final canXuLy = notification.canXuLy;
    return Material(
      color: _mauNen(chuaDoc, canXuLy),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.radius14),
      ),
      child: InkWell(
        onTap: () => baoDangPhatTrien(context),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.cardPadding),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: _canhIcon,
                height: _canhIcon,
                decoration: BoxDecoration(
                  color: canXuLy
                      ? AppColors.accent.withValues(alpha: 0.16)
                      : AppColors.surface,
                  shape: BoxShape.circle,
                ),
                child: Icon(_icon, size: 20, color: _mauIcon(canXuLy)),
              ),
              const SizedBox(width: AppSpacing.itemGap),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(notification.title, style: AppTextStyles.label),
                    const SizedBox(height: AppSpacing.textGap),
                    Text(notification.message, style: AppTextStyles.captionSm),
                    const SizedBox(height: AppSpacing.labelGap),
                    Text(
                      thoiGianTuongDoi(context.l10n, notification.minutesAgo),
                      style: AppTextStyles.captionSm,
                    ),
                  ],
                ),
              ),
              if (canXuLy) ...[
                const SizedBox(width: AppSpacing.labelGap),
                const Icon(Icons.chevron_right, color: AppColors.accent),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // Cần hành động thì nền cam nhạt, chưa đọc thì nền mint, còn lại nền trắng
  Color _mauNen(bool chuaDoc, bool canXuLy) {
    if (canXuLy) return AppColors.accent.withValues(alpha: 0.08);
    return chuaDoc ? AppColors.cardMint : AppColors.surface;
  }

  Color _mauIcon(bool canXuLy) {
    if (canXuLy) return AppColors.accent;
    if (notification.loai == LoaiThongBao.donHuy) {
      return AppColors.textSecondary;
    }
    return AppColors.primaryColor;
  }

  IconData get _icon => switch (notification.loai) {
    LoaiThongBao.donHang => Icons.check_circle_outline_rounded,
    LoaiThongBao.donHuy => Icons.cancel_outlined,
    LoaiThongBao.donMoi => Icons.assignment_outlined,
    LoaiThongBao.bangChung => Icons.photo_camera_outlined,
    LoaiThongBao.canXacNhan => Icons.error_outline_rounded,
    LoaiThongBao.nhacLich => Icons.access_time_rounded,
    LoaiThongBao.hoSo => Icons.verified_user_outlined,
    LoaiThongBao.danhGia => Icons.star_rounded,
    LoaiThongBao.tinNhan => Icons.chat_bubble_outline_rounded,
    LoaiThongBao.noiDung => Icons.lightbulb_outline_rounded,
  };
}
