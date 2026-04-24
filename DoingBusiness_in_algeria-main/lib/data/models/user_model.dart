import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  String username;
  String email;
  String id;

  UserModel({required this.username, required this.email, required this.id});

  Map<String, dynamic> toJson() {
    return {'username': username, 'email': email};
  }

  static UserModel empty() => UserModel(username: '', email: '', id: '');

  factory UserModel.fromSnapshot(
      DocumentSnapshot<Map<String, dynamic>> document) {
    if (document.data() != null) {
      final data = document.data();
      return UserModel(
        username: (data!['username'] as String?) ?? '',
        email: (data['email'] as String?) ?? '',
        id: document.id,
      );
    } else {
      return UserModel.empty();
    }
  }
}
