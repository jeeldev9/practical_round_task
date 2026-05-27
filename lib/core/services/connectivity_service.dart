import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';
import 'sync_service.dart';

class ConnectivityService extends GetxService {
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<List<ConnectivityResult>> _subscription;

  final RxBool isConnected = true.obs;

  @override
  void onInit() {
    super.onInit();
    _checkInitialConnection();
    _subscription = _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
  }

  Future<void> _checkInitialConnection() async {
    try {
      final List<ConnectivityResult> results = await _connectivity.checkConnectivity();
      _updateStatus(results);
    } catch (_) {
      isConnected.value = false;
    }
  }

  void _updateConnectionStatus(List<ConnectivityResult> results) {
    _updateStatus(results);
  }

  void _updateStatus(List<ConnectivityResult> results) {
    final bool currentlyConnected = results.isNotEmpty && !results.contains(ConnectivityResult.none);
    final bool wasDisconnected = !isConnected.value;

    isConnected.value = currentlyConnected;

    if (currentlyConnected && wasDisconnected) {
      try {
        final syncService = Get.find<SyncService>();
        syncService.syncPendingActions();
      } catch (_) {
        // SyncService might not be registered yet
      }
    }
  }

  @override
  void onClose() {
    _subscription.cancel();
    super.onClose();
  }
}
