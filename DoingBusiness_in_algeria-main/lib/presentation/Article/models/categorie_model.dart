import 'package:cloud_firestore/cloud_firestore.dart';

class CategorieModel {
  int id;
  String name;
  String parentId;
  bool isFeatured;

  CategorieModel(
      {required this.id,
      required this.name,
      this.parentId = "",
      required this.isFeatured});

  static CategorieModel empty() =>
      CategorieModel(id: 0, name: '', isFeatured: false);

  Map<String, dynamic> toJson() {
    return {'name': name, 'parentId': parentId, 'isFeatured': isFeatured};
  }

  factory CategorieModel.fromSnapshot(
      DocumentSnapshot<Map<String, dynamic>> document) {
    if (document.data() != null) {
      final data = document.data()!;
      return CategorieModel(
          id: (data['id'] as num?)?.toInt() ?? 0,
          name: (data['name'] as String?) ?? '',
          isFeatured: (data['isFeatured'] as bool?) ?? false);
    } else {
      return CategorieModel.empty();
    }
  }
}
