import 'package:connectivity_plus/connectivity_plus.dart';

/// Provides an abstraction for device connectivity state handling
abstract class IConnectivityRepository {
  /// Stream that emits connectivity status changes
  /// 
  /// Possible values are:
  /// - ConnectivityResult.wifi
  /// - ConnectivityResult.mobile
  /// - ConnectivityResult.none
  Stream<ConnectivityResult> get connectivityStateChanges;
  
  /// Checks the current connectivity status
  /// 
  /// Returns the current connectivity status synchronously
  Future<ConnectivityResult> checkConnectivity();
}
