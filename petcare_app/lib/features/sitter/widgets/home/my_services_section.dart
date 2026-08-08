import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/router/app_router.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_spacing.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';
import 'package:petcare_app/shared/data/service_summary.dart';
import 'package:petcare_app/shared/data/sitter_services.dart';
import 'package:petcare_app/features/sitter/providers/sitter_services_provider.dart';
import 'package:petcare_app/features/sitter/widgets/services/service_list_card.dart';

// Section Dịch vụ của tôi ở Home NCC
class MyServicesSection extends ConsumerWidget {
  const MyServicesSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final services =
        ref.watch(sitterServicesProvider).value ?? const SitterServices();
    final loaiDaCauHinh = services.configuredTypes;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(l10n.dichVuCuaToi, style: AppTextStyles.h3),
            const Spacer(),
            InkWell(
              onTap: () => context.push(AppRoutes.sitterServices),
              customBorder: const CircleBorder(),
              child: const Padding(
                padding: EdgeInsets.all(4),
                child: Icon(
                  Icons.chevron_right,
                  size: 24,
                  color: AppColors.accent,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.itemGap),
        for (final (i, type) in loaiDaCauHinh.indexed) ...[
          _ServiceToggleCard(
            type: type,
            services: services,
            active: services.isEnabled(type),
            onToggle: (v) =>
                ref.read(sitterServicesProvider.notifier).batTat(type, v),
          ),
          if (i != loaiDaCauHinh.length - 1) const SizedBox(height: 10),
        ],
      ],
    );
  }
}

// Card một loại dịch vụ ở Home
class _ServiceToggleCard extends StatelessWidget {
  const _ServiceToggleCard({
    required this.type,
    required this.services,
    required this.active,
    required this.onToggle,
  });

  final ServiceType type;
  final SitterServices services;
  final bool active;
  final ValueChanged<bool> onToggle;

  @override
  Widget build(BuildContext context) {
    return ServiceListCard(
      iconAsset: type.iconAsset,
      title: serviceTypeName(context, type),
      subtitle: serviceTypeSummary(context, services, type) ?? '',
      dimmed: !active,
      trailing: Switch(
        value: active,
        onChanged: onToggle,
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        activeTrackColor: AppColors.primaryColor,
      ),
    );
  }
}
