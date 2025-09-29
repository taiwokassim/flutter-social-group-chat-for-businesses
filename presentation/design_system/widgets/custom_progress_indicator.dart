import 'package:flutter/material.dart';

/// A customized progress indicator that provides consistent styling across the app
///
/// This widget wraps the Flutter CircularProgressIndicator with default values
/// aligned with the app's design system.
class CustomProgressIndicator extends StatelessWidget {
  const CustomProgressIndicator({
    super.key,
    this.progressIndicatorColor,
    this.size = 48.0,
    this.strokeWidth = 4.0,
    this.backgroundColor,
    this.padding = EdgeInsets.zero,
  });

  /// The color of the progress indicator (defaults to primary color from theme)
  final Color? progressIndicatorColor;

  /// The size of the progress indicator in logical pixels
  final double size;

  /// The thickness of the progress indicator line
  final double strokeWidth;

  /// Optional background color for the progress indicator
  final Color? backgroundColor;

  /// Padding around the progress indicator
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: padding,
        child: SizedBox(
          width: size,
          height: size,
          child: CircularProgressIndicator(
            color: progressIndicatorColor ?? theme.primaryColor,
            strokeWidth: strokeWidth,
            backgroundColor: backgroundColor,
          ),
        ),
      ),
    );
  }
}
