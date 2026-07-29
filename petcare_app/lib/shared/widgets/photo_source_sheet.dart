import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_radius.dart';
import 'package:petcare_app/core/theme/app_spacing.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';

// Hỏi lấy ảnh từ đâu
Future<ImageSource?> showPhotoSourceSheet(
  BuildContext context, {
  String? tieuDe,
}) {
  final l10n = context.l10n;
  return showModalBottomSheet<ImageSource>(
    context: context,
    showDragHandle: true,
    useSafeArea: true,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(AppRadius.radius20),
      ),
    ),
    builder: (sheetContext) {
      final mq = MediaQuery.of(sheetContext);
      return Padding(
        padding: EdgeInsets.fromLTRB(
          AppSpacing.screenPadding,
          0,
          AppSpacing.screenPadding,
          AppSpacing.itemGap + mq.viewPadding.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.labelGap),
              child: Text(tieuDe ?? l10n.themAnh, style: AppTextStyles.h3),
            ),
            _Dong(
              icon: Icons.photo_camera_outlined,
              nhan: l10n.chupAnh,
              onTap: () => Navigator.pop(sheetContext, ImageSource.camera),
            ),
            _Dong(
              icon: Icons.photo_library_outlined,
              nhan: l10n.chonTuThuVien,
              onTap: () => Navigator.pop(sheetContext, ImageSource.gallery),
            ),
          ],
        ),
      );
    },
  );
}

class _Dong extends StatelessWidget {
  const _Dong({required this.icon, required this.nhan, required this.onTap});

  final IconData icon;
  final String nhan;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, size: 20, color: AppColors.primaryColor),
      title: Text(
        nhan,
        style: AppTextStyles.label.copyWith(color: AppColors.textPrimary),
      ),
      onTap: onTap,
    );
  }
}
