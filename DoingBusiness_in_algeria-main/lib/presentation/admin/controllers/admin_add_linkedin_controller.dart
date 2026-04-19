import 'package:doingbusiness/data/repository/admin_repository.dart';
import 'package:doingbusiness/presentation/Article/controllers/article_controller.dart';
import 'package:doingbusiness/utils/loaders/loaders.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// ════════════════════════════════════════════════════════════════════════
///  AdminAddLinkedInController
/// ════════════════════════════════════════════════════════════════════════
///  Drives the 2-step wizard:
///    Step 1 — paste URL, fetch preview
///    Step 2 — review auto-extracted title/description/image, optionally
///             override, pick category, publish
/// ════════════════════════════════════════════════════════════════════════

enum AdminAddStep { enterUrl, reviewAndPublish }

class AdminAddLinkedInController extends GetxController {
  static AdminAddLinkedInController get instance => Get.find();

  // ─── Step tracking ─────────────────────────────────────────────────
  final Rx<AdminAddStep> step = AdminAddStep.enterUrl.obs;

  // ─── Step 1 state ──────────────────────────────────────────────────
  final GlobalKey<FormState> step1FormKey = GlobalKey<FormState>();
  final TextEditingController urlController = TextEditingController();
  final RxBool isLoadingPreview = false.obs;

  // ─── Preview result (between steps) ────────────────────────────────
  final Rx<LinkedInPreview?> preview = Rx<LinkedInPreview?>(null);

  // ─── Step 2 state ──────────────────────────────────────────────────
  final GlobalKey<FormState> step2FormKey = GlobalKey<FormState>();
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController imageUrlController = TextEditingController();
  final RxString selectedCategoryId = ''.obs;
  final RxBool isPublishing = false.obs;

  // ─── Validators ────────────────────────────────────────────────────

  String? validateLinkedInUrl(String? v) {
    if (v == null || v.trim().isEmpty) return 'LinkedIn URL is required';
    final url = v.trim();
    if (!url.startsWith('https://')) return 'URL must start with https://';
    if (!url.contains('linkedin.com/')) return 'Must be a linkedin.com URL';
    // Accepted paths: /posts/, /pulse/, /feed/update/
    final hasValidPath = url.contains('/posts/') ||
        url.contains('/pulse/') ||
        url.contains('/feed/update/');
    if (!hasValidPath) {
      return 'URL must be a post, pulse article, or feed update';
    }
    return null;
  }

  String? validateTitle(String? v) {
    if (v == null || v.trim().isEmpty) return 'Title is required';
    if (v.length > 200) return 'Title must be 200 characters or fewer';
    return null;
  }

  // ─── Actions ───────────────────────────────────────────────────────

  Future<void> fetchPreview() async {
    if (!step1FormKey.currentState!.validate()) return;

    isLoadingPreview.value = true;
    try {
      final result = await AdminRepository.instance
          .previewLinkedInArticle(urlController.text.trim());

      preview.value = result;

      // Pre-fill the editable fields with auto-extracted values
      titleController.text = result.title;
      descriptionController.text = result.description;
      imageUrlController.text = result.imageUrl ?? '';

      step.value = AdminAddStep.reviewAndPublish;
    } catch (e) {
      Loaders.errorSnackBar(title: 'Could not fetch preview', message: e.toString());
    } finally {
      isLoadingPreview.value = false;
    }
  }

  Future<void> publish() async {
    if (!step2FormKey.currentState!.validate()) return;

    isPublishing.value = true;
    try {
      final articleId = await AdminRepository.instance.createLinkedInArticle(
        url: urlController.text.trim(),
        categoryId: selectedCategoryId.value.isEmpty ? null : selectedCategoryId.value,
        overrideTitle: titleController.text.trim(),
        overrideDescription: descriptionController.text.trim(),
        overrideImageUrl: imageUrlController.text.trim(),
      );

      Loaders.successSnackBar(
        title: 'Published',
        message: 'Article added to the feed.',
      );

      // Refresh home feed if the controller is around
      if (Get.isRegistered<ArticleController>()) {
        ArticleController.instance.fetchFeaturedArticles();
      }

      // Reset wizard and close screen
      _reset();
      Get.back<String>(result: articleId);
    } catch (e) {
      Loaders.errorSnackBar(title: 'Could not publish', message: e.toString());
    } finally {
      isPublishing.value = false;
    }
  }

  void goBackToStep1() {
    step.value = AdminAddStep.enterUrl;
  }

  void _reset() {
    urlController.clear();
    titleController.clear();
    descriptionController.clear();
    imageUrlController.clear();
    selectedCategoryId.value = '';
    preview.value = null;
    step.value = AdminAddStep.enterUrl;
  }

  @override
  void onClose() {
    urlController.dispose();
    titleController.dispose();
    descriptionController.dispose();
    imageUrlController.dispose();
    super.onClose();
  }
}
