import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_social_chat/presentation/blocs/connectivity/connectivity_state.dart';
import 'package:flutter/foundation.dart';

/// Cubit that manages the device's connectivity state
class ConnectivityCubit extends Cubit<ConnectivityState> {
  /// Creates a new instance and initializes connectivity monitoring
  ConnectivityCubit() : super(ConnectivityState.empty()) {
    _initConnectivity();
  }

  late final StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;
  final Connectivity _connectivity = Connectivity();

  /// Initialize the connectivity monitoring
  Future<void> _initConnectivity() async {
    try {
      // Check initial connectivity
      final initialResults = await _connectivity.checkConnectivity();
      _onConnectivityChanged(initialResults);

      // Setup listener for connectivity changes
      _connectivitySubscription = _connectivity.onConnectivityChanged.listen(_onConnectivityChanged);
    } catch (e) {
      debugPrint('Error initializing connectivity monitoring: $e');
      emit(state.copyWith(isUserConnectedToTheInternet: false));
    }
  }

  /// Handle connectivity change events
  void _onConnectivityChanged(List<ConnectivityResult> results) {
    final isConnected = results.any((result) => result != ConnectivityResult.none);
    emit(state.copyWith(isUserConnectedToTheInternet: isConnected));
  }

  /// Cancels the connectivity subscription when the cubit is closed
  @override
  Future<void> close() async {
    await _connectivitySubscription.cancel();
    return super.close();
  }
}
