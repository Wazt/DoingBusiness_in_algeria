import 'dart:ffi';

import 'package:doingbusiness/data/repository/article_repository.dart';
import 'package:doingbusiness/data/models/article_model.dart';
import 'package:doingbusiness/utils/loaders/loaders.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ArticleController extends GetxController {
  static ArticleController get instance => Get.find();

  final isLoading = false.obs;
  RxList<ArticleModel> featuredArticles = <ArticleModel>[].obs;

  ArticleRepository articleRepo = Get.put(ArticleRepository());

  RxList selectedCat = [].obs;
  RxList<ArticleModel> filteredArticles = <ArticleModel>[].obs;
  RxBool selected = false.obs;

  RxDouble fontSizeValue = 16.0.obs;

  GetStorage _storage = GetStorage();

  @override
  void onInit() async {
    fetchFeaturedArticles();
    await _storage.writeIfNull('fontsize', fontSizeValue);
    resetList();
    super.onInit();
  }

  /*
   * Working on the saving system
   * When clicking on the saving button, add the current article to the saved list
   * at first the saved list is empty, and pushing into it (stack)
   * 
   * 
   * 
   */

  saveFontSize(double fontsizeVal) async {
    await _storage.write('fontsize', fontsizeVal);

    Loaders.successSnackBar(title: "Success", message: 'Font size Updated');
    print(_storage.read('fontsize'));
  }

  resetList() {
    filteredArticles.value = featuredArticles;
  }

  chooseCat(String index) {
    selectedCat.value = [];
    selectedCat.add(index);
    filteredArticles.value = featuredArticles
        .where(
          (p0) => p0.categoryId == index,
        )
        .toList();
    print(selectedCat);
  }

  Future<void> fetchFeaturedArticles() async {
    try {
      //start the loading
      print("fetching");
      isLoading.value = true;

      //fetch articles

      final articles = await articleRepo.getFeaturedArticles();
      print('update the fetching');
      //assign the articles

      featuredArticles.assignAll(articles);
    } catch (e) {
      Loaders.errorSnackBar(title: 'Oh snap', message: e.toString());
    } finally {
      isLoading.value = false;
    }
  }
}
