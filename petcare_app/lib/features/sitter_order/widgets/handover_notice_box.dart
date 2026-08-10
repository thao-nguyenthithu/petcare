import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_radius.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';
import 'package:petcare_app/shared/widgets/app_card.dart';

const int _soCot = 4;

const double _khe = 10;

// Một nhóm ảnh bàn giao: ảnh các bé hoặc ảnh đồ dùng
class HandoverPhotoGroup extends StatelessWidget {
  const HandoverPhotoGroup({
    super.key,
    required this.tieuDe,
    required this.anh,
    required this.tran,
    required this.onThem,
  });

  final String tieuDe;

  final List<Uint8List> anh;
  final int tran;

  final VoidCallback onThem;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(tieuDe, style: AppTextStyles.h3),
        const SizedBox(height: 12),
        LayoutBuilder(
          builder: (context, rang) {
            final canh = (rang.maxWidth - _khe * (_soCot - 1)) / _soCot;
            return Wrap(
              spacing: _khe,
              runSpacing: _khe,
              children: [
                for (final tam in anh) _OAnh(bytes: tam, canh: canh),
                if (anh.length < tran) _OThem(canh: canh, onTap: onThem),
              ],
            );
          },
        ),
      ],
    );
  }
}

class HandoverNoticeBox extends StatelessWidget {
  const HandoverNoticeBox({super.key, required this.chinh, this.phu});

  final String chinh;
  final String? phu;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      width: double.infinity,
      nen: AppColors.cardMint,
      vien: false,
      padding: const EdgeInsets.all(14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.verified_user_outlined,
            size: 18,
            color: AppColors.primaryColor,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  chinh,
                  style: AppTextStyles.label.copyWith(
                    color: AppColors.primaryColor,
                  ),
                ),
                if (phu case final p? when p.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    p,
                    style: AppTextStyles.captionSm.copyWith(
                      color: AppColors.primaryColor,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OAnh extends StatelessWidget {
  const _OAnh({required this.bytes, required this.canh});

  final Uint8List bytes;
  final double canh;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.radius14),
      child: Image.memory(bytes, width: canh, height: canh, fit: BoxFit.cover),
    );
  }
}

class _OThem extends StatelessWidget {
  const _OThem({required this.canh, required this.onTap});

  final double canh;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.radius14),
      child: Container(
        width: canh,
        height: canh,
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(AppRadius.radius14),
          border: Border.all(color: AppColors.neutralLight),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.photo_camera_outlined,
              size: 20,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 6),
            Text(context.l10n.chupThem, style: AppTextStyles.captionSm),
          ],
        ),
      ),
    );
  }
}
