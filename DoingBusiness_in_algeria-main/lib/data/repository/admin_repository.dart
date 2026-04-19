import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

/// ════════════════════════════════════════════════════════════════════════
///  AdminRepository — admin-only operations
/// ════════════════════════════════════════════════════════════════════════
///  All methods here route through Cloud Functions with server-side
///  enforcement of the `admin` custom claim.
///
///  Admin claim is granted via Firebase Admin SDK:
///    await admin.auth().setCustomUserClaims(uid, { admin: true });
///
///  The user must RE-LOGIN after the claim is granted for it to take effect
///  in their ID token. Alternatively force-refresh via:
///    await user.getIdToken(true);
/// ════════════════════════════════════════════════════════════════════════

class AdminRepository extends GetxController {
  static AdminRepository get instance => Get.find();

  // Must match the region used in functions/src/linkedin.ts
  static const _region = 'europe-west1';

  final FirebaseFunctions _functions = FirebaseFunctions.instanceFor(region: _region);

  // ─── Admin check ─────────────────────────────────────────────────────

  /// Returns true if the current user has the `admin` custom claim.
  /// Pass [forceRefresh] = true after a user has just been granted admin,
  /// to bypass the cached token.
  Future<bool> isCurrentUserAdmin({bool forceRefresh = false}) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;

    try {
      final result = await user.getIdTokenResult(forceRefresh);
      final admin = result.claims?['admin'];
      return admin == true;
    } catch (_) {
      return false;
    }
  }

  // ─── LinkedIn preview + publish ──────────────────────────────────────

  Future<LinkedInPreview> previewLinkedInArticle(String url) async {
    try {
      final callable = _functions.httpsCallable('previewLinkedInArticle');
      final result = await callable.call<Map<String, dynamic>>({'url': url});
      return LinkedInPreview.fromJson(result.data);
    } on FirebaseFunctionsException catch (e) {
      throw _mapFunctionsException(e);
    }
  }

  Future<String> createLinkedInArticle({
    required String url,
    String? categoryId,
    String? overrideTitle,
    String? overrideDescription,
    String? overrideImageUrl,
  }) async {
    try {
      final callable = _functions.httpsCallable('createLinkedInArticle');
      final result = await callable.call<Map<String, dynamic>>({
        'url': url,
        if (categoryId != null && categoryId.isNotEmpty) 'categoryId': categoryId,
        if (overrideTitle != null && overrideTitle.isNotEmpty)
          'overrideTitle': overrideTitle,
        if (overrideDescription != null && overrideDescription.isNotEmpty)
          'overrideDescription': overrideDescription,
        if (overrideImageUrl != null && overrideImageUrl.isNotEmpty)
          'overrideImageUrl': overrideImageUrl,
      });
      return result.data['articleId'] as String;
    } on FirebaseFunctionsException catch (e) {
      throw _mapFunctionsException(e);
    }
  }

  // ─── Error mapping — never expose raw FirebaseFunctionsException to UI ─

  String _mapFunctionsException(FirebaseFunctionsException e) {
    switch (e.code) {
      case 'unauthenticated':
        return 'Please sign in again.';
      case 'permission-denied':
        return e.message ?? 'Admin privileges required.';
      case 'invalid-argument':
        return e.message ?? 'The URL is not valid.';
      case 'unavailable':
        return e.message ?? 'Could not reach LinkedIn. Please try again.';
      case 'resource-exhausted':
        return e.message ?? 'Please wait before publishing another post.';
      case 'already-exists':
        return 'This LinkedIn post is already in the feed.';
      default:
        return e.message ?? 'Something went wrong. Please try again.';
    }
  }
}

// ─── Preview DTO ────────────────────────────────────────────────────────

class LinkedInPreview {
  final String title;
  final String description;
  final String? imageUrl;
  final String? author;

  const LinkedInPreview({
    required this.title,
    required this.description,
    this.imageUrl,
    this.author,
  });

  factory LinkedInPreview.fromJson(Map<String, dynamic> json) => LinkedInPreview(
        title: json['title'] as String? ?? '',
        description: json['description'] as String? ?? '',
        imageUrl: json['imageUrl'] as String?,
        author: json['author'] as String?,
      );
}
