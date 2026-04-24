import 'package:doingbusiness/core/routing/routing_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

/// A recording fake for tests — lets callers verify the correct
/// navigation method was invoked without needing a widget tree.
class FakeRoutingService implements RoutingService {
  final List<String> calls = [];
  String? lastEmail;

  @override
  void goToMain() => calls.add('main');

  @override
  void goToIntro() => calls.add('intro');

  @override
  void goToLogin() => calls.add('login');

  @override
  void goToEmailVerify({String? email}) {
    calls.add('verify');
    lastEmail = email;
  }
}

void main() {
  setUp(() => Get.reset());

  group('RoutingService · injection surface', () {
    test('FakeRoutingService can be registered via Get.put and found', () {
      final fake = FakeRoutingService();
      Get.put<RoutingService>(fake);
      expect(Get.find<RoutingService>(), same(fake));
    });

    test('goToMain is recorded', () {
      final fake = FakeRoutingService();
      Get.put<RoutingService>(fake);
      Get.find<RoutingService>().goToMain();
      expect(fake.calls, ['main']);
    });

    test('goToEmailVerify forwards email arg', () {
      final fake = FakeRoutingService();
      Get.put<RoutingService>(fake);
      Get.find<RoutingService>().goToEmailVerify(email: 'a@b.dz');
      expect(fake.calls, ['verify']);
      expect(fake.lastEmail, 'a@b.dz');
    });

    test('goToEmailVerify without email', () {
      final fake = FakeRoutingService();
      Get.put<RoutingService>(fake);
      Get.find<RoutingService>().goToEmailVerify();
      expect(fake.lastEmail, isNull);
    });

    test('RoutingService contract covers all four destinations', () {
      final fake = FakeRoutingService();
      Get.put<RoutingService>(fake);
      final r = Get.find<RoutingService>();
      r.goToMain();
      r.goToIntro();
      r.goToLogin();
      r.goToEmailVerify(email: 'x@y.dz');
      expect(fake.calls, ['main', 'intro', 'login', 'verify']);
    });
  });
}
