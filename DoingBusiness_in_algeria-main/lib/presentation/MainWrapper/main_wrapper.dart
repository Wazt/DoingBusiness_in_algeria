import 'package:doingbusiness/presentation/Home/pages/home_screen.dart';
import 'package:doingbusiness/presentation/MainWrapper/controllers/mainwrapper_controller.dart';
import 'package:doingbusiness/presentation/Profile/pages/profile_screen.dart';
import 'package:doingbusiness/presentation/explorer/pages/explorer_screen.dart';
import 'package:doingbusiness/presentation/saved/pages/saved_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// ════════════════════════════════════════════════════════════════════════
///  MainWrapper — REDESIGNED
/// ════════════════════════════════════════════════════════════════════════
///  Changes:
///    ✔ Uses Material 3 NavigationBar (respects theme, built-in a11y,
///      proper selected/unselected states)
///    ✔ Saved tab RE-ENABLED (was commented out — orphan state bug)
///    ✔ "Discover" typo fixed ("Dsicover" → "Discover")
///    ✔ IndexedStack preserves scroll position across tab switches
///    ✔ No more manual colored Container bottom bar
/// ════════════════════════════════════════════════════════════════════════
class MainWrapper extends StatelessWidget {
  MainWrapper({super.key});

  final MainWrapperController controller = Get.put(MainWrapperController());

  static const _tabs = [
    _NavTab(icon: Icons.home_outlined,       selected: Icons.home_rounded,       label: 'Home'),
    _NavTab(icon: Icons.explore_outlined,    selected: Icons.explore_rounded,    label: 'Discover'),
    _NavTab(icon: Icons.bookmark_outline,    selected: Icons.bookmark_rounded,   label: 'Saved'),
    _NavTab(icon: Icons.person_outline,      selected: Icons.person_rounded,     label: 'Profile'),
  ];

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
      bottomNavigationBar: Obx(() => NavigationBar(
            selectedIndex: controller.currentPage.value,
            onDestinationSelected: controller.goToTab,
            destinations: _tabs
                .map((t) => NavigationDestination(
                      icon: Icon(t.icon),
                      selectedIcon: Icon(t.selected),
                      label: t.label,
                      tooltip: t.label,
                    ))
                .toList(),
          )),
    );
  }
}

class _NavTab {
  final IconData icon;
  final IconData selected;
  final String   label;
  const _NavTab({required this.icon, required this.selected, required this.label});
}
