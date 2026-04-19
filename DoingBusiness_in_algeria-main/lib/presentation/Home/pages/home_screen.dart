import 'package:cached_network_image/cached_network_image.dart';
import 'package:doingbusiness/core/configs/theme/app_colors.dart';
import 'package:doingbusiness/core/configs/theme/app_spacing.dart';
import 'package:doingbusiness/data/models/article_model.dart';
import 'package:doingbusiness/presentation/Article/controllers/article_controller.dart';
import 'package:doingbusiness/presentation/Article/controllers/category_controller.dart';
import 'package:doingbusiness/presentation/Article/pages/article_screen.dart';
import 'package:doingbusiness/presentation/auth/controllers/user_controller.dart';
import 'package:doingbusiness/presentation/shared/widgets/source_tag.dart';
import 'package:doingbusiness/presentation/shared/widgets/thumbnail_with_linkedin_badge.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';

/// Editorial home screen: wordmark + hero + category chips + "Latest" feed.
/// Articles render with a small source tag — GT Editorial (coral) vs
/// LinkedIn (blue with "in" mark). LinkedIn-mirrored articles also get a
/// blue "in" badge overlaid on the thumbnail.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final articleController = Get.put(ArticleController());
    final categoryController = Get.put(CategoryController());
    final userController = Get.put(UserController());

    return Scaffold(
      backgroundColor: AppColors.lightBg,
      body: RefreshIndicator(
        color: AppColors.brandPurple,
        onRefresh: () async {
          await articleController.fetchFeaturedArticles();
        },
        child: CustomScrollView(
          slivers: [
            _HomeAppBar(userController: userController),
            _HeroSection(articleController: articleController),
            _FilterChipsSliver(
              articleController: articleController,
              categoryController: categoryController,
            ),
            _LatestHeader(articleController: articleController),
            _LatestList(articleController: articleController),
            const SliverToBoxAdapter(
              child: SizedBox(height: AppSpacing.huge),
            ),
          ],
        ),
      ),
    );
  }
}

// ───────────────────────── App bar ─────────────────────────
class _HomeAppBar extends StatelessWidget {
  const _HomeAppBar({required this.userController});
  final UserController userController;

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      backgroundColor: AppColors.lightBg,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      pinned: false,
      floating: true,
      titleSpacing: AppSpacing.lg,
      toolbarHeight: 64,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const _Wordmark(),
          Obx(() {
            final name = userController.user.value.username;
            final initials = _initials(name.isEmpty ? 'GT' : name);
            return CircleAvatar(
              radius: 17,
              backgroundColor: AppColors.brandPurple,
              child: Text(
                initials,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2 && parts[0].isNotEmpty && parts[1].isNotEmpty) {
      return (parts[0][0] + parts[1][0]).toUpperCase();
    }
    return (name.isEmpty ? 'GT' : name[0]).toUpperCase();
  }
}

class _Wordmark extends StatelessWidget {
  const _Wordmark();
  @override
  Widget build(BuildContext context) {
    return RichText(
      text: const TextSpan(
        children: [
          TextSpan(
            text: 'Doing',
            style: TextStyle(
              fontFamily: 'Playfair Display',
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: AppColors.brandPurpleDark,
              letterSpacing: -0.4,
            ),
          ),
          TextSpan(
            text: '.',
            style: TextStyle(
              fontFamily: 'Playfair Display',
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: AppColors.brandCoral,
            ),
          ),
          TextSpan(
            text: 'Business',
            style: TextStyle(
              fontFamily: 'Playfair Display',
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: AppColors.brandPurpleDark,
              letterSpacing: -0.4,
            ),
          ),
        ],
      ),
    );
  }
}

// ───────────────────────── Hero ─────────────────────────
class _HeroSection extends StatelessWidget {
  const _HeroSection({required this.articleController});
  final ArticleController articleController;

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Obx(() {
        if (articleController.isLoading.value) {
          return const _HeroSkeleton();
        }
        final list = articleController.featuredArticles;
        if (list.isEmpty) return const SizedBox.shrink();
        final hero = list.first;
        return _HeroCard(article: hero);
      }),
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({required this.article});
  final ArticleModel article;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg, AppSpacing.xs, AppSpacing.lg, AppSpacing.lg,
      ),
      child: InkWell(
        onTap: () => Get.to(() => ArticleScreen(article: article)),
        borderRadius: BorderRadius.circular(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Kicker
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: article.isLinkedIn
                  ? SourceTag(source: article.source)
                  : const Text(
                      'FEATURED',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 2.0,
                        color: AppColors.brandCoral,
                      ),
                    ),
            ),
            const SizedBox(height: AppSpacing.sm),
            // Title
            Text(
              article.titre,
              style: const TextStyle(
                fontFamily: 'Source Serif 4',
                fontSize: 26,
                fontWeight: FontWeight.w700,
                height: 1.15,
                color: AppColors.lightText,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            // Image
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: AspectRatio(
                aspectRatio: 16 / 10,
                child: article.imageUrl.isEmpty
                    ? const _HeroGradient()
                    : CachedNetworkImage(
                        imageUrl: article.imageUrl,
                        fit: BoxFit.cover,
                        placeholder: (_, __) => const _HeroGradient(),
                        errorWidget: (_, __, ___) => const _HeroGradient(),
                      ),
              ),
            ),
            const SizedBox(height: AppSpacing.sm + 2),
            // Meta
            DefaultTextStyle.merge(
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.lightTextTertiary,
              ),
              child: Row(
                children: [
                  Flexible(
                    child: Text(
                      article.author ?? 'Grant Thornton',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppColors.brandPurpleDark,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  _dot(),
                  const Text('8 min read'),
                  _dot(),
                  Flexible(
                    child: Text(
                      _categoryLabel(article.categoryId),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _dot() => const Padding(
        padding: EdgeInsets.symmetric(horizontal: 6),
        child: Icon(Icons.circle, size: 2, color: AppColors.lightTextTertiary),
      );
}

class _HeroGradient extends StatelessWidget {
  const _HeroGradient();
  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.brandPurpleLight,
            AppColors.brandPurple,
            AppColors.brandPurpleDark,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
    );
  }
}

class _HeroSkeleton extends StatelessWidget {
  const _HeroSkeleton();
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg, AppSpacing.xs, AppSpacing.lg, AppSpacing.lg,
      ),
      child: Shimmer.fromColors(
        baseColor: AppColors.lightSurfaceAlt,
        highlightColor: AppColors.lightSurface,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 80, height: 10,
              color: Colors.white,
            ),
            const SizedBox(height: 12),
            Container(width: double.infinity, height: 22, color: Colors.white),
            const SizedBox(height: 8),
            Container(width: 200, height: 22, color: Colors.white),
            const SizedBox(height: 14),
            AspectRatio(
              aspectRatio: 16 / 10,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ───────────────────────── Filter chips ─────────────────────────
class _FilterChipsSliver extends StatelessWidget {
  const _FilterChipsSliver({
    required this.articleController,
    required this.categoryController,
  });
  final ArticleController articleController;
  final CategoryController categoryController;

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.sm + 2),
        child: SizedBox(
          height: 36,
          child: Obx(() {
            final selected = articleController.selectedCategoryIds;
            final categories = categoryController.allCategories;
            return ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              physics: const BouncingScrollPhysics(),
              children: [
                _Chip(
                  label: 'All',
                  active: selected.isEmpty,
                  onTap: () => articleController.resetFilter(),
                ),
                const SizedBox(width: 6),
                for (int i = 0; i < categories.length; i++) ...[
                  _Chip(
                    label: categories[i].name,
                    active: selected.contains(categories[i].id.toString()),
                    onTap: () => articleController
                        .filterByCategory(categories[i].id.toString()),
                  ),
                  if (i < categories.length - 1) const SizedBox(width: 6),
                ],
              ],
            );
          }),
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.active,
    required this.onTap,
  });
  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      curve: Curves.easeOut,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 4),
          decoration: BoxDecoration(
            color: active ? AppColors.brandPurple : Colors.transparent,
            border: Border.all(
              color: active ? AppColors.brandPurple : AppColors.lightBorder,
            ),
            borderRadius: BorderRadius.circular(999),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.1,
              color: active ? Colors.white : AppColors.lightTextSecondary,
            ),
          ),
        ),
      ),
    );
  }
}

// ───────────────────────── Latest list ─────────────────────────
class _LatestHeader extends StatelessWidget {
  const _LatestHeader({required this.articleController});
  final ArticleController articleController;

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg, AppSpacing.sm, AppSpacing.lg, AppSpacing.sm + 2,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Latest',
              style: TextStyle(
                fontFamily: 'Playfair Display',
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.lightText,
              ),
            ),
            TextButton(
              onPressed: () {
                // Let the Discover tab handle browsing all articles.
                Get.find<ArticleController>().resetFilter();
              },
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: const Size(44, 28),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text(
                'See all →',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.brandPurple,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LatestList extends StatelessWidget {
  const _LatestList({required this.articleController});
  final ArticleController articleController;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (articleController.isLoading.value) {
        return SliverList.list(children: const [
          _ListItemSkeleton(),
          _ListItemSkeleton(),
          _ListItemSkeleton(),
        ]);
      }
      final all = articleController.filteredArticles;
      // Skip the first (shown in hero) if the filter is empty; otherwise show all filtered results.
      final list = articleController.selectedCategoryIds.isEmpty && all.isNotEmpty
          ? all.skip(1).toList()
          : all;
      if (list.isEmpty) {
        return const SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.lg, vertical: AppSpacing.xxl,
            ),
            child: Text(
              'No articles in this category yet.',
              style: TextStyle(color: AppColors.lightTextTertiary),
            ),
          ),
        );
      }
      return SliverList.separated(
        itemCount: list.length,
        separatorBuilder: (_, __) => const Divider(
          height: 1, color: AppColors.lightBorder, indent: AppSpacing.lg, endIndent: AppSpacing.lg,
        ),
        itemBuilder: (_, i) => _ArticleRow(article: list[i]),
      );
    });
  }
}

class _ArticleRow extends StatelessWidget {
  const _ArticleRow({required this.article});
  final ArticleModel article;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Get.to(() => ArticleScreen(article: article)),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg, vertical: AppSpacing.sm + 2,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ThumbnailWithLinkedInBadge(
              imageUrl: article.imageUrl,
              size: 72,
              showLinkedInBadge: article.isLinkedIn,
            ),
            const SizedBox(width: AppSpacing.md + 2),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SourceTag(source: article.source),
                  const SizedBox(height: 4),
                  Text(
                    article.titre,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: 'Source Serif 4',
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      height: 1.3,
                      color: AppColors.lightText,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    _metaLine(article),
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.lightTextTertiary,
                    ),
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

class _ListItemSkeleton extends StatelessWidget {
  const _ListItemSkeleton();
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg, vertical: AppSpacing.sm + 2,
      ),
      child: Shimmer.fromColors(
        baseColor: AppColors.lightSurfaceAlt,
        highlightColor: AppColors.lightSurface,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 72, height: 72,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            const SizedBox(width: AppSpacing.md + 2),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(width: 60, height: 9, color: Colors.white),
                  const SizedBox(height: 10),
                  Container(width: double.infinity, height: 14, color: Colors.white),
                  const SizedBox(height: 6),
                  Container(width: 180, height: 14, color: Colors.white),
                  const SizedBox(height: 8),
                  Container(width: 120, height: 10, color: Colors.white),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Simple helpers
String _categoryLabel(String id) {
  if (id.isEmpty) return 'Insight';
  return id; // If CategoryController lookup is desired later, swap in the name.
}

String _metaLine(ArticleModel a) {
  final parts = <String>[];
  if (a.categoryId.isNotEmpty) parts.add(_categoryLabel(a.categoryId));
  parts.add('${_estimateMinutes(a.blog)} min');
  if (a.addedAt != null) parts.add(_relativeDate(a.addedAt!));
  return parts.join(' · ');
}

int _estimateMinutes(String body) {
  if (body.isEmpty) return 3;
  final words = body.split(RegExp(r'\s+')).length;
  return (words / 220).ceil().clamp(1, 30);
}

String _relativeDate(DateTime d) {
  final diff = DateTime.now().difference(d);
  if (diff.inDays >= 7) return '${(diff.inDays / 7).floor()}w ago';
  if (diff.inDays >= 1) return '${diff.inDays}d ago';
  if (diff.inHours >= 1) return '${diff.inHours}h ago';
  return 'just now';
}
