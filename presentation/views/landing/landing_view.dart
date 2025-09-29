import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_social_chat/core/constants/enums/router_enum.dart';
import 'package:flutter_social_chat/presentation/blocs/auth_session/auth_session_cubit.dart';
import 'package:flutter_social_chat/presentation/blocs/auth_session/auth_session_state.dart';
import 'package:flutter_social_chat/presentation/design_system/widgets/popscope_scaffold.dart';
import 'package:flutter_social_chat/presentation/views/landing/widgets/landing_background.dart';
import 'package:flutter_social_chat/presentation/views/landing/widgets/landing_content.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';

/// The initial landing page shown when the app starts
///
/// This page serves several purposes:
/// 1. Displays an animated splash screen with the app logo
/// 2. Checks authentication state to determine where to navigate
/// 3. Shows loading indicators for various initialization phases
/// 4. Ensures a smooth user experience with minimum splash duration
/// 5. Handles transitions to the appropriate next screen
class LandingView extends StatefulWidget {
  const LandingView({super.key});

  @override
  State<LandingView> createState() => _LandingViewState();
}

class _LandingViewState extends State<LandingView> with SingleTickerProviderStateMixin {
  // Animation constants
  static const Duration _animationDuration = Duration(milliseconds: 3000);
  static const Duration _minimumSplashDuration = Duration(milliseconds: 4000);
  static const Duration _loadingDotsDuration = Duration(milliseconds: 500);
  static const Duration _navigationDelay = Duration(milliseconds: 500);

  // Loading phase constants
  static const int _maxLoadingPhase = 4;

  /// Controls the fade-in animation for the splash content
  late final AnimationController _animationController;
  late final Animation<double> _fadeAnimation;

  /// Flag to prevent multiple navigation attempts
  bool _hasCheckedInitialRoute = false;

  /// Flag indicating if auth state has been checked
  bool _isAuthStateReady = false;

  /// Flag indicating if minimum splash duration has elapsed
  bool _isReadyToNavigate = false;

  /// Current loading message to display (updated with dots animation)
  late String _loadingMessage;

  /// Current loading phase (0-4) affecting the UI display
  int _loadingPhase = 0;

  /// Timer for the loading dots animation
  Timer? _loadingDotsTimer;

  @override
  void initState() {
    super.initState();
    _initializeAnimation();
    _loadingMessage = '';

    // Delay auth check until after first build when localizations are available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAuthAndInitialize();
    });
  }

  /// Sets up the fade-in animation for splash content
  void _initializeAnimation() {
    _animationController = AnimationController(vsync: this, duration: _animationDuration);

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    _animationController.forward();
  }

  /// Starts the authentication check and initialization process
  void _checkAuthAndInitialize() {
    if (!mounted) return;

    // Update initial message with localized string
    final localizations = AppLocalizations.of(context)!;
    _updateLoadingState(localizations.startingUp, 0);

    final authState = context.read<AuthSessionCubit>().state;

    // Start loading message animation
    _startLoadingDotsAnimation();

    // Handle the case where auth state is already checked
    if (authState.isUserCheckedFromAuthService) {
      _isAuthStateReady = true;
      _updateLoadingState(localizations.accountVerified, 2);
      _checkAndNavigate(authState);
    } else {
      _updateLoadingState(localizations.verifyingAccount, 1);
    }

    // Ensure minimum display time for the splash screen
    _ensureMinimumSplashDuration(authState);
  }

  /// Updates the loading message and phase state
  void _updateLoadingState(String message, int phase) {
    if (!mounted) return;

    setState(() {
      _loadingMessage = message;
      _loadingPhase = phase;
    });
  }

  /// Ensures the splash screen is shown for a minimum duration
  void _ensureMinimumSplashDuration(AuthSessionState authState) {
    Future.delayed(_minimumSplashDuration, () {
      if (!mounted) return;

      setState(() {
        _isReadyToNavigate = true;
        _loadingMessage = AppLocalizations.of(context)!.loadingChats;
        _loadingPhase = 3;
      });

      // If auth state is already ready, navigate now
      if (_isAuthStateReady && !_hasCheckedInitialRoute) {
        _prepareForNavigation();
        _navigateToAppropriateRoute(authState.isLoggedIn, authState.authUser.isOnboardingCompleted);
      }
    });
  }

  /// Starts the animated dots (.) for loading messages
  void _startLoadingDotsAnimation() {
    _loadingDotsTimer?.cancel();
    _loadingDotsTimer = Timer.periodic(_loadingDotsDuration, (_) {
      if (!mounted || _hasCheckedInitialRoute) {
        _loadingDotsTimer?.cancel();
        return;
      }

      setState(() {
        if (_loadingMessage.endsWith('...')) {
          _loadingMessage = _loadingMessage.substring(0, _loadingMessage.length - 3);
        } else {
          _loadingMessage = '$_loadingMessage.';
        }
      });
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _loadingDotsTimer?.cancel();
    super.dispose();
  }

  /// Checks if ready to navigate and initiates navigation if so
  void _checkAndNavigate(AuthSessionState authState) {
    if (!_isReadyToNavigate || !_isAuthStateReady || _hasCheckedInitialRoute) return;

    _prepareForNavigation();
    _navigateToAppropriateRoute(authState.isLoggedIn, authState.authUser.isOnboardingCompleted);
  }

  /// Prepares the UI for navigation
  void _prepareForNavigation() {
    final localizations = AppLocalizations.of(context);
    _updateLoadingState(localizations?.takingToChats ?? '', _maxLoadingPhase);
    _loadingDotsTimer?.cancel();
  }

  /// Navigates to the appropriate route based on auth state
  void _navigateToAppropriateRoute(bool isUserLoggedIn, bool isOnboardingCompleted) {
    if (!mounted || _hasCheckedInitialRoute) return;

    // Mark as checked to prevent multiple navigation attempts
    _hasCheckedInitialRoute = true;

    // Add a small delay to make transition smoother
    Future.delayed(_navigationDelay, () {
      if (!mounted) return;

      try {
        final route = _getRouteForUser(isUserLoggedIn, isOnboardingCompleted);
        context.go(route);
      } catch (e) {
        // If navigation fails, try an alternative approach
        _handleNavigationError(isUserLoggedIn, isOnboardingCompleted);
      }
    });
  }

  /// Handles navigation errors with fallback approach
  void _handleNavigationError(bool isUserLoggedIn, bool isOnboardingCompleted) {
    if (!mounted) return;

    // Try once more on the next frame with a different approach
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      try {
        final route = _getRouteForUser(isUserLoggedIn, isOnboardingCompleted);
        context.go(route);
      } catch (e) {
        // Last resort - go to sign in view directly
        if (mounted) {
          context.go(RouterEnum.signInView.routeName);
        }
      }
    });
  }

  /// Determines the appropriate route based on auth state
  String _getRouteForUser(bool isUserLoggedIn, bool isOnboardingCompleted) {
    if (isUserLoggedIn && !isOnboardingCompleted) {
      return RouterEnum.onboardingView.routeName;
    } else if (isUserLoggedIn && isOnboardingCompleted) {
      return RouterEnum.dashboardView.routeName;
    } else {
      return RouterEnum.signInView.routeName;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthSessionCubit, AuthSessionState>(
      listenWhen: (previous, current) =>
          previous.isUserCheckedFromAuthService != current.isUserCheckedFromAuthService &&
          current.isUserCheckedFromAuthService,
      listener: _handleAuthStateChanged,
      child: PopScopeScaffold(
        body: Stack(
          children: [
            const LandingBackground(),
            FadeTransition(
              opacity: _fadeAnimation,
              child: LandingContent(
                loadingMessage: _loadingMessage,
                loadingPhase: _loadingPhase,
                isReadyToNavigate: _isReadyToNavigate,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Handles authentication state changes from the BlocListener
  void _handleAuthStateChanged(BuildContext context, AuthSessionState state) {
    final localizations = AppLocalizations.of(context);

    _isAuthStateReady = true;
    _updateLoadingState(localizations?.accountVerified ?? '', 2);
    _checkAndNavigate(state);
  }
}
