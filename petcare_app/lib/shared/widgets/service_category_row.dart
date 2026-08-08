import 'package:flutter/material.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/theme/app_spacing.dart';
import 'package:petcare_app/shared/data/service_catalog.dart';
import 'package:petcare_app/shared/utils/placeholder_action.dart';
import 'package:petcare_app/shared/widgets/service_category_card.dart';

// Hàng 3 loại dịch vụ của nền tảng
class ServiceCategoryRow extends StatelessWidget {
  const ServiceCategoryRow({super.key, this.onChon});
  final ValueChanged<LoaiDichVu>? onChon;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return SizedBox(
      height: 145,
      child: Row(
        children: [
          for (final loai in LoaiDichVu.values) ...[
            Expanded(
              child: ServiceCategoryCard(
                image: loai.anhMinhHoa,
                label: loai.ten(l10n),
                width: null,
                onTap: () =>
                    onChon == null ? baoDangPhatTrien(context) : onChon!(loai),
              ),
            ),
            if (loai != LoaiDichVu.values.last)
              const SizedBox(width: AppSpacing.itemGap),
          ],
        ],
      ),
    );
  }
}
