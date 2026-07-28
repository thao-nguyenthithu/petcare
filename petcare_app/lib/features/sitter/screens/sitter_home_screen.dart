import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/features/account/screens/sitter_account_screen.dart';
import 'package:petcare_app/features/messaging/providers/conversations_provider.dart';
import 'package:petcare_app/features/messaging/screens/sitter_messages_screen.dart';
import 'package:petcare_app/features/messaging/widgets/chat_nav_icon.dart';
import 'package:petcare_app/features/sitter/providers/sitter_services_provider.dart';
import 'package:petcare_app/features/sitter/screens/sitter_schedule_screen.dart';
import 'package:petcare_app/features/sitter/screens/sitter_work_tab.dart';

// Home công việc của người cung cấp
class SitterHomeScreen extends ConsumerStatefulWidget {
  const SitterHomeScreen({super.key});

  @override
  ConsumerState<SitterHomeScreen> createState() => _SitterHomeScreenState();
}

class _SitterHomeScreenState extends ConsumerState<SitterHomeScreen> {
  int _tabIndex = 0;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final unread = ref.watch(sitterUnreadCountProvider);
    // Chưa thiết lập xong khóa các tab khác
    final chuaXongOnboarding =
        !(ref.watch(sitterOnboardingProvider).value ?? false);
    return Scaffold(
      body: switch (_tabIndex) {
        0 => const SitterWorkTab(),
        1 => const SitterScheduleScreen(),
        2 => const SitterMessagesScreen(),
        _ => const SitterAccountScreen(),
      },
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tabIndex,
        onDestinationSelected: (index) {
          if (chuaXongOnboarding && index != 0) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(l10n.deTiepTucThietLap)));
            return; // khóa tab khác khi chưa thiết lập xong
          }
          setState(() => _tabIndex = index);
        },
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
            icon: ChatNavIcon(unread: unread),
            selectedIcon: ChatNavIcon(unread: unread, selected: true),
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
