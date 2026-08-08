import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/features/auth/providers/auth_provider.dart';

// Kéo xuống làm mới
class AppRefreshIndicator extends ConsumerWidget {
  const AppRefreshIndicator({super.key, required this.child, this.onRefresh});

  final Widget child;
  final Future<void> Function()? onRefresh;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return RefreshIndicator(
      color: AppColors.primaryColor,
      onRefresh: () async {
        ref.refreshUserData();
        if (onRefresh != null) await onRefresh!();
      },
      child: child,
    );
  }
}
