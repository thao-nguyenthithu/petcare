import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/router/app_router.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_radius.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';

// Header tab Công việc của NCC, tự co theo nội dung
class ProviderHomeAppBar extends StatelessWidget {
  const ProviderHomeAppBar({
    super.key,
    required this.location,
    required this.isReceiving,
    required this.hasUnreadNotifications,
  });

  final String location;
  final bool isReceiving;
  final bool hasUnreadNotifications;

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
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      l10n.tenUngDung,
                      style: AppTextStyles.h3.copyWith(
                        fontSize: 16,
                        color: AppColors.textWhite,
                      ),
                    ),
                  ),
                  Material(
                    color: const Color(0xFF23705A),
                    shape: const CircleBorder(),
                    child: IconButton(
                      onPressed: () => context.push(AppRoutes.notifications),
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
              const SizedBox(height: 16),
              Text(
                l10n.congViec,
                style: AppTextStyles.h1.copyWith(
                  fontSize: 26,
                  color: AppColors.textWhite,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                l10n.sanSangNhanDon,
                style: AppTextStyles.body.copyWith(
                  fontSize: 13,
                  color: AppColors.textWhite.withValues(alpha: 0.85),
                ),
              ),
              const SizedBox(height: 16),
              _AvailabilityBar(
                location: location,
                initialReceiving: isReceiving,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Thanh bật/tắt nhận đơn
class _AvailabilityBar extends StatefulWidget {
  const _AvailabilityBar({
    required this.location,
    required this.initialReceiving,
  });

  final String location;
  final bool initialReceiving;

  @override
  State<_AvailabilityBar> createState() => _AvailabilityBarState();
}

class _AvailabilityBarState extends State<_AvailabilityBar> {
  late bool _receiving = widget.initialReceiving;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final trangThai = _receiving ? l10n.dangNhanDon : l10n.dangTamNghi;
    final mauChu = AppColors.textWhite.withValues(alpha: _receiving ? 1 : 0.4);
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
              style: AppTextStyles.label.copyWith(fontSize: 16, color: mauChu),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(
            height: 30,
            child: Switch(
              value: _receiving,
              onChanged: (v) => setState(() => _receiving = v),
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
