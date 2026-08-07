import 'package:flutter/material.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';

// Nhãn bo tròn dùng chung
class AppStatusBadge extends StatelessWidget {
  const AppStatusBadge({
    super.key,
    required this.label,
    required this.background,
    required this.textColor,
    this.leading,
  });

  final String label;
  final Color background;
  final Color textColor;
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (leading != null) ...[leading!, const SizedBox(width: 4)],
          // Nhãn dài hơn chỗ trống thì cắt bớt, không đẩy tràn hàng chứa nó
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.labelSm.copyWith(color: textColor),
            ),
          ),
        ],
      ),
    );
  }
}
