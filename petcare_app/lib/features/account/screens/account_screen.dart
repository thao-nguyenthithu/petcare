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
import 'package:petcare_app/features/dksitter/providers/dksitter_provider.dart';
import 'package:petcare_app/shared/utils/placeholder_action.dart';
import 'package:petcare_app/shared/widgets/app_menu_card.dart';
import 'package:petcare_app/shared/widgets/app_refresh_indicator.dart';
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
    AppMenuTile tile(
      IconData icon,
      String label,
      VoidCallback onTap, {
      bool danger = false,
    }) => AppMenuTile(icon: icon, label: label, danger: danger, onTap: onTap);
    return [
      tile(
        Icons.person_outline,
        l10n.hoSoCuaToi,
        () => context.push(AppRoutes.ownerProfile),
      ),
      tile(
        Icons.pets_outlined,
        l10n.thuCungCuaToi,
        () => context.push(AppRoutes.myPets),
      ),
      tile(
        Icons.receipt_long_outlined,
        l10n.thanhToan,
        () => context.push(AppRoutes.ownerWallet),
      ),
      tile(
        Icons.location_on_outlined,
        l10n.diaChiDaLuu,
        () => context.push(AppRoutes.addresses),
      ),
      tile(
        Icons.star_outline,
        l10n.danhGiaCuaToi,
        () => context.push(AppRoutes.ownerReviews),
      ),
      tile(
        Icons.receipt_long_outlined,
        l10n.lichSuVaChiTieu,
        () => context.push(AppRoutes.ownerSpending),
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
    final nguoiDung = ref.watch(currentUserProvider).asData?.value;

    return ColoredBox(
      color: AppColors.background,
      child: AppRefreshIndicator(
        onRefresh: () => Future.wait([
          ref.read(currentUserProvider.future),
          ref.read(sitterStatusProvider.future),
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
            SliverToBoxAdapter(
              child: AccountProfileHeader(
                name: nguoiDung?.fullName,
                avatarUrl: nguoiDung?.avatarUrl,
                roleLabel: context.l10n.chuNuoiDaXacMinh,
                statusText: context.l10n.dangOCheDoChuNuoi,
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
                    // Thẻ trên cùng đổi theo trạng thái hồ sơ NCC
                    const RoleEntryCard(),
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
