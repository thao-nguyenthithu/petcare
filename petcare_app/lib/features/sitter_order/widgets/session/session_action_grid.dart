import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/router/app_router.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_radius.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';
import 'package:petcare_app/features/messaging/mo_chat_cua_don.dart';

// Ô sự cố tô đỏ để lúc hoảng còn tìm ra ngay
class SessionActionGrid extends StatelessWidget {
  const SessionActionGrid({
    super.key,
    required this.bookingId,
    this.nhanGiua,
    this.onGiua,
  });

  final String bookingId;

  final String? nhanGiua;
  final VoidCallback? onGiua;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Row(
      children: [
        Expanded(
          child: _O(
            icon: Icons.chat_bubble_outline_rounded,
            nhan: l10n.nhanTin,
            onTap: () => moChatCuaDon(context, bookingId, laChuNuoi: false),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _O(
            icon: Icons.photo_camera_outlined,
            nhan: nhanGiua ?? l10n.guiAnh,
            onTap:
                onGiua ??
                () => context.push(AppRoutes.sitterEvidencePath(bookingId)),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _O(
            icon: Icons.warning_amber_rounded,
            nhan: l10n.suCo,
            canhBao: true,
            onTap: () => context.push(AppRoutes.sitterIncidentPath(bookingId)),
          ),
        ),
      ],
    );
  }
}

class _O extends StatelessWidget {
  const _O({
    required this.icon,
    required this.nhan,
    required this.onTap,
    this.canhBao = false,
  });

  final IconData icon;
  final String nhan;
  final VoidCallback onTap;
  final bool canhBao;

  @override
  Widget build(BuildContext context) {
    final mau = canhBao ? AppColors.accent : AppColors.textSecondary;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.radius14),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: canhBao
              ? AppColors.accent.withValues(alpha: 0.10)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.radius14),
          border: Border.all(
            color: canhBao ? Colors.transparent : AppColors.neutralLight,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, size: 22, color: mau),
            const SizedBox(height: 8),
            Text(nhan, style: AppTextStyles.label.copyWith(color: mau)),
          ],
        ),
      ),
    );
  }
}
