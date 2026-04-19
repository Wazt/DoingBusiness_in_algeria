import 'package:doingbusiness/data/repository/article_repository.dart';
import 'package:doingbusiness/data/repository/category_repository.dart';
import 'package:doingbusiness/data/models/article_model.dart';
import 'package:doingbusiness/presentation/Article/models/categorie_model.dart';
import 'package:doingbusiness/utils/loaders/loaders.dart';
import 'package:get/get.dart';

/// ════════════════════════════════════════════════════════════════════════
///  CategoryController — fixed
/// ════════════════════════════════════════════════════════════════════════
///  Bugs fixed:
///    ✘ Loaders.errorSnackBar(message: e.toString)  ← missing ()
///       → Snackbar would show "Closure: () => String" to users.
///    ✔ Now: message: e.toString()
/// ════════════════════════════════════════════════════════════════════════
class CategoryController extends GetxController {
  static CategoryController get instance => Get.find();

  final isLoading = false.obs;
  final _categoryRepo = Get.put(CategoryRepository());

  final RxList<CategorieModel> allCategories      = <CategorieModel>[].obs;
  final RxList<CategorieModel> featuredCategories = <CategorieModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchCategories();
  }

  Future<void> fetchCategories() async {
    try {
      isLoading.value = true;
      final categories = await _categoryRepo.fetchAllCategories();
      allCategories.assignAll(categories);
      featuredCategories.assignAll(
        allCategories.where((c) => c.isFeatured && c.parentId.isEmpty),
      );
    } catch (e) {
      Loaders.errorSnackBar(
        title: 'Could not load categories',
        message: e.toString(),  // ← FIXED: was e.toString without ()
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<List<ArticleModel>> getCategoryArticles(String categoryId) async {
    return ArticleRepository.instance.getCategoryArticles(categoryId: categoryId);
  }
}
