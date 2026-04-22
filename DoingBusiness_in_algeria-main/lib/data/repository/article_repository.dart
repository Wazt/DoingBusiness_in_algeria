import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:doingbusiness/data/models/article_model.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

/// Page of articles + the Firestore cursor needed to fetch the next page.
class ArticlesPage {
  final List<ArticleModel> items;
  final DocumentSnapshot? cursor;
  const ArticlesPage(this.items, this.cursor);
}

class ArticleRepository extends GetxController {
  static ArticleRepository get instance => Get.find();

  final _db = FirebaseFirestore.instance;

  /// Fetches the first page (or a continuation page when [startAfter] is
  /// provided). Returns the parsed models + the raw last document so the
  /// caller can pass it back as [startAfter] for the next page.
  ///
  /// Note: no Firestore orderBy — editorial articles may not carry
  /// `addedAt`, and `orderBy` would silently drop them. The controller
  /// sorts client-side.
  Future<ArticlesPage> getFeaturedArticlesPage({
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
      final items =
          snapshot.docs.map((e) => ArticleModel.fromSnapshot(e)).toList();
      final cursor = snapshot.docs.isEmpty ? null : snapshot.docs.last;
      return ArticlesPage(items, cursor);
    } on FirebaseException catch (e) {
      throw Exception(e.message ?? e.code);
    } on PlatformException catch (e) {
      throw Exception(e.message ?? e.code);
    } catch (e) {
      throw Exception('Unknown error while fetching articles.');
    }
  }

  /// Back-compat wrapper. New callers should use [getFeaturedArticlesPage].
  Future<List<ArticleModel>> getFeaturedArticles({
    int limit = 50,
    DocumentSnapshot? startAfter,
  }) async {
    final page =
        await getFeaturedArticlesPage(limit: limit, startAfter: startAfter);
    return page.items;
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
