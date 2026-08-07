import 'package:flutter/material.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';
import 'package:petcare_app/shared/widgets/app_note_box.dart';
import 'package:petcare_app/shared/widgets/app_text_field.dart';

// Mục địa điểm và ghi chú của đơn
class BookingPlaceNote extends StatelessWidget {
  const BookingPlaceNote({
    super.key,
    required this.tieuDe,
    required this.icon,
    required this.nhan,
    required this.giaTri,
    required this.nhanHanhDong,
    required this.onHanhDong,
    required this.ghiChu,
    this.loi,
    this.dongPhu,
    this.ghiChuDongPhu,
  });

  final String tieuDe;
  final IconData icon;
  final String nhan;
  final String? giaTri;
  final String nhanHanhDong;
  final VoidCallback onHanhDong;
  final TextEditingController ghiChu;
  final String? loi;
  final ({IconData icon, String? nhan, String giaTri, String? duoi})? dongPhu;
  final String? ghiChuDongPhu;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final thieu = giaTri == null || giaTri!.isEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(tieuDe, style: AppTextStyles.h3),
        const SizedBox(height: 14),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 1),
              child: Icon(icon, size: 17, color: AppColors.textSecondary),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(nhan, style: AppTextStyles.captionSm),
                  const SizedBox(height: 3),
                  Text(
                    thieu ? l10n.banChuaCoDiaChiNao : giaTri!,
                    style: AppTextStyles.label.copyWith(
                      color: thieu ? AppColors.accent : null,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            InkWell(
              onTap: onHanhDong,
              child: Text(
                nhanHanhDong,
                style: AppTextStyles.label.copyWith(
                  color: AppColors.primaryColor,
                ),
              ),
            ),
          ],
        ),
        if (dongPhu case final phu?) ...[
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 1),
                child: Icon(phu.icon, size: 17, color: AppColors.textSecondary),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (phu.nhan case final nhanPhu?) ...[
                      Text(nhanPhu, style: AppTextStyles.captionSm),
                      const SizedBox(height: 3),
                    ],
                    Text(phu.giaTri, style: AppTextStyles.label),
                    if (phu.duoi case final duoi?) ...[
                      const SizedBox(height: 3),
                      Text(duoi, style: AppTextStyles.label),
                    ],
                  ],
                ),
              ),
            ],
          ),
          if (ghiChuDongPhu case final ghi?) ...[
            const SizedBox(height: 8),
            AppNoteBox(text: ghi),
          ],
        ],
        if (loi != null) ...[
          const SizedBox(height: 10),
          AppNoteBox(text: loi!, kieu: NoteKind.canhBao),
        ],
        const SizedBox(height: 14),
        AppTextField(
          label: '',
          hint: l10n.hintGhiChuDon,
          controller: ghiChu,
          maxLines: 3,
          fillColor: AppColors.surface,
        ),
      ],
    );
  }
}
