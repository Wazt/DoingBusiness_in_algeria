import 'package:doingbusiness/presentation/Article/controllers/article_controller.dart';
import 'package:doingbusiness/presentation/Article/models/article_model.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

/// ════════════════════════════════════════════════════════════════════════
///  SavedController — fixed
/// ════════════════════════════════════════════════════════════════════════
///  Previous bugs:
///    ✘ initSavedArticles() crashed on first launch when storage key was null
///    ✘ print(savedArticles) on every save/unsave — removed
///    ✘ RxList<dynamic> instead of RxList<String> — type loss
///
///  Fix:
///    ✔ Null-safe init with typed RxList<String>
///    ✔ No more print in production path
///    ✔ Bookmark ID list + lookup in articleController.featuredArticles to
///      build the full ArticleModel list reactively
/// ════════════════════════════════════════════════════════════════════════
class SavedController extends GetxController {
  static SavedController get instance => Get.find();

  static const _storageKey = 'saved_articles_v2';  // bumped from 'saved_Articles1' to force a clean start

  final GetStorage _storage = GetStorage();
  final RxList<String> savedArticleIds = <String>[].obs;

  @override
  void onInit() {
    super.onInit();
    _loadFromStorage();
  }

  void _loadFromStorage() {
    final raw = _storage.read(_storageKey);
    if (raw is List) {
      savedArticleIds.assignAll(raw.whereType<String>());
    } else {
      savedArticleIds.clear();
      _storage.write(_storageKey, <String>[]);
    }
  }

  bool isSaved(String articleId) => savedArticleIds.contains(articleId);

  Future<void> toggleSaved(String articleId) async {
    if (isSaved(articleId)) {
      savedArticleIds.remove(articleId);
    } else {
      savedArticleIds.add(articleId);
    }
    await _storage.write(_storageKey, savedArticleIds.toList());
  }

  Future<void> clearAll() async {
    savedArticleIds.clear();
    await _storage.write(_storageKey, <String>[]);
  }

  /// Materialize the saved IDs into actual ArticleModel objects,
  /// filtering out any IDs whose article no longer exists in the feed.
  List<ArticleModel> get savedArticles {
    final articleController = Get.isRegistered<ArticleController>()
        ? ArticleController.instance
        : null;
    if (articleController == null) return [];

    return savedArticleIds
        .map((id) {
          try {
            return articleController.featuredArticles.firstWhere((a) => a.id == id);
          } catch (_) {
            return null;
          }
        })
        .whereType<ArticleModel>()
        .toList();
  }
}
