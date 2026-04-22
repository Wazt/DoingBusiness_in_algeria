import 'package:doingbusiness/core/configs/theme/app_colors.dart';
import 'package:doingbusiness/presentation/auth/controllers/authentication_repository.dart';
import 'package:doingbusiness/utils/error_mapper.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Delete-account screen.
/// Flow: intro → "Proceed" button → confirmation dialog → password prompt →
/// loading → deleteUserAccount() → returns to intro via AuthenticationRepository.
/// GDPR Article 17 compliant — Firebase Auth + Firestore /Users/{uid} doc
/// deletion are both performed by deleteUserAccount() in a single transaction.
class DeleteUserAccount extends StatelessWidget {
  DeleteUserAccount({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () => Get.back(),
                child: const Icon(Icons.arrow_back_ios_new_outlined),
              ),
              const SizedBox(height: 10),
              const Text(
                'Delete your account',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 10),
              const Text(
                "This is permanent. Your profile, saved articles, and "
                "notification preferences will be erased. We'll ask for your "
                "password to confirm it's really you.",
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 30),
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.warningOrange,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                    minimumSize: const Size(260, 60),
                  ),
                  onPressed: () => _confirmAndDelete(context),
                  child: const Text(
                    "Proceed",
                    style: TextStyle(
                      fontSize: 16,
                      letterSpacing: 1.1,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _confirmAndDelete(BuildContext context) async {
    // Step 1 — are you sure?
    final sure = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete your account?'),
        content: const Text(
          'This is permanent. All your data will be erased and cannot be '
          'recovered.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.dangerRed),
            child: const Text('Yes, delete'),
          ),
        ],
      ),
    );
    if (sure != true) return;

    // Step 2 — password prompt (reauth requirement).
    final password = await showDialog<String>(
      context: context,
      builder: (ctx) {
        final controller = TextEditingController();
        return AlertDialog(
          title: const Text('Confirm with your password'),
          content: TextField(
            controller: controller,
            obscureText: true,
            autofocus: true,
            decoration: const InputDecoration(hintText: 'Password'),
            onSubmitted: (v) => Navigator.pop(ctx, v),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, controller.text),
              style: TextButton.styleFrom(foregroundColor: AppColors.dangerRed),
              child: const Text('Delete account'),
            ),
          ],
        );
      },
    );
    if (password == null || password.isEmpty) return;

    // Step 3 — spinner + actual deletion.
    // Use Get.dialog so we can dismiss from the same context after the call.
    Get.dialog(
      const Center(child: CircularProgressIndicator()),
      barrierDismissible: false,
    );

    final email = FirebaseAuth.instance.currentUser?.email ?? '';
    try {
      await AuthenticationRepository.instance.deleteUserAccount(email, password);
      // deleteUserAccount() navigates to GetStartedPage; no need to pop
      // the spinner — GetX destroys the route stack.
    } catch (e) {
      // Dismiss spinner if still open.
      if (Get.isDialogOpen ?? false) Get.back();
      Get.snackbar(
        'Delete failed',
        ErrorMapper.toUserMessage(e),
        backgroundColor: AppColors.dangerRed.withOpacity(0.15),
        colorText: AppColors.dangerRed,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}
