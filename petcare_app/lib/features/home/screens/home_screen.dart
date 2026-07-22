import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/router/app_router.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';
import 'package:petcare_app/features/auth/providers/auth_provider.dart';
import 'package:petcare_app/features/home/data/mock_home_data.dart';
import 'package:petcare_app/features/home/screens/owner_home_tab.dart';
import 'package:petcare_app/features/home/widgets/active_order_bar.dart';
import 'package:petcare_app/shared/widgets/app_button.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _tabIndex = 0;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      body: switch (_tabIndex) {
        0 => const _HomeTabWithLiveBar(),
        1 => _PlaceholderTab(title: l10n.donCuaToi),
        2 => _PlaceholderTab(title: l10n.tinNhan),
        _ => const _AccountTab(),
      },
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tabIndex,
        onDestinationSelected: (index) => setState(() => _tabIndex = index),
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.home_outlined),
            selectedIcon: const Icon(Icons.home_rounded),
            label: l10n.trangChu,
          ),
          NavigationDestination(
            icon: const Icon(Icons.bookmark_border),
            selectedIcon: const Icon(Icons.bookmark),
            label: l10n.donCuaToi,
          ),
          NavigationDestination(
            icon: SvgPicture.asset(
              'assets/icons/icon_chat.svg',
              width: 24,
              colorFilter: const ColorFilter.mode(
                AppColors.textSecondary,
                BlendMode.srcIn,
              ),
            ),
            selectedIcon: SvgPicture.asset(
              'assets/icons/icon_chat.svg',
              width: 24,
            ),
            label: l10n.tinNhan,
          ),
          NavigationDestination(
            icon: const Icon(Icons.person_outline),
            selectedIcon: const Icon(Icons.person),
            label: l10n.taiKhoan,
          ),
        ],
      ),
    );
  }
}

// Tab Trang chủ với đơn đang diễn ra
class _HomeTabWithLiveBar extends StatelessWidget {
  const _HomeTabWithLiveBar();

  @override
  Widget build(BuildContext context) {
    const orders = MockHomeData.activeOrders;
    return Stack(
      children: [
        OwnerHomeTab(bottomInset: orders.isEmpty ? 24 : 108),
        if (orders.isNotEmpty)
          Positioned(
            left: 0,
            right: 0,
            bottom: 12,
            child: ActiveOrderBar(orders: orders),
          ),
      ],
    );
  }
}

class _PlaceholderTab extends StatelessWidget {
  const _PlaceholderTab({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(title, style: AppTextStyles.h2),
            const SizedBox(height: 8),
            Text(
              context.l10n.chucNangDangPhatTrien,
              style: AppTextStyles.caption,
            ),
          ],
        ),
      ),
    );
  }
}

class _AccountTab extends ConsumerWidget {
  const _AccountTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.taiKhoan,
              textAlign: TextAlign.center,
              style: AppTextStyles.h1,
            ),
            const SizedBox(height: 8),
            Text(
              l10n.chucNangDangPhatTrien,
              textAlign: TextAlign.center,
              style: AppTextStyles.caption,
            ),
            const SizedBox(height: 32),
            AppButton(
              text: l10n.dangXuat,
              onTapAsync: () async {
                await ref.read(authProvider.notifier).logout();
                if (context.mounted) context.go(AppRoutes.login);
              },
            ),
          ],
        ),
      ),
    );
  }
}
