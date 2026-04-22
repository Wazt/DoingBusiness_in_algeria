import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:doingbusiness/data/models/article_model.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class ArticleRepository extends GetxController {
  static ArticleRepository get instance => Get.find();

  final _db = FirebaseFirestore.instance;

  /// Fetches the feed.
  /// [limit] caps the page size. Pass [startAfter] to paginate.
  /// Note: no Firestore orderBy (editorial articles may not carry
  /// `addedAt`); sorting is done client-side in the controller.
  Future<List<ArticleModel>> getFeaturedArticles({
    int limit = 50,
    DocumentSnapshot? startAfter,
  }) async {
    try {
      Query<Map<String, dynamic>> query =
          _db.collection('Articles').limit(limit);
      if (startAfter != null) {
        query = query.startAfterDocument(startAfter);
      }
      final snapshot = await query.get();
      return snapshot.docs.map((e) => ArticleModel.fromSnapshot(e)).toList();
    } on FirebaseException catch (e) {
      throw Exception(e.message ?? e.code);
    } on PlatformException catch (e) {
      throw Exception(e.message ?? e.code);
    } catch (e) {
      throw Exception('Unknown error while fetching articles.');
    }
  }

  Future<List<ArticleModel>> getCategoryArticles({
    required String categoryId,
    int limit = -1,
  }) async {
    try {
      final base = _db
          .collection('Articles')
          .where('category', isEqualTo: categoryId);
      final querySnapshot =
          limit == -1 ? await base.get() : await base.limit(limit).get();
      return querySnapshot.docs
          .map((article) => ArticleModel.fromSnapshot(article))
          .toList();
    } on FirebaseException catch (e) {
      throw Exception(e.message ?? e.code);
    } catch (e) {
      throw Exception('Unknown error while fetching category articles.');
    }
  }
}
