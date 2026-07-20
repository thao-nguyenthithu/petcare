import 'package:flutter/material.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';
import 'package:petcare_app/features/home/data/mock_home_data.dart';
import 'package:petcare_app/shared/utils/placeholder_action.dart';

// Danh sách bài viết
class ArticleList extends StatelessWidget {
  const ArticleList({super.key, required this.articles});

  final List<MockArticle> articles;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          for (var i = 0; i < articles.length; i++) ...[
            if (i > 0)
              const Divider(
                color: AppColors.neutral,
                height: 24,
                indent: _ArticleRow.imageWidth + _ArticleRow.gap,
              ),
            _ArticleRow(article: articles[i]),
          ],
        ],
      ),
    );
  }
}

class _ArticleRow extends StatelessWidget {
  const _ArticleRow({required this.article});
  static const double imageWidth = 120;
  static const double gap = 12;

  final MockArticle article;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => baoDangPhatTrien(context),
      child: Row(
        children: [
          ClipRRect(
            child: Image.asset(
              article.coverImage,
              width: imageWidth,
              height: 90,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: gap),
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
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(article.readingTime, style: AppTextStyles.captionSm),
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
