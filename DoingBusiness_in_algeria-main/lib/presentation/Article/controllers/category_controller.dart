import 'package:doingbusiness/data/repository/article_repository.dart';
import 'package:doingbusiness/data/repository/category_repository.dart';
import 'package:doingbusiness/data/models/article_model.dart';
import 'package:doingbusiness/presentation/Article/models/categorie_model.dart';
import 'package:doingbusiness/utils/loaders/loaders.dart';
import 'package:get/get.dart';

class CategoryController extends GetxController {
  static CategoryController get instance => Get.find();

  final isLoading = false.obs;
  final _categoryRepo = Get.put(CategoryRepository());
  RxList<CategorieModel> allCategories = <CategorieModel>[].obs;
  RxList<CategorieModel> featuredCategory = <CategorieModel>[].obs;

  @override
  void onInit() {
    fetchCategories();
    super.onInit();
  }

  //load categories data

  Future<void> fetchCategories() async {
    try {
      //show loader

      isLoading.value = true;

      //fetch categories from data sources

      final categories = await _categoryRepo.fetchAllCategories();

      // Update the category list

      allCategories.assignAll(categories);

      //Filter featured category

      featuredCategory.assignAll(allCategories
          .where((category) => category.isFeatured && category.parentId.isEmpty)
          .toList());
    } catch (e) {
      Loaders.errorSnackBar(title: "oh snap", message: e.toString);
    } finally {
      isLoading.value = false;
    }
  }
  //load selected category data

  // get category articles

  Future<List<ArticleModel>> getCategoryArticles(String categoryId) async {
    final articles = await ArticleRepository.instance
        .getCategoryArticles(categoryId: categoryId);
    return articles;
  }
}
