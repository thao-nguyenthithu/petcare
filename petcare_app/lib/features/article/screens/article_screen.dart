import 'package:flutter/material.dart';
import 'package:petcare_app/core/l10n/l10n_ext.dart';
import 'package:petcare_app/core/theme/app_spacing.dart';
import 'package:petcare_app/core/theme/app_text_styles.dart';
import 'package:petcare_app/features/article/data/mock_article_data.dart';
import 'package:petcare_app/features/article/widgets/article_list.dart';
import 'package:petcare_app/features/article/widgets/article_row.dart';
import 'package:petcare_app/features/article/widgets/featured_article_card.dart';
import 'package:petcare_app/shared/widgets/app_screen_header.dart';

// Màn Mẹo chăm sóc
class ArticleScreen extends StatefulWidget {
  const ArticleScreen({super.key});

  @override
  State<ArticleScreen> createState() => _ArticleScreenState();
}

class _ArticleScreenState extends State<ArticleScreen> {
  static const double _nguongTaiThem = 320;

  final ScrollController _scrollController = ScrollController();
  final List<MockArticle> _articles = [];
  int _trangKeTiep = 0;
  bool _dangTai = false;
  bool _conBaiDeTai = true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_khiCuon);
    _taiThem();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _khiCuon() {
    final conLai =
        _scrollController.position.maxScrollExtent -
        _scrollController.position.pixels;
    if (conLai < _nguongTaiThem) _taiThem();
  }

  Future<void> _taiThem() async {
    if (_dangTai || !_conBaiDeTai) return;
    setState(() => _dangTai = true);
    final themVao = await MockArticle.taiTrang(_trangKeTiep);
    if (!mounted) return;
    setState(() {
      _articles.addAll(themVao);
      _trangKeTiep++;
      _conBaiDeTai = themVao.length == MockArticle.pageSize;
      _dangTai = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppScreenHeader(title: l10n.meoChamSoc),
                  const Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppSpacing.screenPadding,
                    ),
                    child: FeaturedArticleCard(article: MockArticle.featured),
                  ),
                  const SizedBox(height: AppSpacing.sectionGap),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.screenPadding,
                    ),
                    child: Text(l10n.baiVietMoi, style: AppTextStyles.h3),
                  ),
                  const SizedBox(height: AppSpacing.titleGap),
                ],
              ),
            ),
            // Chỉ dòng nào lọt vào khung nhìn mới được dựng
            SliverPadding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.screenPadding,
              ),
              sliver: SliverList.builder(
                itemCount: _articles.length,
                itemBuilder: (context, index) => Column(
                  children: [
                    if (index > 0) const ArticleDivider(),
                    ArticleRow(article: _articles[index]),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: AppSpacing.groupGap,
                ),
                child: _dangTai
                    ? const Center(child: CircularProgressIndicator())
                    : const SizedBox.shrink(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
