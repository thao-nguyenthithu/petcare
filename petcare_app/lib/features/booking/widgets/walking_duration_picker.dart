import 'package:flutter/material.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';
import 'package:petcare_app/shared/data/sitter_services.dart';
import 'package:petcare_app/shared/utils/money_format.dart';
import 'package:petcare_app/shared/widgets/button_select.dart';

// Mục chọn mức thời lượng của một lượt dắt
class WalkingDurationPicker extends StatelessWidget {
  const WalkingDurationPicker({
    super.key,
    required this.tenNcc,
    required this.config,
    required this.chon,
    required this.onChon,
  });

  final String tenNcc;
  final WalkingConfig config;
  final int? chon;
  final void Function(int phut) onChon;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.chonGoiCua(tenNcc), style: AppTextStyles.h3),
        const SizedBox(height: 14),
        for (final phut in walkingDurations)
          if (config.priceByDuration[phut] != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: ButtonSelect(
                selected: chon == phut,
                title: l10n.nPhut('$phut'),
                titleColor: chon == phut ? AppColors.primaryColor : null,
                subtitle: _moTaMuc(context, phut),
                trailing: Text(
                  '${dinhDangTien(config.priceByDuration[phut]!)}đ',
                  style: AppTextStyles.label.copyWith(
                    color: chon == phut ? AppColors.primaryColor : null,
                  ),
                ),
                onTap: () => onChon(phut),
              ),
            ),
      ],
    );
  }
}

String _moTaMuc(BuildContext context, int phut) =>
    phut <= 30 ? context.l10n.moTaGoi30Phut : context.l10n.moTaGoi60Phut;
