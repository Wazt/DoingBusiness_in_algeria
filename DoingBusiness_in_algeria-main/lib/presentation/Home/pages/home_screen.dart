import 'package:cached_network_image/cached_network_image.dart';
import 'package:doingbusiness/core/configs/theme/app_colors.dart';
import 'package:doingbusiness/core/configs/theme/app_spacing.dart';
import 'package:doingbusiness/presentation/Article/controllers/article_controller.dart';
import 'package:doingbusiness/presentation/Article/controllers/category_controller.dart';
import 'package:doingbusiness/presentation/Article/models/article_model.dart';
import 'package:doingbusiness/presentation/Article/pages/article_screen.dart';
import 'package:doingbusiness/presentation/auth/controllers/user_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';

/// ════════════════════════════════════════════════════════════════════════
///  HomeScreen — REDESIGNED
/// ════════════════════════════════════════════════════════════════════════
///  Structure (top to bottom):
///    1. Sticky app bar with greeting + avatar
///    2. Featured hero article (big card)
///    3. Categories chip bar (horizontal scroll)
///    4. "Latest" list of articles (vertical scroll)
///
///  Design notes:
///    - Card-based, editorial feel — content is THE product
///    - No background image — respects dark mode, lighter memory footprint
///    - Shimmer placeholders during load (feels faster)
///    - Pull-to-refresh for user agency
/// ════════════════════════════════════════════════════════════════════════
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final articleController  = Get.put(ArticleController());
    final categoryController = Get.put(CategoryController());
    final userController     = UserController.instance;
    final theme = Theme.of(context);

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: articleController.fetchFeaturedArticles,
        child: CustomScrollView(
          slivers: [
            // ─── App bar ─────────────────────────────────
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg, AppSpacing.md, AppSpacing.lg, AppSpacing.sm,
              ),
              sliver: SliverToBoxAdapter(
                child: Obx(() {
                  final username = userController.user.value.username;
                  return Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              username.isEmpty ? 'Welcome' : 'Hello, ${username.split(' ').first}',
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: theme.colorScheme.onSurface.withOpacity(0.7),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text('Doing Business', style: theme.textTheme.headlineMedium),
                          ],
                        ),
                      ),
                      CircleAvatar(
                        radius: 22,
                        backgroundColor: AppColors.brandPurple.withOpacity(0.15),
                        child: const Icon(Icons.person_outline_rounded, color: AppColors.brandPurple),
                      ),
                    ],
                  );
                }),
              ),
            ),

            // ─── Featured hero ───────────────────────────
            SliverToBoxAdapter(
              child: Obx(() {
                if (articleController.isLoading.value && articleController.featuredArticles.isEmpty) {
                  return const _HeroSkeleton();
                }
                if (articleController.featuredArticles.isEmpty) {
                  return const _EmptyState();
                }
                final featured = articleController.featuredArticles.first;
                return Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg, AppSpacing.md, AppSpacing.lg, AppSpacing.xxl,
                  ),
                  child: _FeaturedHero(article: featured),
                );
              }),
            ),

            // ─── Category chips ──────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.md,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Categories', style: theme.textTheme.titleLarge),
                    TextButton(onPressed: () {}, child: const Text('See all')),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 40,
                child: Obx(() {
                  if (categoryController.isLoading.value) return const _ChipsSkeleton();
                  return ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                    itemCount: categoryController.featuredCategories.length,
                    separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.sm),
                    itemBuilder: (_, i) {
                      final c = categoryController.featuredCategories[i];
                      return ActionChip(
                        label: Text(c.name),
                        onPressed: () => articleController.filterByCategory(c.id),
                      );
                    },
                  );
                }),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xxl)),

            // ─── Latest articles list ────────────────────
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.md,
              ),
              sliver: SliverToBoxAdapter(
                child: Text('Latest', style: theme.textTheme.titleLarge),
              ),
            ),

            Obx(() {
              if (articleController.isLoading.value) {
                return const SliverPadding(
                  padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                  sliver: SliverList.list(
                    children: [_ListItemSkeleton(), _ListItemSkeleton(), _ListItemSkeleton()],
                  ),
                );
              }
              final rest = articleController.filteredArticles.skip(1).toList();
              if (rest.isEmpty) return const SliverToBoxAdapter(child: SizedBox.shrink());
              return SliverPadding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.huge,
                ),
                sliver: SliverList.separated(
                  itemCount: rest.length,
                  separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.lg),
                  itemBuilder: (_, i) => _ArticleListItem(article: rest[i]),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  Sub-widgets
// ─────────────────────────────────────────────────────────────

class _FeaturedHero extends StatelessWidget {
  final ArticleModel article;
  const _FeaturedHero({required this.article});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: () => Get.to(() => ArticleScreen(article: article)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        child: Stack(
          children: [
            AspectRatio(
              aspectRatio: 16 / 10,
              child: CachedNetworkImage(
                imageUrl: article.imageUrl,
                fit: BoxFit.cover,
                errorWidget: (_, __, ___) => Container(color: AppColors.brandPurple.withOpacity(0.2)),
                placeholder: (_, __) => Container(color: theme.colorScheme.surfaceContainerHighest),
              ),
            ),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black.withOpacity(0.78)],
                    stops: const [0.4, 1.0],
                  ),
                ),
              ),
            ),
            Positioned(
              left: AppSpacing.xl,
              right: AppSpacing.xl,
              bottom: AppSpacing.xl,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md, vertical: AppSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.brandCoral,
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: const Text(
                      'FEATURED',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    article.titre,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
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

class _ArticleListItem extends StatelessWidget {
  final ArticleModel article;
  const _ArticleListItem({required this.article});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: () => Get.to(() => ArticleScreen(article: article)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            child: SizedBox(
              width: 96,
              height: 96,
              child: CachedNetworkImage(
                imageUrl: article.imageUrl,
                fit: BoxFit.cover,
                errorWidget: (_, __, ___) => Container(color: AppColors.brandPurple.withOpacity(0.15)),
                placeholder: (_, __) => Container(color: theme.colorScheme.surfaceContainerHighest),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  article.titre,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  article.blog,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.65),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Skeletons ─────────────────────────────────────────────────

class _HeroSkeleton extends StatelessWidget {
  const _HeroSkeleton();
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Shimmer.fromColors(
        baseColor: theme.colorScheme.surfaceContainerHighest,
        highlightColor: theme.colorScheme.surface,
        child: AspectRatio(
          aspectRatio: 16 / 10,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            ),
          ),
        ),
      ),
    );
  }
}

class _ChipsSkeleton extends StatelessWidget {
  const _ChipsSkeleton();
  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      itemCount: 5,
      separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.sm),
      itemBuilder: (_, __) => Shimmer.fromColors(
        baseColor: Theme.of(context).colorScheme.surfaceContainerHighest,
        highlightColor: Theme.of(context).colorScheme.surface,
        child: Container(
          width: 80,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(100),
          ),
        ),
      ),
    );
  }
}

class _ListItemSkeleton extends StatelessWidget {
  const _ListItemSkeleton();
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: Shimmer.fromColors(
        baseColor: theme.colorScheme.surfaceContainerHighest,
        highlightColor: theme.colorScheme.surface,
        child: Row(
          children: [
            Container(
              width: 96, height: 96,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              ),
            ),
            const SizedBox(width: AppSpacing.lg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(height: 16, color: Colors.white),
                  const SizedBox(height: 8),
                  Container(height: 12, width: 200, color: Colors.white),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xxl),
      child: Column(
        children: [
          Icon(Icons.article_outlined, size: 64, color: theme.colorScheme.onSurface.withOpacity(0.3)),
          const SizedBox(height: AppSpacing.lg),
          Text('No articles yet', style: theme.textTheme.titleMedium),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Pull down to refresh.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }
}
