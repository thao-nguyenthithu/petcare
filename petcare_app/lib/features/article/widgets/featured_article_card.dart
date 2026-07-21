import 'package:flutter/material.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_radius.dart';
import 'package:petcare_app/core/theme/app_spacing.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';
import 'package:petcare_app/features/article/data/mock_article_data.dart';
import 'package:petcare_app/shared/utils/placeholder_action.dart';
import 'package:petcare_app/shared/utils/relative_time.dart';

// Card bài viết nổi bật
class FeaturedArticleCard extends StatelessWidget {
  const FeaturedArticleCard({super.key, required this.article});

  final MockArticle article;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Material(
      color: AppColors.surface,
      elevation: 3,
      shadowColor: AppColors.shadow,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.radius14),
      ),
      child: InkWell(
        onTap: () => baoDangPhatTrien(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Image.asset(
                  article.coverImage,
                  height: 160,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
                Positioned(
                  top: 12,
                  left: 12,
                  child: DecoratedBox(
                    decoration: const ShapeDecoration(
                      color: AppColors.primaryColor,
                      shape: StadiumBorder(),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.itemGap,
                        vertical: AppSpacing.labelGap,
                      ),
                      child: Text(
                        l10n.noiBat,
                        style: AppTextStyles.captionSm.copyWith(
                          color: AppColors.textWhite,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.cardPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(article.title, style: AppTextStyles.h3),
                  if (article.description != null) ...[
                    const SizedBox(height: AppSpacing.labelGap),
                    Text(
                      article.description!,
                      style: AppTextStyles.body,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: AppSpacing.labelGap),
                  Row(
                    children: [
                      Text(
                        thoiGianTuongDoi(l10n, article.minutesAgo),
                        style: AppTextStyles.captionSm,
                      ),
                      const Text(' · ', style: AppTextStyles.captionSm),
                      Flexible(
                        child: Text(
                          article.category,
                          style: AppTextStyles.captionSm,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
