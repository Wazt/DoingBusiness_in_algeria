import 'package:doingbusiness/data/repository/article_repository.dart';
import 'package:doingbusiness/presentation/Article/models/article_model.dart';
import 'package:doingbusiness/utils/loaders/loaders.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

/// ════════════════════════════════════════════════════════════════════════
///  ArticleController — cleaned up
/// ════════════════════════════════════════════════════════════════════════
///  Bugs fixed:
///    ✘ import 'dart:ffi' — removed (breaks web, was unused)
///    ✘ print(selectedCat), print("fetching"), print('update the fetching'),
///      print(_storage.read('fontsize')) — all removed
///    ✔ onInit() now awaits properly (was calling async work without await)
///    ✔ filteredArticles refreshes reactively when featuredArticles changes
/// ════════════════════════════════════════════════════════════════════════
class ArticleController extends GetxController {
  static ArticleController get instance => Get.find();

  final isLoading = false.obs;
  final RxList<ArticleModel> featuredArticles  = <ArticleModel>[].obs;
  final RxList<ArticleModel> filteredArticles  = <ArticleModel>[].obs;
  final RxList<String>       selectedCategoryIds = <String>[].obs;

  final RxDouble fontSizeValue = 16.0.obs;

  final ArticleRepository articleRepo = Get.put(ArticleRepository());
  final GetStorage _storage = GetStorage();

  @override
  Future<void> onInit() async {
    super.onInit();
    fontSizeValue.value = (_storage.read('fontsize') as num?)?.toDouble() ?? 16.0;
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

  Future<void> fetchFeaturedArticles() async {
    try {
      isLoading.value = true;
      final articles = await articleRepo.getFeaturedArticles();
      featuredArticles.assignAll(articles);
      filteredArticles.assignAll(articles);
    } catch (e) {
      Loaders.errorSnackBar(title: 'Could not load articles', message: e.toString());
    } finally {
      isLoading.value = false;
    }
  }
}
