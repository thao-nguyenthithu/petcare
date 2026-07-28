import 'package:flutter/material.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_radius.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';

// Ô Thêm ảnh trang sửa trang cá nhân NCC
class PhotoAddTile extends StatelessWidget {
  const PhotoAddTile({super.key, this.canh, required this.onTap});

  final double? canh;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: canh,
        height: canh,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadius.radius14),
          border: Border.all(color: AppColors.neutral),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.add, color: AppColors.primaryColor),
            const SizedBox(height: 4),
            Text(
              context.l10n.themAnh,
              style: AppTextStyles.captionSm.copyWith(fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }
}
