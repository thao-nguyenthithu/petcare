import 'package:flutter/material.dart';
import 'package:petcare_app/core/theme/app_spacing.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';
import 'package:petcare_app/shared/data/prevention_record.dart';
import 'package:petcare_app/shared/data/prevention_summary.dart';
import 'package:petcare_app/shared/widgets/app_dong_ke.dart';

// Danh sách phòng bệnh ở màn hồ sơ bé
class PreventionSummaryRows extends StatelessWidget {
  const PreventionSummaryRows({super.key, required this.danhSach});

  final List<PreventionRecord> danhSach;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final (i, muc) in danhSach.indexed) ...[
          if (i > 0) const AppDongKe(),
          _Dong(muc: muc),
        ],
      ],
    );
  }
}

class _Dong extends StatelessWidget {
  const _Dong({required this.muc});

  final PreventionRecord muc;

  @override
  Widget build(BuildContext context) {
    final trangThai = muc.trangThai;
    final kieu = preventionCardStyle(trangThai);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.itemGap),
      child: Row(
        children: [
          Icon(kieu.icon, size: 16, color: kieu.mau),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tenCuaHangMuc(context, muc),
                  style: AppTextStyles.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  preventionCountAndLastLabel(context, muc),
                  style: AppTextStyles.captionSm,
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.labelGap),
          Text(
            preventionRemainLabel(context, muc),
            style: AppTextStyles.label.copyWith(
              color: preventionRemainColor(trangThai),
            ),
          ),
        ],
      ),
    );
  }
}
