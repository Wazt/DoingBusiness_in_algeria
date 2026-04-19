import 'package:get/get.dart';

class MainWrapperController extends GetxController {
  final RxInt currentPage = 0.obs;

  void goToTab(int index) => currentPage.value = index;
}
