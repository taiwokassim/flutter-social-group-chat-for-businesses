import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_social_chat/core/interfaces/i_connectivity_repository.dart';

/// Implementation of the connectivity repository using the connectivity_plus package.
/// 
/// This repository:
/// - Abstracts away the complexity of handling connectivity changes
/// - Provides simplified, prioritized connectivity status
/// - Handles error cases gracefully
class ConnectivityRepository implements IConnectivityRepository {
  /// Instance of the connectivity service from the package
  final Connectivity _connectivity;

  /// Creates a new connectivity repository
  /// 
  /// [_connectivity] is injected to allow for better testability
  ConnectivityRepository(this._connectivity);

  @override
  Stream<ConnectivityResult> get connectivityStateChanges {
    try {
      // The connectivity_plus package returns multiple connectivity types
      // We transform this into a single, prioritized result
      return _connectivity.onConnectivityChanged.map(_extractSingleResult);
    } catch (e) {
      debugPrint('Error monitoring connectivity changes: $e');
      return Stream.value(ConnectivityResult.none);
    }
  }
  
  @override
  Future<ConnectivityResult> checkConnectivity() async {
    try {
      // Get the current connectivity state (could be multiple results)
      final results = await _connectivity.checkConnectivity();
      return _extractSingleResult(results);
    } catch (e) {
      debugPrint('Error checking current connectivity: $e');
      return ConnectivityResult.none;
    }
  }
  
  /// Extracts a single ConnectivityResult from a list of connectivity results
  /// based on the following priority order:
  /// 1. Mobile data (most reliable for mobile apps)
  /// 2. WiFi connection
  /// 3. Ethernet connection
  /// 4. Bluetooth connection
  /// 5. Any other available connection
  /// 6. No connection (fallback)
  ConnectivityResult _extractSingleResult(List<ConnectivityResult> results) {
    if (results.contains(ConnectivityResult.mobile)) {
      return ConnectivityResult.mobile;
    } 
    else if (results.contains(ConnectivityResult.wifi)) {
      return ConnectivityResult.wifi;
    }
    else if (results.contains(ConnectivityResult.ethernet)) {
      return ConnectivityResult.ethernet;
    }
    else if (results.contains(ConnectivityResult.bluetooth)) {
      return ConnectivityResult.bluetooth;
    }
    else if (results.isNotEmpty) {
      return results.first;
    } 
    else {
      return ConnectivityResult.none;
    }
  }
}
