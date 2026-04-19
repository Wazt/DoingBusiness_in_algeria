import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:doingbusiness/presentation/Article/models/article_model.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class ArticleRepository extends GetxController {
  static ArticleRepository get instance => Get.find();

  final _db = FirebaseFirestore.instance;

  //get featured articles

  Future<List<ArticleModel>> getFeaturedArticles() async {
    try {
      final snapshot = await _db.collection('Articles').get();
      print('fetching from firebase');

      // return a list of articles

      return snapshot.docs.map((e) => ArticleModel.fromSnapshot(e)).toList();
    } on FirebaseException catch (e) {
      throw e.message.toString();
    } on PlatformException catch (e) {
      throw e.message.toString();
    } catch (e) {
      throw e;
    }
  }

  Future<List<ArticleModel>> getCategoryArticles(
      {required String categoryId, int limit = -1}) async {
    try {
      final querySnapshot = limit == -1
          ? await _db
              .collection("Articles")
              .where('category', isEqualTo: categoryId)
              .get()
          : await _db
              .collection("Articles")
              .where('category', isEqualTo: categoryId)
              .limit(limit)
              .get();
      final articles = querySnapshot.docs
          .map((article) => ArticleModel.fromSnapshot(article))
          .toList();
      return articles;
    } catch (e) {
      throw 'something went south';
    }
  }
}
