import 'dart:ui';

import 'package:doingbusiness/core/configs/theme/app_colors.dart';
import 'package:doingbusiness/presentation/auth/controllers/email_verification_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class EmailVerificationScreen extends StatelessWidget {
  const EmailVerificationScreen({super.key, this.email});
  final String? email;

  Widget build(BuildContext context) {
    final controller = Get.put(EmailVerificationController());
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                fit: BoxFit.cover,
                image: AssetImage(
                  "assets/images/3d_bg.jpg",
                ),
              ),
            ),
          ),
          Container(
            color: Colors.black.withOpacity(0.5),
          ),
          Padding(
            padding: EdgeInsets.symmetric(
              vertical: size.height * 0.08,
              horizontal: size.width * 0.08,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Align(
                  alignment: Alignment.topLeft,
                  child: Row(
                    children: [
                      Image(
                        image: const AssetImage('assets/images/logo_gt.png'),
                        height: size.width * 0.1,
                      ),
                      SizedBox(
                        width: size.width * 0.01,
                      ),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Welcome to",
                            style: TextStyle(
                              fontWeight: FontWeight.w400,
                              color: Colors.white,
                              height: 1.02,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            "Doing Business",
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              height: 1.02,
                              fontSize: 20,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: size.height * 0.18,
                ),
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: BackdropFilter(
                    filter: new ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                    child: Container(
                      width: 400,
                      height: 500,
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Text(
                            "Congratulations",
                            style: TextStyle(
                              fontWeight: FontWeight.w200,
                              color: Colors.white,
                              height: 1.02,
                              fontSize: 25,
                            ),
                          ),
                          const Text(
                            "Please, Verify your email address",
                            style: TextStyle(
                              fontWeight: FontWeight.w300,
                              color: Colors.white,
                              height: 1.02,
                              fontSize: 35,
                            ),
                          ),
                          SizedBox(
                            height: size.height * 0.05,
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryDark,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5)),
                              minimumSize: const Size(260, 60),
                            ),
                            onPressed: () {
                              controller.checkEmailVerificationStatus();
                            },
                            child: const Text(
                              "Continue",
                              style: TextStyle(
                                  fontSize: 16,
                                  letterSpacing: 1.1,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500),
                            ),
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          GestureDetector(
                            onTap: () {
                              controller.sendEmailVerification();
                            },
                            child: Text(
                              "Resend email",
                              style: TextStyle(
                                fontWeight: FontWeight.w200,
                                color: Colors.white,
                                height: 1.02,
                                fontSize: 25,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
