import 'package:doingbusiness/data/models/user_model.dart';
import 'package:doingbusiness/data/repository/user_repository.dart';
import 'package:doingbusiness/utils/loaders/loaders.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class UserController extends GetxController {
  static UserController get instance => Get.find();

  Rx<UserModel> user = UserModel.empty().obs;

  final userRepo = Get.put(UserRepository());

  final profileLoading = false.obs;
  @override
  void onInit() {
    super.onInit();
    fetchUserRecord();
  }

  Future<void> fetchUserRecord() async {
    try {
      profileLoading.value = true;
      final user = await userRepo.fetchUserDetails();
      this.user(user);
      profileLoading.value = false;
    } catch (e) {
      user(UserModel.empty());
    }
  }

  Future<void> saveUserRecord(UserCredential? userCredentials) async {
    try {
      if (userCredentials != null) {
        final username = userCredentials.user!.displayName ?? "";
        final user = UserModel(
          id: userCredentials.user!.uid,
          username: username,
          email: userCredentials.user!.email ?? "",
        );

        await userRepo.saveUserRecord(user);
      }
    } catch (e) {
      Loaders.warningSnackBar(
          title: "Data not saved",
          message: "Something went wrong during the process");
    }
  }
}
