import 'package:doingbusiness/presentation/admin/controllers/admin_add_linkedin_controller.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AdminAddLinkedInController.validateLinkedInUrl', () {
    final controller = AdminAddLinkedInController();

    test('rejects null and empty', () {
      expect(controller.validateLinkedInUrl(null), isNotNull);
      expect(controller.validateLinkedInUrl(''), isNotNull);
      expect(controller.validateLinkedInUrl('   '), isNotNull);
    });

    test('rejects non-HTTPS URLs', () {
      expect(
        controller.validateLinkedInUrl('http://linkedin.com/posts/abc'),
        isNotNull,
      );
    });

    test('rejects non-LinkedIn URLs', () {
      expect(
        controller.validateLinkedInUrl('https://twitter.com/user/status/123'),
        isNotNull,
      );
      expect(
        controller.validateLinkedInUrl('https://example.com'),
        isNotNull,
      );
    });

    test('rejects LinkedIn URLs without valid path', () {
      expect(
        controller.validateLinkedInUrl('https://linkedin.com/'),
        isNotNull,
      );
      expect(
        controller.validateLinkedInUrl('https://linkedin.com/in/someone'),
        isNotNull,
      );
    });

    test('accepts valid LinkedIn post URL', () {
      expect(
        controller.validateLinkedInUrl(
          'https://www.linkedin.com/posts/grant-thornton-algeria_investment-reform-activity-123',
        ),
        isNull,
      );
    });

    test('accepts pulse article URL', () {
      expect(
        controller.validateLinkedInUrl(
          'https://www.linkedin.com/pulse/algeria-investment-outlook-2025-john-doe',
        ),
        isNull,
      );
    });

    test('accepts feed update URL', () {
      expect(
        controller.validateLinkedInUrl(
          'https://www.linkedin.com/feed/update/urn:li:activity:123',
        ),
        isNull,
      );
    });

    test('accepts URL without www prefix', () {
      expect(
        controller.validateLinkedInUrl(
          'https://linkedin.com/posts/grant-thornton-algeria_xyz',
        ),
        isNull,
      );
    });
  });

  group('AdminAddLinkedInController.validateTitle', () {
    final controller = AdminAddLinkedInController();

    test('rejects empty', () {
      expect(controller.validateTitle(null), isNotNull);
      expect(controller.validateTitle(''), isNotNull);
      expect(controller.validateTitle('   '), isNotNull);
    });

    test('rejects too long', () {
      expect(controller.validateTitle('a' * 201), isNotNull);
    });

    test('accepts valid title', () {
      expect(
        controller.validateTitle('Algeria Investment Reform 2025'),
        isNull,
      );
      expect(controller.validateTitle('a' * 200), isNull);
    });
  });
}
