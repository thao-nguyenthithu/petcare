import 'package:flutter/material.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_spacing.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';
import 'package:petcare_app/shared/data/conversation.dart';
import 'package:petcare_app/shared/widgets/app_filter_chip.dart';

// Panel lọc hội thoại, bung dưới header tab Tin nhắn
class ConversationFilterPanel extends StatelessWidget {
  const ConversationFilterPanel({
    super.key,
    required this.sessionFilter,
    required this.serviceTypes,
    required this.onSessionChanged,
    required this.onToggleServiceType,
  });

  final ConversationState? sessionFilter; // null = tất cả trạng thái
  final Set<ServiceType> serviceTypes; // rỗng = tất cả loại dịch vụ
  final ValueChanged<ConversationState?> onSessionChanged;
  final ValueChanged<ServiceType> onToggleServiceType;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Container(
      width: double.infinity,
      color: AppColors.background,
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenPadding,
        AppSpacing.itemGap,
        AppSpacing.screenPadding,
        AppSpacing.itemGap,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _FilterGroupLabel(l10n.trangThai),
          Wrap(
            spacing: AppSpacing.labelGap,
            runSpacing: AppSpacing.labelGap,
            children: [
              AppFilterChip(
                label: l10n.tatCa,
                selected: sessionFilter == null,
                onTap: () => onSessionChanged(null),
              ),
              for (final trangThai in ConversationState.values)
                AppFilterChip(
                  label: _nhanTrangThai(context, trangThai),
                  selected: sessionFilter == trangThai,
                  onTap: () => onSessionChanged(trangThai),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.itemGap),
          _FilterGroupLabel(l10n.loaiDichVu),
          Wrap(
            spacing: AppSpacing.blockGap,
            runSpacing: AppSpacing.textGap,
            children: [
              for (final loai in ServiceType.values)
                _ServiceCheckbox(
                  label: _nhanDichVu(context, loai),
                  selected: serviceTypes.contains(loai),
                  onTap: () => onToggleServiceType(loai),
                ),
            ],
          ),
        ],
      ),
    );
  }

  String _nhanTrangThai(BuildContext context, ConversationState trangThai) {
    final l10n = context.l10n;
    return switch (trangThai) {
      ConversationState.sapToi => l10n.sapToi,
      ConversationState.dangDienRa => l10n.dangDienRa,
      ConversationState.choXacNhan => l10n.trangThaiChoXacNhan,
      ConversationState.daKetThuc => l10n.daKetThuc,
    };
  }

  String _nhanDichVu(BuildContext context, ServiceType loai) {
    final l10n = context.l10n;
    return switch (loai) {
      ServiceType.walking => l10n.datDiDao,
      ServiceType.boarding => l10n.trongGiu,
      ServiceType.grooming => l10n.tamVaTia,
    };
  }
}

// Nhãn nhóm trong panel lọc
class _FilterGroupLabel extends StatelessWidget {
  const _FilterGroupLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.labelGap),
      child: Text(text, style: AppTextStyles.label),
    );
  }
}

// Ô checkbox
class _ServiceCheckbox extends StatelessWidget {
  const _ServiceCheckbox({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 24,
            height: 24,
            child: Checkbox(
              value: selected,
              onChanged: (_) => onTap(),
              activeColor: AppColors.primaryColor,
              visualDensity: VisualDensity.compact,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              side: const BorderSide(color: AppColors.neutralLight, width: 1.5),
            ),
          ),
          const SizedBox(width: AppSpacing.textGap),
          Text(
            label,
            style: AppTextStyles.captionSm.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
