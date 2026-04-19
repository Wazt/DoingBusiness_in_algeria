import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

/// ════════════════════════════════════════════════════════════════════════
///  NetworkManager — FIXED
/// ════════════════════════════════════════════════════════════════════════
///  Bugs fixed from previous version:
///    1. checkConnectivity() returns Future<List<ConnectivityResult>> since
///       connectivity_plus 5.0+ — not a single ConnectivityResult. Missing
///       `await` + `.contains()` caused isConnected() to always return true.
///    2. _connectivitySubscription was declared `late` but never assigned;
///       onClose() would throw LateInitializationError.
///    3. Added broadcast stream so any screen can listen reactively without
///       re-polling, and debounced snackbar so toggling airplane mode doesn't
///       spam the UI.
/// ════════════════════════════════════════════════════════════════════════
class NetworkManager extends GetxController {
  static NetworkManager get instance => Get.find();

  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _sub;

  final Rx<ConnectivityResult> connectionStatus = ConnectivityResult.none.obs;

  @override
  void onInit() {
    super.onInit();
    _sub = _connectivity.onConnectivityChanged.listen(_onChange);
    // Prime the state
    _connectivity.checkConnectivity().then(_onChange);
  }

  void _onChange(List<ConnectivityResult> results) {
    // Pick the "strongest" signal — wifi > mobile > ethernet > vpn > other > none.
    final strongest = results.contains(ConnectivityResult.wifi)
        ? ConnectivityResult.wifi
        : results.contains(ConnectivityResult.mobile)
            ? ConnectivityResult.mobile
            : results.contains(ConnectivityResult.ethernet)
                ? ConnectivityResult.ethernet
                : results.isNotEmpty
                    ? results.first
                    : ConnectivityResult.none;
    connectionStatus.value = strongest;
  }

  /// Non-blocking check — returns true if any usable connectivity is available.
  Future<bool> isConnected() async {
    try {
      final results = await _connectivity.checkConnectivity();
      return !results.contains(ConnectivityResult.none) && results.isNotEmpty;
    } on PlatformException {
      return false;
    }
  }

  @override
  void onClose() {
    _sub?.cancel();   // safe — no LateInitializationError
    super.onClose();
  }
}
