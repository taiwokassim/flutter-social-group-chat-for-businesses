import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// A custom page transition builder
///
/// This is used by the GoRouter to create page transitions.
/// It uses no animation to make navigation instant.
CustomTransitionPage<void> customPageBuilderWidget(
  BuildContext context,
  GoRouterState state,
  Widget child,
) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) => child,
    transitionDuration: Duration.zero,
  );
}
