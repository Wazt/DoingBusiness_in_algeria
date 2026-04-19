import 'package:doingbusiness/core/configs/theme/app_colors.dart';
import 'package:doingbusiness/presentation/Home/pages/home_screen.dart';
import 'package:doingbusiness/presentation/MainWrapper/controllers/mainwrapper_controller.dart';
import 'package:doingbusiness/presentation/Profile/controller/profile_controller.dart';
import 'package:doingbusiness/presentation/Profile/pages/profile_screen.dart';
import 'package:doingbusiness/presentation/explorer/pages/explorer_screen.dart';
import 'package:doingbusiness/presentation/saved/pages/saved_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:doingbusiness/core/configs/theme/app_theme.dart';
import 'package:get/get.dart';

class MainWrapper extends StatelessWidget {
  MainWrapper({super.key});

  final MainWrapperController controller = Get.put(MainWrapperController());

  @override
  Widget build(BuildContext context) {
    final profileController = Get.put(ProfileController());
    return Scaffold(
        extendBody: true,
        body: PageView(
          onPageChanged: controller.animateToTab,
          controller: controller.pageController,
          physics: const NeverScrollableScrollPhysics(),
          children: const [
            HomeScreen(),
            ExplorerScreen(),
            //SavedScreen(),
            ProfileScreen()
          ],
        ),
        bottomNavigationBar: SafeArea(
          child: Obx(
            () => Container(
                margin: EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        offset: Offset(0, 20),
                        blurRadius: 10)
                  ],
                  color: profileController.isDarkMode.value
                      ? Color.fromARGB(255, 85, 3, 120)
                      : Colors.white,
                  borderRadius: BorderRadius.all(
                    Radius.circular(20),
                  ),
                ),
                child: Obx(
                  () => Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _bottomAppBarItem(context,
                          icon: Icons.home_outlined, page: 0, label: "Home"),
                      _bottomAppBarItem(context,
                          icon: Icons.gps_fixed_outlined,
                          page: 1,
                          label: "Discover"),
                      /*_bottomAppBarItem(context,
                          icon: Icons.bookmark, page: 2, label: "Saved"),*/
                      _bottomAppBarItem(context,
                          icon: Icons.person_outline_outlined,
                          page: 2,
                          label: "Profile"),
                    ],
                  ),
                )),
          ),
        ));
  }

  /*BottomAppBar(
        color: Colors.white10,
        elevation: 0,
        notchMargin: 5,
        height: 85,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 35, vertical: 5),
          child: Obx(
            () => Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _bottomAppBarItem(context,
                    icon: Icons.home_outlined, page: 0, label: "Home"),
                _bottomAppBarItem(context,
                    icon: Icons.gps_fixed_outlined, page: 1, label: "Discover"),
                _bottomAppBarItem(context,
                    icon: Icons.person_outline_outlined,
                    page: 2,
                    label: "Profile"),
              ],
            ),
          ),
        ),
      ), */

  Widget _bottomAppBarItem(BuildContext context,
      {required icon, required page, required label}) {
    return GestureDetector(
      onTap: () => controller.goToTab(page),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: controller.currentPage.value == page
                ? Colors.purple
                : Colors.grey,
            size: controller.currentPage.value == page ? 25 : 18,
          ),
          SizedBox(
            height: 3,
          ),
          Text(
            label,
            style: TextStyle(
              color: controller.currentPage.value == page
                  ? AppColors.primaryDark
                  : Colors.grey,
              fontSize: controller.currentPage.value == page ? 11 : 9,
            ),
          ),
        ],
      ),
    );
  }
}
