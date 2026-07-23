import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';
import 'package:petcare_app/features/account/screens/provider_account_screen.dart';
import 'package:petcare_app/features/provider_home/screens/provider_work_tab.dart';

// Home công việc của người cung cấp
class ProviderHomeScreen extends StatefulWidget {
  const ProviderHomeScreen({super.key});

  @override
  State<ProviderHomeScreen> createState() => _ProviderHomeScreenState();
}

class _ProviderHomeScreenState extends State<ProviderHomeScreen> {
  int _tabIndex = 0;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      body: switch (_tabIndex) {
        0 => const ProviderWorkTab(),
        1 => _PlaceholderTab(title: l10n.lich),
        2 => _PlaceholderTab(title: l10n.tinNhan),
        _ => const ProviderAccountScreen(),
      },
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tabIndex,
        onDestinationSelected: (index) => setState(() => _tabIndex = index),
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.work_outline_rounded),
            selectedIcon: const Icon(Icons.work_rounded),
            label: l10n.congViec,
          ),
          NavigationDestination(
            icon: const Icon(Icons.calendar_today_outlined),
            selectedIcon: const Icon(Icons.calendar_today),
            label: l10n.lich,
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
