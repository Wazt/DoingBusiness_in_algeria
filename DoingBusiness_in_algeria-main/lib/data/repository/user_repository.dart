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
      throw e.code;
    } catch (e) {
      throw 'Somethiing went wrong';
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
      throw e.message.toString();
    } catch (e) {
      throw 'unkonw error';
    }
  }

  Future<void> updateUserDetails(UserModel updatedUser) async {
    try {
      await _db
          .collection('Users')
          .doc(updatedUser.id)
          .update(updatedUser.toJson());
    } on FirebaseException catch (e) {
      throw e.message.toString();
    } catch (e) {
      throw 'Unknown error';
    }
  }

  Future<void> updateSingleField(Map<String, dynamic> json) async {
    try {
      await _db
          .collection("Users")
          .doc(AuthenticationRepository.instance.authUser?.uid)
          .update(json);
    } on FirebaseException catch (e) {
      throw e.message.toString();
    } catch (e) {
      throw 'Unknown error has occured';
    }
  }

  Future<void> removeUserRecord(String userId) async {
    try {
      await _db.collection("Users").doc(userId).delete();
    } on FirebaseException catch (e) {
      throw e.message.toString();
    } catch (e) {
      throw 'Unknown error has occured';
    }
  }

  Future<void> deleteUserRecord(String uid) async {
    await _db.collection('Users').doc(uid).delete();
  }
}
