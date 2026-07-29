import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/router/app_router.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_radius.dart';
import 'package:petcare_app/core/theme/app_spacing.dart';
import 'package:petcare_app/core/theme/app_system_ui.dart';
import 'package:petcare_app/features/account/widgets/account_profile_header.dart';
import 'package:petcare_app/features/account/widgets/role_entry_card.dart';
import 'package:petcare_app/features/auth/providers/auth_provider.dart';
import 'package:petcare_app/features/auth/providers/current_user_provider.dart';
import 'package:petcare_app/features/sitter/providers/sitter_services_provider.dart';
import 'package:petcare_app/shared/utils/placeholder_action.dart';
import 'package:petcare_app/shared/widgets/app_menu_card.dart';
import 'package:petcare_app/shared/widgets/app_refresh_indicator.dart';
import 'package:petcare_app/shared/widgets/confirm_dialog.dart';

// Tab Tài khoản của Người cung cấp
class SitterAccountScreen extends ConsumerWidget {
  const SitterAccountScreen({super.key});

  Future<void> _dangXuat(BuildContext context, WidgetRef ref) async {
    final l10n = context.l10n;
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

  // Địa điểm phục vụ đang lưu
  String? _khuVucHienTai(BuildContext context, WidgetRef ref) {
    final area = ref.watch(sitterServiceAreaProvider).value;
    final diaChi = area?.address;
    if (diaChi == null || diaChi.isEmpty) return null;
    return '$diaChi · ${context.l10n.soKm('${area!.radiusKm}')}';
  }

  List<AppMenuTile> _menuTiles(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    AppMenuTile tile(
      IconData icon,
      String label,
      VoidCallback onTap, {
      bool danger = false,
      String? subtitle,
    }) => AppMenuTile(
      icon: icon,
      label: label,
      danger: danger,
      subtitle: subtitle,
      onTap: onTap,
    );
    return [
      tile(
        Icons.person_outline,
        l10n.trangCaNhan,
        () => context.push(AppRoutes.sitterProfileView),
      ),
      tile(
        Icons.storefront_outlined,
        l10n.dichVuCuaToi,
        () => context.push(AppRoutes.sitterServices),
        subtitle: _khuVucHienTai(context, ref),
      ),
      tile(
        Icons.account_balance_wallet_outlined,
        l10n.viVaThuNhap,
        () => context.push(AppRoutes.sitterEarnings),
      ),
      tile(
        Icons.star_outline,
        l10n.danhGiaTuKhach,
        () => context.push(AppRoutes.sitterReviews),
      ),
      tile(
        Icons.receipt_long_outlined,
        l10n.lichSuDon,
        () => context.push(AppRoutes.sitterBookings),
      ),
      tile(
        Icons.settings_outlined,
        l10n.caiDat,
        () => baoDangPhatTrien(context),
      ),
      tile(
        Icons.help_outline,
        l10n.troGiupHoTro,
        () => baoDangPhatTrien(context),
      ),
      tile(
        Icons.logout,
        l10n.dangXuat,
        () => _dangXuat(context, ref),
        danger: true,
      ),
    ];
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final tenNguoiDung = ref.watch(currentUserProvider).asData?.value.fullName;

    return ColoredBox(
      color: AppColors.background,
      child: AppRefreshIndicator(
        onRefresh: () => ref.read(currentUserProvider.future),
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
            SliverToBoxAdapter(
              child: AccountProfileHeader(
                name: tenNguoiDung,
                roleLabel: l10n.nguoiCungCapDaXacMinh,
                statusText: l10n.dangOCheDoNguoiCungCap,
              ),
            ),
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
                    // Thẻ quay lại chế độ Chủ nuôi
                    const RoleEntryCard(providerMode: true),
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
