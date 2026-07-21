import 'package:flutter/material.dart';
import 'package:petcare_app/core/theme/app_colors.dart';
import 'package:petcare_app/core/theme/app_spacing.dart';
import 'package:petcare_app/features/article/data/mock_article_data.dart';
import 'package:petcare_app/features/article/widgets/article_row.dart';

// Danh sách bài viết xem trước ở màn Home
class ArticleList extends StatelessWidget {
  const ArticleList({super.key, required this.articles});

  final List<MockArticle> articles;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
      child: Column(
        children: [
          for (var i = 0; i < articles.length; i++) ...[
            if (i > 0) const ArticleDivider(),
            ArticleRow(article: articles[i]),
          ],
        ],
      ),
    );
  }
}

// Đường kẻ giữa hai bài
class ArticleDivider extends StatelessWidget {
  const ArticleDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return const Divider(
      color: AppColors.neutral,
      height: AppSpacing.groupGap,
      indent: ArticleRow.imageWidth + AppSpacing.itemGap,
    );
  }
}
