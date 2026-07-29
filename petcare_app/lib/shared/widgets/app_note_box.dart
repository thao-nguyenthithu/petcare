import 'package:flutter/material.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_radius.dart';
import 'package:petcare_app/core/theme/app_spacing.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';

const Color nenCanhBao = Color(0xFFFCECE3);

enum NoteKind { thuong, nhac, canhBao }

// icon và chữ ghi chú cùng màu
class AppNoteBox extends StatelessWidget {
  const AppNoteBox({
    super.key,
    required this.text,
    this.kieu = NoteKind.thuong,
    this.coNen = false,
  });

  final String text;
  final NoteKind kieu;

  final bool coNen;

  @override
  Widget build(BuildContext context) {
    final mauChu = switch (kieu) {
      NoteKind.thuong => AppColors.textSecondary,
      NoteKind.nhac => AppColors.primaryColor,
      NoteKind.canhBao => AppColors.accent,
    };
    final icon = kieu == NoteKind.canhBao
        ? Icons.warning_amber_rounded
        : Icons.info_outline;
    final dong = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: mauChu),
        const SizedBox(width: AppSpacing.labelGap),
        Expanded(
          child: Text(
            text,
            style: AppTextStyles.captionSm.copyWith(color: mauChu),
          ),
        ),
      ],
    );
    if (!coNen) return dong;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      decoration: BoxDecoration(
        color: kieu == NoteKind.canhBao ? nenCanhBao : AppColors.cardMint,
        borderRadius: BorderRadius.circular(AppRadius.radius14),
      ),
      child: dong,
    );
  }
}
