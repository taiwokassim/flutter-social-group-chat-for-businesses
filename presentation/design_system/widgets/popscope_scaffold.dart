import 'package:flutter/material.dart';
import 'package:flutter_social_chat/presentation/design_system/widgets/keyboard_dismiss_wrapper.dart';

/// A scaffold with built-in PopScope handling and keyboard dismiss functionality.
///
/// This widget combines a standard Scaffold with PopScope to control navigation
/// and KeyboardDismissWrapper for automatic keyboard dismissal when tapping outside
/// input fields.
class PopScopeScaffold extends StatelessWidget {
  const PopScopeScaffold({
    Key? key,
    this.bottomNavigationBar,
    this.body,
    this.floatingActionButton,
    this.appBar,
    this.backgroundColor,
    this.resizeToAvoidBottomInset = true,
    this.onPopInvokedWithResult,
    this.enableKeyboardDismiss = true,
    this.primary = true,
  }) : super(key: key);

  /// The bottom navigation bar of the scaffold.
  final Widget? bottomNavigationBar;
  
  /// The primary content of the scaffold.
  final Widget? body;
  
  /// The floating action button for the scaffold.
  final Widget? floatingActionButton;
  
  /// The app bar displayed at the top of the scaffold.
  final PreferredSizeWidget? appBar;
  
  /// The background color for the scaffold.
  final Color? backgroundColor;
  
  /// Whether the body should resize when the keyboard appears.
  final bool resizeToAvoidBottomInset;
  
  /// Callback function when pop is invoked with a result.
  final void Function(bool, Object?)? onPopInvokedWithResult;
  
  /// Whether to enable automatic keyboard dismissal.
  final bool enableKeyboardDismiss;

  /// Whether this scaffold is the primary scaffold in the app.
  /// Set to false when using as a nested scaffold.
  final bool primary;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Wrap the body in KeyboardDismissWrapper if enabled
    final wrappedBody = enableKeyboardDismiss && body != null ? KeyboardDismissWrapper(child: body!) : body;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: onPopInvokedWithResult ?? (didPop, result) {},
      child: Scaffold(
        primary: primary,
        bottomNavigationBar: bottomNavigationBar,
        body: wrappedBody,
        appBar: appBar,
        floatingActionButton: floatingActionButton,
        backgroundColor: backgroundColor ?? theme.scaffoldBackgroundColor,
        resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      ),
    );
  }
}
