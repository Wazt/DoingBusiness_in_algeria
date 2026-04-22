import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:doingbusiness/data/models/user_model.dart';
import 'package:doingbusiness/presentation/auth/controllers/authentication_repository.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';

class UserRepository extends GetxController {
  static UserRepository get instance => Get.find();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> saveUserRecord(UserModel user) async {
    try {
      await _db.collection("Users").doc(user.id).set(user.toJson());
    } on FirebaseException catch (e) {
      throw Exception(e.message ?? e.code);
    } catch (e) {
      throw Exception('Something went wrong while saving the user record.');
    }
  }

  Future<UserModel> fetchUserDetails() async {
    try {
      final documentSnapshot = await _db
          .collection("Users")
          .doc(AuthenticationRepository.instance.authUser?.uid)
          .get();
      if (documentSnapshot.exists) {
        return UserModel.fromSnapshot(documentSnapshot);
      } else {
        return UserModel.empty();
      }
    } on FirebaseException catch (e) {
      throw Exception(e.message ?? e.code);
    } catch (e) {
      throw Exception('Unknown error while fetching user details.');
    }
  }

  Future<void> updateUserDetails(UserModel updatedUser) async {
    try {
      await _db
          .collection('Users')
          .doc(updatedUser.id)
          .update(updatedUser.toJson());
    } on FirebaseException catch (e) {
      throw Exception(e.message ?? e.code);
    } catch (e) {
      throw Exception('Unknown error while updating user details.');
    }
  }

  Future<void> updateSingleField(Map<String, dynamic> json) async {
    try {
      await _db
          .collection("Users")
          .doc(AuthenticationRepository.instance.authUser?.uid)
          .update(json);
    } on FirebaseException catch (e) {
      throw Exception(e.message ?? e.code);
    } catch (e) {
      throw Exception('Unknown error while updating user field.');
    }
  }

  Future<void> removeUserRecord(String userId) async {
    try {
      await _db.collection("Users").doc(userId).delete();
    } on FirebaseException catch (e) {
      throw Exception(e.message ?? e.code);
    } catch (e) {
      throw Exception('Unknown error while removing user record.');
    }
  }

  Future<void> deleteUserRecord(String uid) async {
    await _db.collection('Users').doc(uid).delete();
  }
}
