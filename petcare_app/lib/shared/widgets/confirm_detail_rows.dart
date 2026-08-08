import 'package:flutter/material.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';

typedef DongChiTiet = ({
  IconData icon,
  String nhan,
  List<String> giaTri,
  String? phu,
  VoidCallback? onSua,
  String? duoiXanh,
});

// Mục Chi tiết đơn của màn xác nhận
class ConfirmDetailRows extends StatelessWidget {
  const ConfirmDetailRows({
    super.key,
    required this.dong,
    this.tieuDe,
    this.nhanHanhDong,
  });

  final List<DongChiTiet> dong;
  final String? tieuDe;
  final String? nhanHanhDong;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(tieuDe ?? l10n.chiTietDon, style: AppTextStyles.h3),
        const SizedBox(height: 14),
        for (final d in dong)
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(d.icon, size: 18, color: AppColors.textSecondary),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(d.nhan, style: AppTextStyles.captionSm),
                      const SizedBox(height: 4),
                      for (final (i, g) in d.giaTri.indexed)
                        if (d.duoiXanh case final duoi?
                            when i == d.giaTri.length - 1)
                          Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(text: '$g · '),
                                TextSpan(
                                  text: duoi,
                                  style: const TextStyle(
                                    color: AppColors.primaryColor,
                                  ),
                                ),
                              ],
                            ),
                            style: AppTextStyles.label,
                          )
                        else
                          Text(g, style: AppTextStyles.label),
                      if (d.phu != null) ...[
                        const SizedBox(height: 4),
                        Text(d.phu!, style: AppTextStyles.captionSm),
                      ],
                    ],
                  ),
                ),
                if (d.onSua != null) ...[
                  const SizedBox(width: 12),
                  InkWell(
                    onTap: d.onSua,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 2,
                      ),
                      child: Text(
                        nhanHanhDong ?? l10n.sua,
                        style: AppTextStyles.label.copyWith(
                          color: AppColors.primaryColor,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
      ],
    );
  }
}
