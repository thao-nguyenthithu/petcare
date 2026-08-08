import 'package:flutter/material.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_radius.dart';
import 'package:petcare_app/core/theme/app_spacing.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';
import 'package:petcare_app/features/notification/data/thong_bao.dart';
import 'package:petcare_app/features/notification/data/thong_bao_i18n.dart';
import 'package:petcare_app/shared/utils/relative_time.dart';

// Một dòng thông báo
class NotificationTile extends StatelessWidget {
  const NotificationTile({
    super.key,
    required this.notification,
    this.hienVai = false,
    this.onTap,
  });

  static const double _canhIcon = 40;

  final ThongBao notification;
  final bool hienVai;

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final chuaDoc = !notification.daDoc;
    final canXuLy = notification.canXuLy;
    final thoiGian = thoiGianTuongDoi(l10n, notification.soPhutTruoc);
    return Material(
      color: _mauNen(chuaDoc, canXuLy),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.radius14),
      ),
      child: InkWell(
        onTap: onTap,
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
                    if (hienVai) ...[
                      Row(
                        children: [
                          _NhanVai(vai: notification.vai),
                          const Spacer(),
                          Text(thoiGian, style: AppTextStyles.captionSm),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.textGap),
                    ],
                    Text(
                      tieuDeThongBao(l10n, notification),
                      style: AppTextStyles.label,
                    ),
                    const SizedBox(height: AppSpacing.textGap),
                    Text(
                      noiDungThongBao(l10n, notification),
                      style: AppTextStyles.captionSm,
                    ),
                    if (!hienVai) ...[
                      const SizedBox(height: AppSpacing.labelGap),
                      Text(thoiGian, style: AppTextStyles.captionSm),
                    ],
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

  Color _mauNen(bool chuaDoc, bool canXuLy) {
    if (canXuLy) return AppColors.accent.withValues(alpha: 0.08);
    return chuaDoc ? AppColors.cardMint : AppColors.surface;
  }

  Color _mauIcon(bool canXuLy) {
    if (canXuLy) return AppColors.accent;
    return switch (notification.loai) {
      LoaiThongBao.donHuy || LoaiThongBao.nhacLich => AppColors.textSecondary,
      LoaiThongBao.danhGia ||
      LoaiThongBao.phongBenh ||
      LoaiThongBao.khieuNai => AppColors.accent,
      _ => AppColors.primaryColor,
    };
  }

  IconData get _icon => switch (notification.loai) {
    LoaiThongBao.donHang => Icons.check_circle_outline_rounded,
    LoaiThongBao.donHuy => Icons.cancel_outlined,
    LoaiThongBao.donMoi => Icons.assignment_outlined,
    LoaiThongBao.bangChung => Icons.photo_camera_outlined,
    LoaiThongBao.nhacLich => Icons.access_time_rounded,
    LoaiThongBao.hoSo => Icons.verified_user_outlined,
    LoaiThongBao.danhGia => Icons.star_rounded,
    LoaiThongBao.tinNhan => Icons.chat_bubble_outline_rounded,
    LoaiThongBao.noiDung => Icons.lightbulb_outline_rounded,
    LoaiThongBao.tienVi => Icons.account_balance_wallet_outlined,
    LoaiThongBao.phongBenh => Icons.vaccines_outlined,
    LoaiThongBao.khieuNai => Icons.gavel_rounded,
  };
}

class _NhanVai extends StatelessWidget {
  const _NhanVai({required this.vai});

  final VaiNhan vai;

  @override
  Widget build(BuildContext context) {
    final laNcc = vai == VaiNhan.nguoiCham;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.textGap,
        vertical: 2,
      ),
      decoration: ShapeDecoration(
        color: laNcc
            ? AppColors.primaryColor.withValues(alpha: 0.14)
            : AppColors.neutralLight,
        shape: const StadiumBorder(),
      ),
      child: Text(
        laNcc ? context.l10n.nguoiCham : context.l10n.chuNuoi,
        style: AppTextStyles.labelSm.copyWith(
          color: laNcc ? AppColors.primaryColor : AppColors.textSecondary,
        ),
      ),
    );
  }
}
