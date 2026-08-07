import 'package:flutter/material.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';
import 'package:petcare_app/shared/widgets/pet_avatar.dart';

const double _avatar = 46;

// Hàng chủ nuôi: ảnh, tên và số đơn đã đặt
class SitterOrderOwnerRow extends StatelessWidget {
  const SitterOrderOwnerRow({
    super.key,
    required this.ten,
    required this.soDonDaDat,
    this.avatarUrl,
    this.onNhanTin,
  });

  final String ten;
  final int soDonDaDat;
  final String? avatarUrl;
  final VoidCallback? onNhanTin;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Row(
      children: [
        PetAvatar(imageUrl: avatarUrl, name: ten, size: _avatar),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(ten, style: AppTextStyles.label),
              const SizedBox(height: 4),
              Text(
                l10n.soDonDaDat('$soDonDaDat'),
                style: AppTextStyles.captionSm,
              ),
            ],
          ),
        ),
        if (onNhanTin case final nhanTin?)
          IconButton(
            onPressed: nhanTin,
            tooltip: l10n.nhanTin,
            style: IconButton.styleFrom(
              backgroundColor: AppColors.cardMint,
              fixedSize: const Size(38, 38),
              minimumSize: const Size(38, 38),
              padding: EdgeInsets.zero,
            ),
            icon: const Icon(
              Icons.chat_bubble_outline_rounded,
              size: 18,
              color: AppColors.primaryColor,
            ),
          ),
      ],
    );
  }
}
