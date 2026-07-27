import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/router/app_router.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_spacing.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';
import 'package:petcare_app/features/account/widgets/sitter_switch_sheet.dart';
import 'package:petcare_app/features/sitter_profile/providers/sitter_profile_provider.dart';
import 'package:petcare_app/shared/widgets/app_menu_card.dart';
import 'package:petcare_app/shared/widgets/button_select.dart';

// Thẻ chuyển vai trò ở đầu tab Tài khoản
class RoleEntryCard extends ConsumerWidget {
  const RoleEntryCard({super.key, this.providerMode = false});

  final bool providerMode;

  //sheet xác nhận rồi sang Home người cung cấp
  Future<void> _moSheetSangNCC(BuildContext context) async {
    final doiCheDo = await showSitterSwitchSheet(context);
    if (doiCheDo == true && context.mounted) {
      context.go(AppRoutes.sitterHome);
    }
  }

  //sheet xác nhận rồi về Home chủ nuôi
  Future<void> _moSheetVeChuNuoi(BuildContext context) async {
    final doiCheDo = await showOwnerSwitchSheet(context);
    if (doiCheDo == true && context.mounted) {
      context.go(AppRoutes.home);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;

    // NCC
    if (providerMode) {
      return ButtonSelect(
        selected: true,
        onTap: () => _moSheetVeChuNuoi(context),
        title: l10n.chuyenSangCheDoChuNuoi,
        titleColor: AppColors.primaryColor,
        titleMaxLines: 2,
        subtitle: l10n.moTaCheDoChuNuoi,
        leading: const AppIconChip(
          icon: Icons.swap_horiz_rounded,
          size: 40,
          iconSize: 22,
          background: AppColors.surface,
        ),
        trailing: const Icon(
          Icons.chevron_right,
          color: AppColors.textSecondary,
        ),
      );
    }

    final trangThai = ref.watch(sitterStatusProvider).asData?.value;

    // Đã duyệt chuyển chế độ Người cung cấp
    if (trangThai == 'APPROVED') {
      return ButtonSelect(
        selected: true,
        onTap: () => _moSheetSangNCC(context),
        title: l10n.chuyenSangCheDoNguoiCungCap,
        titleColor: AppColors.primaryColor,
        titleMaxLines: 2,
        subtitle: l10n.xemDonCanXacNhanLichLamViec,
        leading: const AppIconChip(
          icon: Icons.swap_horiz_rounded,
          size: 40,
          iconSize: 22,
          background: AppColors.surface,
        ),
        trailing: _TrailingBadge(text: l10n.soDonMoi('2')),
      );
    }

    // Đang chờ duyệt thẻ trạng thái
    if (trangThai == 'PENDING') {
      return ButtonSelect(
        selected: false,
        borderColor: AppColors.accent,
        onTap: () => context.push(AppRoutes.sitterSubmitted),
        title: l10n.hoSoDangDuyet,
        titleMaxLines: 2,
        subtitle: l10n.hoSoDangDuyetMoTa,
        leading: AppIconChip(
          icon: Icons.hourglass_top_rounded,
          size: 40,
          iconSize: 22,
          background: AppColors.accent.withValues(alpha: 0.12),
          iconColor: AppColors.accent,
        ),
        trailing: const _TrailingBadge(),
      );
    }

    // Chưa đăng ký mời trở thành Người cung cấp
    return ButtonSelect(
      selected: true,
      onTap: () => context.push(AppRoutes.sitterIntro),
      title: l10n.troThanhNguoiCungCap,
      titleColor: AppColors.primaryColor,
      titleMaxLines: 2,
      subtitle: l10n.xacMinhDeNhanDon,
      leading: const AppIconChip(
        icon: Icons.storefront_outlined,
        size: 40,
        iconSize: 22,
        background: AppColors.surface,
      ),
      trailing: _TrailingBadge(text: l10n.kiemThem),
    );
  }
}

// Phần đuôi thẻ badge cam tuỳ chọn, mũi tên.
class _TrailingBadge extends StatelessWidget {
  const _TrailingBadge({this.text});

  final String? text;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (text != null) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: AppColors.accent,
              borderRadius: BorderRadius.circular(9),
            ),
            child: Text(
              text!,
              style: AppTextStyles.captionSm.copyWith(
                color: AppColors.textWhite,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.textGap),
        ],
        const Icon(Icons.chevron_right, color: AppColors.textSecondary),
      ],
    );
  }
}
