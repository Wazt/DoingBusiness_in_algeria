import 'package:doingbusiness/presentation/Home/pages/home_screen.dart';
import 'package:doingbusiness/presentation/MainWrapper/controllers/mainwrapper_controller.dart';
import 'package:doingbusiness/presentation/MainWrapper/widgets/editorial_bottom_nav.dart';
import 'package:doingbusiness/presentation/Profile/pages/profile_screen.dart';
import 'package:doingbusiness/presentation/chatbot/pages/chatbot_screen.dart';
import 'package:doingbusiness/presentation/explorer/pages/explorer_screen.dart';
import 'package:doingbusiness/presentation/saved/pages/saved_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// MainWrapper with the editorial bottom nav: 4 tabs + center purple AI FAB.
/// FAB opens the chatbot as a bottom sheet-style full-screen modal.
class MainWrapper extends StatelessWidget {
  MainWrapper({super.key});

  final MainWrapperController controller = Get.put(MainWrapperController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() => IndexedStack(
            index: controller.currentPage.value,
            children: const [
              HomeScreen(),
              ExplorerScreen(),
              SavedScreen(),
              ProfileScreen(),
            ],
          )),
      bottomNavigationBar: Obx(() => EditorialBottomNav(
            currentIndex: controller.currentPage.value,
            onTabTap: controller.goToTab,
            onAskAiTap: () => _openChatbot(context),
          )),
    );
  }

  void _openChatbot(BuildContext context) {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierColor: Colors.black54,
        transitionDuration: const Duration(milliseconds: 260),
        reverseTransitionDuration: const Duration(milliseconds: 180),
        pageBuilder: (_, __, ___) => const ChatbotScreen(),
        transitionsBuilder: (_, anim, __, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 1),
              end: Offset.zero,
            ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOutCubic)),
            child: child,
          );
        },
      ),
    );
  }
}
