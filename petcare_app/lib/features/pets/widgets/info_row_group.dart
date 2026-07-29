import 'package:flutter/material.dart';
import 'package:petcare_app/core/theme/app_spacing.dart';
import 'package:petcare_app/shared/widgets/app_dong_ke.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';

typedef InfoRow = ({String nhan, String giaTri});

// Bảng thông tin dạng dòng dùng cho khối Thông tin cơ bản và Sức khoẻ ở màn hồ sơ bé
class InfoRowGroup extends StatelessWidget {
  const InfoRowGroup({super.key, required this.dong});

  final List<InfoRow> dong;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final (i, muc) in dong.indexed) ...[
          if (i > 0) const AppDongKe(),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.itemGap),
            child: Row(
              children: [
                Expanded(child: Text(muc.nhan, style: AppTextStyles.captionSm)),
                const SizedBox(width: AppSpacing.itemGap),
                Text(
                  muc.giaTri,
                  textAlign: TextAlign.right,
                  style: AppTextStyles.label,
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
