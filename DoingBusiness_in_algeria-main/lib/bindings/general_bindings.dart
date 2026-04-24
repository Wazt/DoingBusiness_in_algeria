import 'package:doingbusiness/core/routing/routing_service.dart';
import 'package:doingbusiness/utils/Network/network_manager.dart';
import 'package:get/get.dart';

class GeneralBindings extends Bindings {
  @override
  void dependencies() {
    // Routing port — AuthenticationRepository depends on this, so it must
    // be registered before any code calls Get.find<RoutingService>().
    // Keep this as the first registration in the list.
    if (!Get.isRegistered<RoutingService>()) {
      Get.put<RoutingService>(GetxRoutingService(), permanent: true);
    }

    Get.put(NetworkManager());
  }
}
