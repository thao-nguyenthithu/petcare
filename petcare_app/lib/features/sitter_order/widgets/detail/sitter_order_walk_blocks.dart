import 'package:flutter/material.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';
import 'package:petcare_app/features/sitter_order/data/sitter_order_detail.dart';
import 'package:petcare_app/shared/widgets/session_blocks.dart';
import 'package:petcare_app/shared/widgets/app_button.dart';

// Dòng nhắc đã qua cửa kiểm dụng cụ, đứng dưới bản đồ
class SitterGearVerified extends StatelessWidget {
  const SitterGearVerified({super.key, required this.gio});

  final String gio;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 1),
          child: Icon(
            Icons.check_circle,
            size: 20,
            color: AppColors.primaryColor,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.daXacMinhRoMomDayXichLuc(gio),
                style: AppTextStyles.label,
              ),
              const SizedBox(height: 3),
              Text(l10n.anhLuuTrongNhatKy, style: AppTextStyles.captionSm),
            ],
          ),
        ),
      ],
    );
  }
}

// Nhật ký ảnh của phiên kèm nút gửi thêm
class SitterSessionPhotoLog extends StatelessWidget {
  const SitterSessionPhotoLog({
    super.key,
    required this.don,
    required this.onGuiAnh,
    required this.onXemTatCa,
  });

  final SitterOrderDetail don;
  final VoidCallback onGuiAnh;
  final VoidCallback onXemTatCa;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SessionPhotoLog(
          anh: don.anhNhatKy,
          tong: don.tongAnhNhatKy,
          onXemTatCa: onXemTatCa,
        ),
        const SizedBox(height: 14),
        AppButton(
          text: l10n.guiAnhChoChuNuoi,
          outlined: true,
          height: 50,
          onTap: onGuiAnh,
        ),
        const SizedBox(height: 14),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(top: 1),
              child: Icon(
                Icons.balance_outlined,
                size: 18,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                l10n.ghiChuGuiItNhatMotAnh,
                style: AppTextStyles.captionSm,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
