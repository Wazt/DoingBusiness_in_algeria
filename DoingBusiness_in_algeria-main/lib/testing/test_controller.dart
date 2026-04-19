import 'package:flutter/foundation.dart';
import 'package:doingbusiness/presentation/Article/controllers/article_controller.dart';
import 'package:doingbusiness/presentation/Article/models/article_model.dart';

import 'package:get/get.dart';

class TestController extends GetxController {
  static TestController get instance => Get.find();

  RxList selectedCat = [].obs;
  final articleController = Get.put(ArticleController());

  RxList<ArticleModel> filteredArticles = <ArticleModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    resetList();
  }

  @override
  void onClose() {
    super.onClose();
  }

  resetList() {
    filteredArticles.value = articleController.featuredArticles.value;
  }

  chooseCat(String index) {
    selectedCat.value.add(index);
    filteredArticles.value = articleController.featuredArticles
        .where(
          (p0) => p0.categoryId == index,
        )
        .toList();
    debugPrint(selectedCat);
  }

  /*
  addItem(String itemName, String itemValue) {
    itemModel = ItemModel(itemName: itemName, itemValue: itemValue);
    itemList.value.add(itemModel);
    itemCount.value = itemList.value.length;
    debugPrint(itemList);
  }*/
}
