import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/router/app_router.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_radius.dart';
import 'package:petcare_app/core/theme/app_spacing.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';

// Header tab Công việc của NCC, tự co theo nội dung
class SitterHomeAppBar extends StatelessWidget {
  const SitterHomeAppBar({
    super.key,
    required this.location,
    required this.isReceiving,
    required this.hasUnreadNotifications,
    this.onReceivingChanged,
    this.khoa = false,
  });

  final String location;
  final bool isReceiving;
  final bool hasUnreadNotifications;
  final ValueChanged<bool>? onReceivingChanged;
  // Khoá khi đang onboarding
  final bool khoa;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Container(
      color: AppColors.primaryColor,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 8, 22, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  SvgPicture.asset('assets/icons/paw_white.svg', width: 24),
                  const SizedBox(width: AppSpacing.labelGap),
                  Expanded(
                    child: Text(l10n.tenUngDung, style: AppTextStyles.button),
                  ),
                  Material(
                    color: Color.alphaBlend(
                      Colors.black.withValues(alpha: 0.18),
                      AppColors.primaryColor,
                    ),
                    shape: const CircleBorder(),
                    child: IconButton(
                      onPressed: khoa
                          ? null
                          : () => context.push(
                              AppRoutes.notificationsPath(laNcc: true),
                            ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints.tightFor(
                        width: 40,
                        height: 40,
                      ),
                      style: const ButtonStyle(
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      icon: Badge(
                        isLabelVisible: hasUnreadNotifications,
                        smallSize: 8,
                        backgroundColor: AppColors.accent,
                        child: const Icon(Icons.notifications, size: 20),
                      ),
                      color: AppColors.textWhite,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.stackGap),
              Text(
                l10n.congViec,
                style: AppTextStyles.h1.copyWith(color: AppColors.textWhite),
              ),
              // Khi onboarding ẩn thanh nhận đơn, chỉ còn tiêu đề
              if (!khoa) ...[
                const SizedBox(height: AppSpacing.stackGap),
                _AvailabilityBar(
                  location: location,
                  receiving: isReceiving,
                  onChanged: onReceivingChanged,
                ),
                // Tắt nhận đơn thông báo ngay dưới thanh, không giấu nội dung
                if (!isReceiving) ...[
                  const SizedBox(height: 10),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 15,
                        color: AppColors.textWhite.withValues(alpha: 0.85),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          l10n.tatNhanDonMoTa,
                          style: AppTextStyles.captionSm.copyWith(
                            color: AppColors.textWhite.withValues(alpha: 0.85),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// Thanh bật/tắt nhận đơn
class _AvailabilityBar extends StatelessWidget {
  const _AvailabilityBar({
    required this.location,
    required this.receiving,
    this.onChanged,
  });

  final String location;
  final bool receiving;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final trangThai = receiving ? l10n.dangNhanDon : l10n.dangTamNghi;
    final mauChu = AppColors.textWhite.withValues(alpha: receiving ? 1 : 0.4);
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 9, 8, 9),
      decoration: BoxDecoration(
        color: AppColors.textWhite.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(AppRadius.radius14),
      ),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: mauChu, shape: BoxShape.circle),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              trangThai,
              style: AppTextStyles.label.copyWith(color: mauChu),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(
            height: 30,
            child: Switch(
              value: receiving,
              onChanged: onChanged,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              thumbColor: const WidgetStatePropertyAll(AppColors.primaryColor),
              trackColor: WidgetStateProperty.resolveWith(
                (states) => states.contains(WidgetState.selected)
                    ? AppColors.textWhite
                    : AppColors.textWhite.withValues(alpha: 0.3),
              ),
              trackOutlineColor: const WidgetStatePropertyAll(
                Colors.transparent,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
