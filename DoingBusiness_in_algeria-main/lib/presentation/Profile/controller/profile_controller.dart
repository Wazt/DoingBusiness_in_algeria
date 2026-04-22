import 'package:doingbusiness/core/configs/theme/app_theme.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

/// Profile-scope settings (dark mode, etc.).
///
/// Storage backend unified on [GetStorage] to match [SavedController] and
/// [ArticleController] (was previously using the async [SharedPreferences]
/// for the same single-bool preference — see audit V3 §05 MEDIUM).
class ProfileController extends GetxController {
  static ProfileController get instance => Get.find();

  static const _storageKey = 'isDarkMode';

  final RxBool isDarkMode = false.obs;
  final GetStorage _storage = GetStorage();

  @override
  void onInit() {
    super.onInit();
    isDarkMode.value = _storage.read<bool>(_storageKey) ?? false;
  }

  Future<void> darkModeSwitch(bool value) async {
    isDarkMode.value = value;
    Get.changeTheme(value ? AppTheme.dark() : AppTheme.light());
    await _storage.write(_storageKey, value);
  }

  // NOTE: Delete-account flow lives in
  // lib/presentation/Profile/pages/delete_user_account.dart — it shows a
  // password dialog and calls AuthenticationRepository.deleteUserAccount(...).
}
