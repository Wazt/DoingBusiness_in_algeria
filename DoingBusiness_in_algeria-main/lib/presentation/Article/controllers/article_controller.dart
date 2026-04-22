import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:doingbusiness/data/models/article_model.dart';
import 'package:doingbusiness/data/repository/article_repository.dart';
import 'package:doingbusiness/utils/error_mapper.dart';
import 'package:doingbusiness/utils/loaders/loaders.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

/// Feeds the Home screen. Paginated — the first page is fetched eagerly in
/// `onInit`; subsequent pages are pulled by the UI via `loadMore()` when
/// the user scrolls near the bottom.
///
/// Client-side sort by `addedAt` DESC so the hero always shows the most
/// recent article (LinkedIn-mirrored or editorial with a timestamp).
class ArticleController extends GetxController {
  static ArticleController get instance => Get.find();

  /// Page size — snappy first paint + covers hero + "Latest" above-the-fold.
  static const int pageSize = 30;

  final isLoading = false.obs;
  final isLoadingMore = false.obs;
  final hasMore = true.obs;

  final RxList<ArticleModel> featuredArticles = <ArticleModel>[].obs;
  final RxList<ArticleModel> filteredArticles = <ArticleModel>[].obs;
  final RxList<String> selectedCategoryIds = <String>[].obs;

  final RxDouble fontSizeValue = 16.0.obs;

  final ArticleRepository articleRepo = Get.put(ArticleRepository());
  final GetStorage _storage = GetStorage();

  /// Cursor for the next page — populated by [fetchFeaturedArticles] and
  /// [loadMore]. Null means "no more pages / haven't fetched yet".
  DocumentSnapshot? _cursor;

  @override
  Future<void> onInit() async {
    super.onInit();
    fontSizeValue.value =
        (_storage.read('fontsize') as num?)?.toDouble() ?? 16.0;
    await fetchFeaturedArticles();
  }

  Future<void> saveFontSize(double value) async {
    fontSizeValue.value = value;
    await _storage.write('fontsize', value);
    Loaders.successSnackBar(title: 'Success', message: 'Font size updated');
  }

  void resetFilter() {
    selectedCategoryIds.clear();
    filteredArticles.assignAll(featuredArticles);
  }

  void filterByCategory(String categoryId) {
    selectedCategoryIds
      ..clear()
      ..add(categoryId);
    filteredArticles.assignAll(
      featuredArticles.where((a) => a.categoryId == categoryId),
    );
  }

  /// First page — used on initial load and pull-to-refresh.
  Future<void> fetchFeaturedArticles() async {
    try {
      isLoading.value = true;
      hasMore.value = true;
      _cursor = null;
      final page =
          await articleRepo.getFeaturedArticlesPage(limit: pageSize);
      _applyPage(page, append: false);
    } catch (e) {
      Loaders.errorSnackBar(
        title: 'Could not load articles',
        message: ErrorMapper.toUserMessage(e),
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Next page — idempotent + re-entrant safe.
  Future<void> loadMore() async {
    if (isLoadingMore.value || !hasMore.value || _cursor == null) return;
    try {
      isLoadingMore.value = true;
      final page = await articleRepo.getFeaturedArticlesPage(
        limit: pageSize,
        startAfter: _cursor,
      );
      _applyPage(page, append: true);
    } catch (e) {
      Loaders.errorSnackBar(
        title: 'Could not load more articles',
        message: ErrorMapper.toUserMessage(e),
      );
    } finally {
      isLoadingMore.value = false;
    }
  }

  void _applyPage(ArticlesPage page, {required bool append}) {
    _cursor = page.cursor;
    hasMore.value = page.items.length >= pageSize;

    final combined =
        append ? [...featuredArticles, ...page.items] : [...page.items];

    // Newest first. Entries without `addedAt` sink to the bottom.
    combined.sort((a, b) {
      final at = a.addedAt;
      final bt = b.addedAt;
      if (at == null && bt == null) return 0;
      if (at == null) return 1;
      if (bt == null) return -1;
      return bt.compareTo(at);
    });

    featuredArticles.assignAll(combined);
    if (selectedCategoryIds.isEmpty) {
      filteredArticles.assignAll(combined);
    } else {
      final selected = selectedCategoryIds.toSet();
      filteredArticles.assignAll(
        combined.where((a) => selected.contains(a.categoryId)),
      );
    }
  }
}
