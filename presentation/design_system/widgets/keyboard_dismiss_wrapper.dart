import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// A wrapper widget that enables dismissing the keyboard by tapping anywhere outside input fields.
///
/// This widget should be used to wrap screen content to provide a consistent keyboard
/// dismissal behavior across the app. It uses the most reliable cross-platform approach
/// to ensure the keyboard is properly dismissed.
class KeyboardDismissWrapper extends StatelessWidget {
  /// The child widget that will be wrapped.
  final Widget child;

  /// Whether to enable behavior where tapping outside input fields dismisses the keyboard.
  ///
  /// Defaults to true. Set to false in rare cases where you don't want this behavior.
  final bool enableDismissOnTap;

  /// Creates a KeyboardDismissWrapper.
  const KeyboardDismissWrapper({
    Key? key,
    required this.child,
    this.enableDismissOnTap = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // If dismissal is not enabled, just return the child
    if (!enableDismissOnTap) {
      return child;
    }

    // Otherwise wrap with GestureDetector to enable keyboard dismissal
    return GestureDetector(
      onTap: () => _dismissKeyboard(context),
      // Ensures the detector doesn't interfere with scrolling or other gestures
      behavior: HitTestBehavior.translucent,
      child: child,
    );
  }

  /// Dismisses the keyboard using the most reliable cross-platform approach.
  void _dismissKeyboard(BuildContext context) {
    // First unfocus any focused text field
    FocusScope.of(context).unfocus();

    // For iOS, also use the platform channel method for better reliability
    if (Platform.isIOS) {
      try {
      SystemChannels.textInput.invokeMethod('TextInput.hide');
      } catch (e) {
        // Fallback is already handled by unfocus() above
        debugPrint('Error hiding keyboard: $e');
      }
    }
  }
}
