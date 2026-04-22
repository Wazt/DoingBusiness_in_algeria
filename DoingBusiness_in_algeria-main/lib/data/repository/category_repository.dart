import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:doingbusiness/presentation/Article/models/categorie_model.dart';
import 'package:get/get.dart';

class CategoryRepository extends GetxController {
  static CategoryRepository get instance => Get.find();

  final _db = FirebaseFirestore.instance;

  /// Fetch all categories.
  Future<List<CategorieModel>> fetchAllCategories() async {
    try {
      final snapshot = await _db.collection('categories').get();
      return snapshot.docs
          .map((e) => CategorieModel.fromSnapshot(e))
          .toList();
    } on FirebaseException catch (e) {
      throw Exception(e.message ?? e.code);
    } catch (e) {
      throw Exception('Unknown error while fetching categories.');
    }
  }
}
