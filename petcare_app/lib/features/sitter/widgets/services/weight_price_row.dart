import 'package:flutter/material.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_radius.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';
import 'package:petcare_app/shared/utils/money_format.dart';

const _banPhimSo = TextInputType.numberWithOptions(
  signed: false,
  decimal: false,
);

// Hàng bảng giá theo cân nặng checkbox bật/tắt ô nhập giá bên phải
class WeightPriceRow extends StatefulWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final bool selected;
  final ValueChanged<bool> onToggle;

  const WeightPriceRow({
    super.key,
    required this.label,
    required this.hint,
    required this.controller,
    required this.selected,
    required this.onToggle,
  });

  @override
  State<WeightPriceRow> createState() => _WeightPriceRowState();
}

class _WeightPriceRowState extends State<WeightPriceRow> {
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  Color get _mauVien {
    if (!widget.selected) return AppColors.neutral;
    return _focusNode.hasFocus ? AppColors.primaryColor : AppColors.neutral;
  }

  @override
  Widget build(BuildContext context) {
    final dangChon = widget.selected;
    return Container(
      height: 46,
      padding: const EdgeInsets.only(left: 6, right: 16),
      decoration: BoxDecoration(
        color: dangChon ? AppColors.surface : AppColors.background,
        borderRadius: BorderRadius.circular(AppRadius.radius14),
        border: Border.all(
          color: _mauVien,
          width: dangChon && _focusNode.hasFocus ? 1.5 : 1,
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 32,
            child: Checkbox(
              value: dangChon,
              onChanged: (value) => widget.onToggle(value ?? false),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: VisualDensity.compact,
              side: const BorderSide(color: AppColors.neutral),
            ),
          ),
          const SizedBox(width: 4),
          Text(
            widget.label,
            style: AppTextStyles.label.copyWith(
              color: dangChon ? AppColors.textPrimary : AppColors.textSecondary,
            ),
          ),
          const Spacer(),
          SizedBox(
            width: 100,
            child: TextField(
              controller: widget.controller,
              focusNode: _focusNode,
              enabled: dangChon,
              textAlign: TextAlign.right,
              keyboardType: _banPhimSo,
              inputFormatters: const [DinhDangTienFormatter()],
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textPrimary,
              ),
              decoration: InputDecoration(
                hintText: dangChon ? widget.hint : '',
                hintStyle: AppTextStyles.caption,
                isDense: true,
                border: InputBorder.none,
                disabledBorder: InputBorder.none,
              ),
            ),
          ),
          const SizedBox(width: 4),
          Text(context.l10n.donViDong, style: AppTextStyles.captionSm),
        ],
      ),
    );
  }
}
