import 'package:flutter/material.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';
import 'package:petcare_app/shared/data/sitter_review.dart';
import 'package:petcare_app/shared/widgets/app_dong_ke.dart';
import 'package:petcare_app/shared/widgets/pet_avatar_stack.dart';
import 'package:petcare_app/shared/widgets/review_stars.dart';

const int _soXemTruoc = 2;

// Mục Đánh giá ở trang chi tiết NCC phía chủ nuôi
class SitterProfileReviews extends StatelessWidget {
  const SitterProfileReviews({
    super.key,
    required this.tongSo,
    required this.reviews,
    this.onXemTatCa,
  });

  final int tongSo;
  final List<SitterReview> reviews;
  final VoidCallback? onXemTatCa;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final hien = reviews.take(_soXemTruoc).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.danhGiaSo('$tongSo'), style: AppTextStyles.h3),
        const SizedBox(height: 12),
        if (hien.isEmpty)
          Text(
            l10n.chuaCoDanhGia,
            style: AppTextStyles.body.copyWith(
              color: AppColors.textSecondary,
              fontStyle: FontStyle.italic,
            ),
          )
        else ...[
          for (final (i, r) in hien.indexed) ...[
            if (i != 0)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 14),
                child: AppDongKe(),
              ),
            _Danh(review: r),
          ],
          if (onXemTatCa != null) ...[
            const SizedBox(height: 16),
            Center(
              child: InkWell(
                onTap: onXemTatCa,
                child: Text(
                  l10n.xemTatCaNDanhGia('$tongSo'),
                  style: AppTextStyles.label.copyWith(color: AppColors.accent),
                ),
              ),
            ),
          ],
        ],
      ],
    );
  }
}

// Một đánh giá
class _Danh extends StatelessWidget {
  const _Danh({required this.review});

  final SitterReview review;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final phu = [
      review.service,
      if (review.pets.length > 1) l10n.soBe('${review.pets.length}'),
      review.time,
    ].join(' · ');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(review.name, style: AppTextStyles.label),
                  const SizedBox(height: 4),
                  ReviewStars(so: review.stars),
                  const SizedBox(height: 4),
                  Text(phu, style: AppTextStyles.captionSm),
                ],
              ),
            ),
            if (review.pets.isNotEmpty)
              PetAvatarStack(pets: review.pets, size: 26),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          review.text,
          style: AppTextStyles.body.copyWith(color: AppColors.textPrimary),
        ),
      ],
    );
  }
}
