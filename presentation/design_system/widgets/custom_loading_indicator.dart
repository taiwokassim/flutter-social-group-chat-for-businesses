import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_social_chat/presentation/design_system/colors.dart';

/// A customizable loading indicator that shows a semi-transparent overlay with a circular progress indicator.
///
/// This indicator blocks user interaction while displayed and can be shown/hidden programmatically.
/// It ensures only one indicator is shown at a time across the entire app.
class CustomLoadingIndicator {
  // Static variables to maintain global state
  static bool _isGloballyShowing = false;
  static Timer? _safetyTimer;
  static OverlayEntry? _overlayEntry;

  // Per-instance context
  final BuildContext _context;

  /// Private constructor for singleton pattern
  CustomLoadingIndicator._create(this._context);

  /// Factory constructor to create a loading indicator for the given context
  ///
  /// Always recreates the instance to ensure we have the latest context
  factory CustomLoadingIndicator.of(BuildContext context) {
    if (!context.mounted) {
      throw StateError('Cannot create CustomLoadingIndicator with unmounted context');
    }

    return CustomLoadingIndicator._create(context);
  }

  /// Shows the loading indicator
  void show() {
    // If already showing globally, don't show again
    if (_isGloballyShowing) return;

    if (!_context.mounted) return;

    try {
      // Set global flag
      _isGloballyShowing = true;

      // Cancel any existing safety timer
      _safetyTimer?.cancel();

      // Use overlay instead of dialog for more reliable cleanup
      _showOverlay();

      // Add safety timer to auto-hide after 15 seconds
      _safetyTimer = Timer(const Duration(seconds: 15), () {
        debugPrint('Global safety timer fired - force closing indicator');
        forceClose();
      });
    } catch (e) {
      debugPrint('Error showing loading indicator: $e');
      _isGloballyShowing = false;
    }
  }

  /// Shows the indicator using an overlay for more reliable cleanup
  void _showOverlay() {
    try {
      final overlay = Overlay.of(_context);

      // Remove any existing overlay first
      _removeOverlay();

      // Create and insert a new overlay
      _overlayEntry = OverlayEntry(
        builder: (context) => const LoadingIndicator(),
      );

      overlay.insert(_overlayEntry!);
    } catch (e) {
      debugPrint('Error showing overlay: $e');
    }
  }

  /// Removes the overlay entry
  static void _removeOverlay() {
    try {
      _overlayEntry?.remove();
      _overlayEntry = null;
    } catch (e) {
      debugPrint('Error removing overlay: $e');
    }
  }

  /// Hides the loading indicator if it's showing
  void hide() {
    _cancelSafetyTimer();

    if (_isGloballyShowing) {
      _removeOverlay();
      _isGloballyShowing = false;
    }
  }

  /// Cancels the safety timer if one is active
  static void _cancelSafetyTimer() {
    _safetyTimer?.cancel();
    _safetyTimer = null;
  }

  /// Returns whether the loading indicator is currently showing
  bool get isShowing => _isGloballyShowing;

  /// Resets the internal state - use when navigating between major screens
  static void reset() {
    _cancelSafetyTimer();
    _removeOverlay();
    _isGloballyShowing = false;
  }

  /// Force closes any open loading indicators, even if we don't have the original context
  static void forceClose() {
    debugPrint('Force closing any active loading indicators');
    reset();

    // Force rebuild UI just to be sure
    WidgetsBinding.instance.addPostFrameCallback((_) {
      reset();
    });
  }

  /// Show a loading indicator temporarily for a specific operation
  ///
  /// Returns the result of the Future operation
  static Future<T> during<T>(BuildContext context, Future<T> operation) async {
    try {
      if (!context.mounted) return await operation;

      final indicator = CustomLoadingIndicator.of(context);
      indicator.show();

      try {
        return await operation;
      } finally {
        if (context.mounted) {
          indicator.hide();
        } else {
          forceClose();
        }
      }
    } catch (e) {
      rethrow;
    }
  }
}

/// The widget implementation of the loading indicator
class LoadingIndicator extends StatelessWidget {
  const LoadingIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Container(
        color: black.withAlpha(120),
        child: const Center(
          child: Card(
            elevation: 4,
            shape: CircleBorder(),
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation<Color>(customIndigoColor),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
