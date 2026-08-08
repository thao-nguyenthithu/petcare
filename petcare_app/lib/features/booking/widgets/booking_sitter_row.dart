import 'package:flutter/material.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';
import 'package:petcare_app/shared/widgets/user_avatar.dart';

const double _avatar = 46;

// Hàng người chăm ở màn chi tiết đơn
class BookingSitterRow extends StatelessWidget {
  const BookingSitterRow({
    super.key,
    required this.ten,
    required this.rating,
    required this.soDanhGia,
    required this.onXemHoSo,
    this.avatarUrl,
    this.onNhanTin,
  });

  final String ten;
  final String? avatarUrl;
  final double rating;
  final int soDanhGia;
  final VoidCallback onXemHoSo;
  final VoidCallback? onNhanTin;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Row(
      children: [
        UserAvatar(name: ten, imageUrl: avatarUrl, size: _avatar),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                ten,
                style: AppTextStyles.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(
                    Icons.star_rounded,
                    size: 15,
                    color: AppColors.accent,
                  ),
                  const SizedBox(width: 5),
                  Text(rating.toStringAsFixed(1), style: AppTextStyles.label),
                  const SizedBox(width: 4),
                  Text('($soDanhGia)', style: AppTextStyles.captionSm),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        if (onNhanTin case final nhanTin?)
          _NutTron(icon: Icons.chat_bubble_outline, onTap: nhanTin)
        else
          InkWell(
            onTap: onXemHoSo,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              child: Text(
                l10n.hoSo,
                style: AppTextStyles.label.copyWith(
                  color: AppColors.primaryColor,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _NutTron extends StatelessWidget {
  const _NutTron({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      customBorder: const CircleBorder(),
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        alignment: Alignment.center,
        decoration: const BoxDecoration(
          color: AppColors.cardMint,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 18, color: AppColors.primaryColor),
      ),
    );
  }
}
