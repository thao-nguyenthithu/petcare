import 'package:flutter/material.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/theme/app_spacing.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';
import 'package:petcare_app/features/article/data/mock_article_data.dart';
import 'package:petcare_app/shared/utils/placeholder_action.dart';
import 'package:petcare_app/shared/utils/relative_time.dart';

// Một dòng bài viết
class ArticleRow extends StatelessWidget {
  const ArticleRow({super.key, required this.article});

  static const double imageWidth = 120;
  static const double imageHeight = 90;

  final MockArticle article;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => baoDangPhatTrien(context),
      child: Row(
        children: [
          Image.asset(
            article.coverImage,
            width: imageWidth,
            height: imageHeight,
            fit: BoxFit.cover,
          ),
          const SizedBox(width: AppSpacing.itemGap),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  article.title,
                  style: AppTextStyles.label,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppSpacing.labelGap),
                Row(
                  children: [
                    Text(
                      thoiGianTuongDoi(context.l10n, article.minutesAgo),
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
    );
  }
}
