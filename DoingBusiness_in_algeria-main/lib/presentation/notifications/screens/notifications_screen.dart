import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Placeholder — the notifications list is wired through FCM/local plugins
/// elsewhere. This screen stays as a simple entry point until we add the
/// per-user notification history.
class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Notifications',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            height: 1.02,
            fontSize: 22,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: GestureDetector(
              onTap: () => Get.to(const NotificationsScreen()),
              child: const Icon(Icons.settings_outlined),
            ),
          ),
        ],
      ),
      body: const Center(
        child: Text('No notifications yet.'),
      ),
    );
  }
}
