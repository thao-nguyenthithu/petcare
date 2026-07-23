import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/router/app_router.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_radius.dart';
import 'package:petcare_app/core/theme/app_spacing.dart';
import 'package:petcare_app/core/theme/app_system_ui.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';
import 'package:petcare_app/features/account/widgets/provider_switch_sheet.dart';
import 'package:petcare_app/features/auth/providers/auth_provider.dart';
import 'package:petcare_app/features/auth/providers/current_user_provider.dart';
import 'package:petcare_app/features/provider_profile/providers/provider_profile_provider.dart';
import 'package:petcare_app/shared/utils/placeholder_action.dart';
import 'package:petcare_app/shared/widgets/app_menu_card.dart';
import 'package:petcare_app/shared/widgets/app_refresh_indicator.dart';
import 'package:petcare_app/shared/widgets/button_select.dart';
import 'package:petcare_app/shared/widgets/confirm_dialog.dart';

// Màn Tài khoản
class AccountScreen extends ConsumerWidget {
  const AccountScreen({super.key});

  Future<void> _dangXuat(BuildContext context, WidgetRef ref) async {
    final l10n = context.l10n;
    // Hỏi xác nhận trước khi đăng xuất
    final xacNhan = await showConfirmDialog(
      context,
      icon: Icons.logout_rounded,
      title: l10n.dangXuat,
      message: l10n.dangXuatXacNhan,
      confirmLabel: l10n.dangXuat,
      danger: true,
    );
    if (!xacNhan) return;
    await ref.read(authProvider.notifier).logout();
    if (context.mounted) context.go(AppRoutes.login);
  }

  // Danh sách dòng menu
  List<AppMenuTile> _menuTiles(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    AppMenuTile dev(IconData icon, String label) => AppMenuTile(
      icon: icon,
      label: label,
      onTap: () => baoDangPhatTrien(context),
    );
    return [
      dev(Icons.person_outline, l10n.hoSoCuaToi),
      dev(Icons.pets_outlined, l10n.thuCungCuaToi),
      dev(Icons.account_balance_wallet_outlined, l10n.viVaThanhToan),
      AppMenuTile(
        icon: Icons.location_on_outlined,
        label: l10n.diaChiDaLuu,
        onTap: () => context.push(AppRoutes.addresses),
      ),
      dev(Icons.star_outline, l10n.danhGiaCuaToi),
      dev(Icons.receipt_long_outlined, l10n.lichSuVaChiTieu),
      dev(Icons.settings_outlined, l10n.caiDat),
      dev(Icons.help_outline, l10n.troGiupHoTro),
      AppMenuTile(
        icon: Icons.logout,
        label: l10n.dangXuat,
        danger: true,
        onTap: () => _dangXuat(context, ref),
      ),
    ];
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tenNguoiDung = ref.watch(currentUserProvider).asData?.value.fullName;

    return ColoredBox(
      color: AppColors.background,
      child: AppRefreshIndicator(
        onRefresh: () => Future.wait([
          ref.read(currentUserProvider.future),
          ref.read(providerStatusProvider.future),
        ]),
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverAppBar(
              pinned: true,
              automaticallyImplyLeading: false,
              toolbarHeight: 0,
              elevation: 0,
              backgroundColor: AppColors.primaryColor,
              systemOverlayStyle: AppSystemUi.onDarkBackground,
            ),
            SliverToBoxAdapter(child: _ProfileHeader(name: tenNguoiDung)),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.screenPadding,
                  AppSpacing.blockGap,
                  AppSpacing.screenPadding,
                  AppSpacing.screenEdgeGap,
                ),
                child: Column(
                  children: [
                    // Thẻ trên cùng đổi theo trạng thái hồ sơ NCC
                    const _ProviderEntry(),
                    const SizedBox(height: AppSpacing.stackGap),
                    Material(
                      color: AppColors.surface,
                      elevation: 2,
                      shadowColor: AppColors.shadow,
                      borderRadius: BorderRadius.circular(AppRadius.radius14),
                      clipBehavior: Clip.antiAlias,
                      child: AppMenuCard(tiles: _menuTiles(context, ref)),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Thẻ trên cùng của màn Tài khoản
class _ProviderEntry extends ConsumerWidget {
  const _ProviderEntry();

  Future<void> _moSheetChuyenCheDo(BuildContext context) async {
    final doiCheDo = await showProviderSwitchSheet(context);
    // Luồng chế độ Người cung cấp
    if (doiCheDo == true && context.mounted) baoDangPhatTrien(context);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final trangThai = ref.watch(providerStatusProvider).asData?.value;

    // Đã duyệt: chuyển chế độ Người cung cấp
    if (trangThai == 'APPROVED') {
      return ButtonSelect(
        selected: true,
        onTap: () => _moSheetChuyenCheDo(context),
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

    // Đang chờ duyệt: thẻ trạng thái
    if (trangThai == 'PENDING') {
      return ButtonSelect(
        selected: false,
        borderColor: AppColors.accent,
        onTap: () => context.push(AppRoutes.providerSubmitted),
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
      onTap: () => context.push(AppRoutes.providerIntro),
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

// Phần đuôi thẻ: badge cam tuỳ chọn, mũi tên.
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

// Header xanh
class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({this.name});

  final String? name;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final ten = (name == null || name!.isEmpty) ? l10n.taiKhoan : name!;
    final chuCaiDau = ten.characters.first.toUpperCase();
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.primaryColor,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
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
                Material(
                  color: const Color(0xFF23705A),
                  shape: const CircleBorder(),
                  child: IconButton(
                    onPressed: () => baoDangPhatTrien(context),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints.tightFor(
                      width: 40,
                      height: 40,
                    ),
                    style: const ButtonStyle(
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    icon: const Icon(Icons.settings_outlined, size: 20),
                    color: AppColors.textWhite,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                _Avatar(letter: chuCaiDau),
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
                            l10n.chuNuoiDaXacMinh,
                            style: AppTextStyles.captionSm.copyWith(
                              color: AppColors.textWhite,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.labelGap),
                      const _StatusPill(),
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

// Avatar tròn viền trắng, hiện chữ cái đầu của tên (chưa có ảnh đại diện).
class _Avatar extends StatelessWidget {
  const _Avatar({required this.letter});

  final String letter;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 64, // đường kính avatar
      height: 64,
      decoration: BoxDecoration(
        color: AppColors.cardMint,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.textWhite, width: 3),
      ),
      alignment: Alignment.center,
      child: Text(
        letter,
        style: AppTextStyles.h2.copyWith(color: AppColors.primaryColor),
      ),
    );
  }
}

// Pill trạng thái vai trò đang dùng.
class _StatusPill extends StatelessWidget {
  const _StatusPill();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.textWhite.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(20),
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
            context.l10n.dangOCheDoChuNuoi,
            style: AppTextStyles.captionSm.copyWith(color: AppColors.textWhite),
          ),
        ],
      ),
    );
  }
}
