import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_social_chat/presentation/design_system/colors.dart';
import 'package:flutter_social_chat/presentation/design_system/widgets/custom_text.dart';

/// A customized app bar that provides consistent styling across the app
///
/// This widget wraps the Flutter AppBar with default values aligned with
/// the app's design system and provides additional customization options.
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  CustomAppBar({
    super.key,
    this.title,
    this.backgroundColor,
    this.leading,
    this.isTitleCentered = true,
    this.titleColor = black,
    this.titleFontSize = 20,
    this.titleFontWeight = FontWeight.w600,
    this.actions,
    this.elevation = 0,
    this.extraHeight = 8,
    this.bottom,
    this.systemOverlayStyle,
    this.showBackButton = false,
    this.onBackPressed,
  }) : preferredSize = Size.fromHeight(kToolbarHeight + extraHeight + (bottom?.preferredSize.height ?? 0));

  @override
  final Size preferredSize;

  /// Whether to center the title. Defaults to true.
  final bool isTitleCentered;

  /// The title text to display.
  final String? title;

  /// Background color of the app bar.
  final Color? backgroundColor;

  /// Color of the title text.
  final Color titleColor;

  /// Font size of the title text.
  final double titleFontSize;

  /// Font weight of the title text.
  final FontWeight titleFontWeight;

  /// Widget to display before the title.
  final Widget? leading;

  /// List of widgets to display after the title.
  final List<Widget>? actions;

  /// Elevation of the app bar. Defaults to 0.
  final double elevation;

  /// Additional height to add to the standard app bar height.
  final double extraHeight;

  /// Optional bottom widget for the app bar (e.g., TabBar).
  final PreferredSizeWidget? bottom;

  /// System overlay style to control status bar appearance.
  final SystemUiOverlayStyle? systemOverlayStyle;

  /// Whether to show a back button in the leading position.
  final bool showBackButton;

  /// Callback for when the back button is pressed.
  final VoidCallback? onBackPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scaffoldBackgroundColor = theme.scaffoldBackgroundColor;

    // Determine the leading widget
    Widget? leadingWidget = leading;
    if (showBackButton && leadingWidget == null) {
      leadingWidget = IconButton(
        icon: const Icon(Icons.arrow_back, color: black),
        onPressed: onBackPressed ?? () => Navigator.of(context).pop(),
      );
    }

    // Only create the title widget if a title string is provided
    final Widget? appBarTitle = title != null
        ? CustomText(
            color: titleColor,
            fontSize: titleFontSize,
            text: title!,
            fontWeight: titleFontWeight,
          )
        : null;

    // Default system overlay style based on background color
    final effectiveSystemOverlayStyle = systemOverlayStyle ??
        SystemUiOverlayStyle(
          statusBarColor: transparent,
          statusBarIconBrightness:
              _isLightColor(backgroundColor ?? scaffoldBackgroundColor) ? Brightness.dark : Brightness.light,
          statusBarBrightness:
              _isLightColor(backgroundColor ?? scaffoldBackgroundColor) ? Brightness.light : Brightness.dark,
        );

    return AppBar(
      centerTitle: isTitleCentered,
      backgroundColor: backgroundColor ?? scaffoldBackgroundColor,
      toolbarHeight: kToolbarHeight + extraHeight,
      elevation: elevation,
      leadingWidth: 56,
      leading: leadingWidget,
      actions: actions,
      surfaceTintColor: backgroundColor,
      shadowColor: transparent,
      title: appBarTitle,
      bottom: bottom,
      systemOverlayStyle: effectiveSystemOverlayStyle,
      scrolledUnderElevation: 0.5,
    );
  }

  /// Helper method to determine if a color is light
  bool _isLightColor(Color color) {
    // Calculate the brightness using the formula:
    // (0.299 * R) + (0.587 * G) + (0.114 * B)
    final brightness = (0.299 * color.r + 0.587 * color.g + 0.114 * color.b) / 255;
    return brightness > 0.5;
  }
}
