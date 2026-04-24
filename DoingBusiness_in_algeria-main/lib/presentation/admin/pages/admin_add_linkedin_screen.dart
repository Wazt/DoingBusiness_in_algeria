import 'package:cached_network_image/cached_network_image.dart';
import 'package:doingbusiness/core/configs/theme/app_spacing.dart';
import 'package:doingbusiness/presentation/Article/controllers/category_controller.dart';
import 'package:doingbusiness/presentation/admin/controllers/admin_add_linkedin_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

/// ════════════════════════════════════════════════════════════════════════
///  AdminAddLinkedInScreen — mirror a LinkedIn post into the app
/// ════════════════════════════════════════════════════════════════════════
///  2-step wizard:
///    1. Paste URL → preview
///    2. Review auto-extracted content, optionally edit, publish
///
///  Only visible to users with the `admin` custom claim (gated by
///  ProfileScreen before navigation).
/// ════════════════════════════════════════════════════════════════════════

class AdminAddLinkedInScreen extends StatelessWidget {
  const AdminAddLinkedInScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AdminAddLinkedInController());

    return Scaffold(
      appBar: AppBar(
        title: Obx(() => Text(
              controller.step.value == AdminAddStep.enterUrl
                  ? 'Mirror LinkedIn post'
                  : 'Review & publish',
            )),
        leading: IconButton(
          icon: const Icon(Icons.close),
          tooltip: 'Cancel',
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(
        () => switch (controller.step.value) {
          AdminAddStep.enterUrl => _Step1EnterUrl(controller: controller),
          AdminAddStep.reviewAndPublish => _Step2Review(controller: controller),
        },
      ),
    );
  }
}

// ─── Step 1: paste URL ──────────────────────────────────────────────────

class _Step1EnterUrl extends StatelessWidget {
  final AdminAddLinkedInController controller;
  const _Step1EnterUrl({required this.controller});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Form(
          key: controller.step1FormKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ─── Header ───
              Row(
                children: [
                  _LinkedInIcon(size: 32),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Text(
                      'Add a LinkedIn post',
                      style: theme.textTheme.headlineSmall,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'Paste the URL of a LinkedIn post from Grant Thornton Algeria\'s '
                'page. The app will mirror it to the feed with a link back to '
                'the original.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
              ),

              const SizedBox(height: AppSpacing.huge),

              // ─── URL field ───
              TextFormField(
                controller: controller.urlController,
                validator: controller.validateLinkedInUrl,
                keyboardType: TextInputType.url,
                textInputAction: TextInputAction.done,
                autocorrect: false,
                enableSuggestions: false,
                maxLines: 2,
                minLines: 1,
                decoration: const InputDecoration(
                  labelText: 'LinkedIn URL',
                  hintText: 'https://www.linkedin.com/posts/...',
                  prefixIcon: Icon(Icons.link_rounded),
                ),
                onFieldSubmitted: (_) => controller.fetchPreview(),
              ),

              const SizedBox(height: AppSpacing.md),

              // ─── Paste button (convenience) ───
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: () async {
                    final data = await Clipboard.getData(Clipboard.kTextPlain);
                    if (data?.text != null) {
                      controller.urlController.text = data!.text!.trim();
                    }
                  },
                  icon: const Icon(Icons.content_paste_rounded, size: 18),
                  label: const Text('Paste from clipboard'),
                ),
              ),

              const SizedBox(height: AppSpacing.xxl),

              // ─── Fetch preview button ───
              Obx(() => ElevatedButton.icon(
                    onPressed: controller.isLoadingPreview.value
                        ? null
                        : controller.fetchPreview,
                    icon: controller.isLoadingPreview.value
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.4,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.search_rounded),
                    label: Text(
                      controller.isLoadingPreview.value
                          ? 'Fetching preview...'
                          : 'Fetch preview',
                    ),
                  )),

              const SizedBox(height: AppSpacing.huge),

              // ─── Info box ───
              Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  border: Border.all(color: theme.colorScheme.outline),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline_rounded,
                            color: theme.colorScheme.primary, size: 20),
                        const SizedBox(width: AppSpacing.sm),
                        Text(
                          'How mirroring works',
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    _InfoBullet(text: 'We fetch the post\'s title, description, and thumbnail.'),
                    _InfoBullet(text: 'You can edit any field before publishing.'),
                    _InfoBullet(text: 'Readers will see a "Open on LinkedIn" button to view the original.'),
                    _InfoBullet(text: 'No automatic sync — each post must be added manually for now.'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Step 2: review & publish ───────────────────────────────────────────

class _Step2Review extends StatelessWidget {
  final AdminAddLinkedInController controller;
  const _Step2Review({required this.controller});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final categoryController = Get.put(CategoryController());

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Form(
          key: controller.step2FormKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ─── Preview card (read-only) ───
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  border: Border.all(color: theme.colorScheme.outline),
                ),
                child: Row(
                  children: [
                    _LinkedInIcon(size: 20),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        controller.urlController.text,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontFamily: 'monospace',
                          color: theme.colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: controller.goBackToStep1,
                      child: const Text('Change'),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.xxl),

              // ─── Thumbnail preview ───
              Obx(() {
                final imageUrl = controller.imageUrlController.text;
                if (imageUrl.isEmpty) {
                  return Container(
                    height: 160,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                      border: Border.all(color: theme.colorScheme.outline),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.image_outlined,
                              size: 36,
                              color: theme.colorScheme.onSurface.withOpacity(0.3)),
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            'No thumbnail',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface.withOpacity(0.5),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                return ClipRRect(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: CachedNetworkImage(
                      imageUrl: imageUrl,
                      fit: BoxFit.cover,
                      errorWidget: (_, __, ___) => Container(
                        color: theme.colorScheme.surfaceContainerHighest,
                        child: const Center(child: Icon(Icons.broken_image)),
                      ),
                    ),
                  ),
                );
              }),

              const SizedBox(height: AppSpacing.xxl),

              // ─── Title (editable) ───
              TextFormField(
                controller: controller.titleController,
                validator: controller.validateTitle,
                textCapitalization: TextCapitalization.sentences,
                maxLines: 2,
                minLines: 1,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  helperText: 'Auto-extracted. You can override.',
                ),
              ),

              const SizedBox(height: AppSpacing.lg),

              // ─── Description (editable) ───
              TextFormField(
                controller: controller.descriptionController,
                textCapitalization: TextCapitalization.sentences,
                maxLines: 6,
                minLines: 3,
                maxLength: 5000,
                decoration: const InputDecoration(
                  labelText: 'Description / excerpt',
                  helperText: 'This appears below the title in the feed.',
                  alignLabelWithHint: true,
                ),
              ),

              const SizedBox(height: AppSpacing.lg),

              // ─── Image URL (editable) ───
              TextFormField(
                controller: controller.imageUrlController,
                keyboardType: TextInputType.url,
                autocorrect: false,
                maxLines: 2,
                minLines: 1,
                decoration: const InputDecoration(
                  labelText: 'Thumbnail URL',
                  helperText: 'Paste a direct image URL to override.',
                  prefixIcon: Icon(Icons.image_outlined),
                ),
                onChanged: (_) {
                  // trigger rebuild of thumbnail preview
                  controller.imageUrlController.notifyListeners();
                },
              ),

              const SizedBox(height: AppSpacing.lg),

              // ─── Category picker ───
              Obx(() {
                if (categoryController.allCategories.isEmpty) {
                  return const SizedBox.shrink();
                }
                return DropdownButtonFormField<String>(
                  value: controller.selectedCategoryId.value.isEmpty
                      ? null
                      : controller.selectedCategoryId.value,
                  items: [
                    const DropdownMenuItem<String>(
                      value: '',
                      child: Text('— No category —'),
                    ),
                    ...categoryController.allCategories.map((c) => DropdownMenuItem<String>(
                          value: c.id.toString(),
                          child: Text(c.name),
                        )),
                  ],
                  onChanged: (v) => controller.selectedCategoryId.value = v ?? '',
                  decoration: const InputDecoration(
                    labelText: 'Category (optional)',
                    prefixIcon: Icon(Icons.folder_outlined),
                  ),
                );
              }),

              const SizedBox(height: AppSpacing.huge),

              // ─── Publish button ───
              Obx(() => ElevatedButton.icon(
                    onPressed: controller.isPublishing.value ? null : controller.publish,
                    icon: controller.isPublishing.value
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.4,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.publish_rounded),
                    label: Text(
                      controller.isPublishing.value ? 'Publishing...' : 'Publish to feed',
                    ),
                  )),

              const SizedBox(height: AppSpacing.md),

              // ─── Back to step 1 ───
              TextButton.icon(
                onPressed: controller.goBackToStep1,
                icon: const Icon(Icons.arrow_back_rounded),
                label: const Text('Use a different URL'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Helpers ────────────────────────────────────────────────────────────

class _InfoBullet extends StatelessWidget {
  final String text;
  const _InfoBullet({required this.text});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('• ', style: theme.textTheme.bodyMedium),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.8),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LinkedInIcon extends StatelessWidget {
  final double size;
  const _LinkedInIcon({this.size = 20});

  @override
  Widget build(BuildContext context) {
    // Inline LinkedIn glyph in their brand color (#0A66C2)
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: const Color(0xFF0A66C2),
        borderRadius: BorderRadius.circular(4),
      ),
      alignment: Alignment.center,
      child: Text(
        'in',
        style: TextStyle(
          color: Colors.white,
          fontSize: size * 0.55,
          fontWeight: FontWeight.w900,
          fontStyle: FontStyle.italic,
        ),
      ),
    );
  }
}
