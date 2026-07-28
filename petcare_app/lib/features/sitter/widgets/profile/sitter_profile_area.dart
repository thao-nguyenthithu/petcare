import 'package:flutter/material.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';
import 'package:petcare_app/features/sitter/data/sitter_service_area.dart';
import 'package:petcare_app/features/sitter/widgets/profile/service_area_map.dart';
import 'package:petcare_app/shared/widgets/map_preview.dart';

// Mục Khu vực phục vụ, chạm để mở bản đồ toàn màn hình
class SitterProfileArea extends StatelessWidget {
  const SitterProfileArea({super.key, required this.area});

  final SitterServiceArea? area;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final area = this.area;
    final daDat = area != null && area.daDat;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.khuVucPhucVu, style: AppTextStyles.h3),
        const SizedBox(height: 12),
        if (!daDat)
          Text(
            l10n.chuaDatKhuVuc,
            style: AppTextStyles.body.copyWith(
              color: AppColors.textSecondary,
              fontStyle: FontStyle.italic,
            ),
          )
        else ...[
          MapPreview(
            viTri: area.viTri!,
            zoom: zoomTheoBanKinh(area.radiusKm),
            banKinhKm: area.radiusKm,
            icon: Icons.zoom_out_map,
            nhan: l10n.chamDeXemBanDo,
            onDoi: () => moXemBanDo(context, area.viTri!, area.radiusKm),
          ),
          const SizedBox(height: 12),
          // Bán kính nhận dịch vụ
          Text(
            l10n.banKinhKm(l10n.soKm('${area.radiusKm}')),
            style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ],
    );
  }
}
