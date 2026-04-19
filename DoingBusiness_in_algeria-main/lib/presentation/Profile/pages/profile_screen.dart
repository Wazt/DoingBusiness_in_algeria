import 'package:doingbusiness/core/configs/theme/app_colors.dart';
import 'package:doingbusiness/data/repository/admin_repository.dart';
import 'package:doingbusiness/presentation/admin/pages/admin_add_linkedin_screen.dart';
import 'package:doingbusiness/presentation/Profile/controller/profile_controller.dart';
import 'package:doingbusiness/presentation/Profile/pages/change_password_screen.dart';
import 'package:doingbusiness/presentation/Profile/pages/delete_user_account.dart';
import 'package:doingbusiness/presentation/Profile/pages/update_font_page.dart';
import 'package:doingbusiness/presentation/Profile/widgets/info_widget.dart';
import 'package:doingbusiness/presentation/Profile/widgets/profile_bar.dart';
import 'package:doingbusiness/presentation/auth/controllers/authentication_repository.dart';
import 'package:doingbusiness/presentation/auth/controllers/user_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final userController = UserController.instance;
    final profileController = Get.put(ProfileController());
    return Scaffold(
        body: SingleChildScrollView(
      child: SafeArea(
        child: Padding(
            padding: EdgeInsets.all(size.width * 0.02),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Profile',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                SizedBox(
                  height: size.height * 0.05,
                ),
                Center(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: size.width * 0.17,
                        height: size.height * 0.07,
                        child: CircleAvatar(
                          backgroundColor: Colors.transparent,
                          backgroundImage:
                              AssetImage("assets/images/logo_gt.png"),
                        ),
                      ),
                      SizedBox(
                        height: size.height * 0.01,
                      ),
                      Container(
                        width: 200,
                        child: Text(
                          userController.user.value.username,
                          maxLines: 1,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              overflow: TextOverflow.ellipsis,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.1),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: size.height * 0.03,
                ),
                Center(child: ProfileAppBar()),
                SizedBox(
                  height: size.height * 0.03,
                ),
                Text(
                  'Account Settings',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  height: size.height * 0.01,
                ),
                InfoWidget(
                  widgetColor: AppColors.mediumGreen,
                  widgetIcon: Icons.email_rounded,
                  widgetText: userController.user.value.email,
                  widgetTitle: 'email',
                ),
                SizedBox(
                  height: size.height * 0.02,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    InfoWidget(
                      widgetColor: AppColors.warningOrange,
                      widgetIcon: Icons.lock_outline_rounded,
                      widgetText: "*********",
                      widgetTitle: 'Change password',
                    ),
                    GestureDetector(
                      onTap: () => Get.to(ChangePasswordScreen()),
                      child: Icon(
                        Icons.arrow_circle_right_rounded,
                        size: 30,
                      ),
                    )
                  ],
                ),
                SizedBox(
                  height: size.height * 0.02,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    InfoWidget(
                      widgetColor: AppColors.dangerRed,
                      widgetIcon: Icons.lock_outline_rounded,
                      widgetText: "miss out all the info",
                      widgetTitle: 'Delete your account',
                    ),
                    GestureDetector(
                      onTap: () {
                        Get.to(DeleteUserAccount());
                      },
                      child: Icon(
                        Icons.arrow_circle_right_rounded,
                        size: 30,
                      ),
                    )
                  ],
                ),
                SizedBox(
                  height: size.height * 0.03,
                ),
                Text(
                  'App Settings',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  height: size.height * 0.01,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Obx(
                      () => InfoWidget(
                        widgetColor: AppColors.primaryLight,
                        widgetIcon: Icons.light_mode,
                        widgetText: profileController.isDarkMode.value
                            ? 'Dark'
                            : 'Light',
                        widgetTitle: 'Screen Mode',
                      ),
                    ),
                    Obx(
                      () => CupertinoSwitch(
                        activeColor: AppColors.primaryDark,
                        value: profileController.isDarkMode.value,
                        onChanged: (value) {
                          profileController.isDarkMode.value = value;
                          debugPrint(value);
                          profileController.darkModeSwitch(value);
                        },
                      ),
                    )
                  ],
                ),
                SizedBox(
                  height: size.height * 0.02,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    InfoWidget(
                      widgetColor: AppColors.primaryLight,
                      widgetIcon: Icons.lock_outline_rounded,
                      widgetText: "enhance readability",
                      widgetTitle: 'Font Size',
                    ),
                    GestureDetector(
                      onTap: () {
                        Get.to(UpdateFontPage());
                      },
                      child: Icon(
                        Icons.change_circle_outlined,
                        size: 30,
                      ),
                    )
                  ],
                ),
                FutureBuilder<bool>(
                  future: Get.put(AdminRepository()).isCurrentUserAdmin(),
                  builder: (context, snapshot) {
                    if (snapshot.data != true) return const SizedBox.shrink();
                    return Padding(
                      padding: const EdgeInsets.only(top: 24, bottom: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Admin',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          ListTile(
                            leading: const Icon(Icons.add_link_rounded,
                                color: Color(0xFF0A66C2)),
                            title: const Text('Mirror a LinkedIn post'),
                            subtitle: const Text(
                                'Add a post from Grant Thornton Algeria'),
                            trailing: const Icon(
                                Icons.arrow_forward_ios_rounded,
                                size: 16),
                            onTap: () =>
                                Get.to(() => const AdminAddLinkedInScreen()),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                SizedBox(
                  height: 50,
                ),
                Center(
                  child: ElevatedButton(
                    onPressed: () => AuthenticationRepository.instance.logout(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.dangerRed,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5)),
                      minimumSize: const Size(260, 60),
                    ),
                    child: Text(
                      'logout',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                )
              ],
            )),
      ),
    ));
  }
}
