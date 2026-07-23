import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/router/app_router.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';
import 'package:petcare_app/features/provider_home/data/mock_provider_home.dart';
import 'package:petcare_app/features/provider_profile/data/service_draft.dart';
import 'package:petcare_app/features/provider_profile/data/service_summary.dart';
import 'package:petcare_app/features/provider_profile/widgets/service_list_card.dart';

// Dịch vụ của tôi dùng chung card và subtitle với màn Dịch vụ của tôi
class MyServicesSection extends StatefulWidget {
  const MyServicesSection({super.key, required this.services});

  final List<MockProviderService> services;

  @override
  State<MyServicesSection> createState() => _MyServicesSectionState();
}

class _MyServicesSectionState extends State<MyServicesSection> {
  late final Map<int, bool> _batTat = {
    for (final (i, s) in widget.services.indexed) i: s.isActive,
  };

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(l10n.dichVuCuaToi, style: AppTextStyles.h3),
            const Spacer(),
            InkWell(
              onTap: () => context.push(AppRoutes.providerServices),
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
        const SizedBox(height: 12),
        for (final (i, service) in widget.services.indexed) ...[
          _ServiceToggleCard(
            draft: service.draft,
            active: _batTat[i] ?? service.isActive,
            onToggle: (v) => setState(() => _batTat[i] = v),
          ),
          if (i != widget.services.length - 1) const SizedBox(height: 10),
        ],
      ],
    );
  }
}

// Card dịch vụ ở Home
class _ServiceToggleCard extends StatelessWidget {
  const _ServiceToggleCard({
    required this.draft,
    required this.active,
    required this.onToggle,
  });

  final ServiceDraft draft;
  final bool active;
  final ValueChanged<bool> onToggle;

  @override
  Widget build(BuildContext context) {
    return ServiceListCard(
      iconAsset: draft.type.iconAsset,
      title: draft.name,
      subtitle: serviceSummary(context, draft),
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
