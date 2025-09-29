import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_social_chat/core/constants/enums/router_enum.dart';
import 'package:flutter_social_chat/presentation/blocs/auth_session/auth_session_cubit.dart';
import 'package:flutter_social_chat/presentation/blocs/auth_session/auth_session_state.dart';
import 'package:flutter_social_chat/presentation/blocs/chat_session/chat_session_cubit.dart';
import 'package:flutter_social_chat/presentation/blocs/chat_session/chat_session_state.dart';
import 'package:flutter_social_chat/presentation/design_system/colors.dart';
import 'package:flutter_social_chat/presentation/design_system/widgets/custom_progress_indicator.dart';
import 'package:flutter_social_chat/presentation/design_system/widgets/popscope_scaffold.dart';
import 'package:flutter_social_chat/core/di/dependency_injector.dart';
import 'package:flutter_social_chat/presentation/views/bottom_tab/widgets/bottom_navigation_builder.dart';
import 'package:go_router/go_router.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';

/// Provides the main bottom tab navigation structure for the app.
///
/// This widget manages:
/// 1. The global navigation bar at the bottom of the app
/// 2. Authentication state monitoring and redirection to sign-in if needed
/// 3. Stream Chat connection verification and auto-reconnection
/// 4. Loading state display while services initialize
///
/// It acts as a container for the main content pages which are displayed
/// via the [child] parameter, typically set by the router.
class BottomTabView extends StatefulWidget {
  const BottomTabView({super.key, this.child});

  /// The content page to display within the tab structure
  final Widget? child;

  @override
  State<BottomTabView> createState() => _BottomTabViewState();
}

class _BottomTabViewState extends State<BottomTabView> {
  /// Flag to prevent multiple simultaneous reconnection attempts
  bool _isAttemptingReconnection = false;

  @override
  void initState() {
    super.initState();

    // Check for chat service initialization after the first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _checkChatServiceConnection();
      }
    });
  }

  /// Verifies Stream Chat service is properly connected
  ///
  /// If user is authenticated but chat is not connected,
  /// this initiates a reconnection attempt.
  void _checkChatServiceConnection() {
    if (!mounted) return;

    final authCubit = context.read<AuthSessionCubit>();
    final chatCubit = context.read<ChatSessionCubit>();

    if (authCubit.state.isLoggedIn && !chatCubit.state.isChatUserConnected) {
      _attemptReconnection();
    }
  }

  /// Attempts to reconnect to Stream Chat service
  ///
  /// Uses a flag to prevent multiple simultaneous attempts
  void _attemptReconnection() {
    if (_isAttemptingReconnection || !mounted) return;

    _isAttemptingReconnection = true;

    try {
      context.read<AuthSessionCubit>().reconnectToChatService();
    } catch (e) {
      // Ignore reconnection errors, will retry on next state change
    } finally {
      _isAttemptingReconnection = false;
    }
  }

  /// Safely navigates to the sign-in view when user is logged out
  void _navigateToSignIn() {
    if (!mounted) return;

    // Use post-frame callback to avoid navigation during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        try {
          context.go(RouterEnum.signInView.routeName);
        } catch (e) {
          // Ignore navigation errors
        }
      }
    });
  }

  /// Manually checks if Stream Chat is connected by examining client state
  ///
  /// This helps detect situations where the client is connected but the
  /// ChatSessionCubit hasn't been updated to reflect this.
  bool _isStreamChatActuallyConnected() {
    try {
      final client = getIt<StreamChatClient>();
      return client.state.currentUser != null;
    } catch (e) {
      return false;
    }
  }

  /// Forces a sync between Stream Chat client state and ChatSessionCubit
  void _syncChatClientState() {
    if (!mounted) return;

    try {
      context.read<ChatSessionCubit>().syncWithClientState();
    } catch (e) {
      // Ignore sync errors
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        // Listen for authentication state changes
        BlocListener<AuthSessionCubit, AuthSessionState>(
          listenWhen: (previous, current) => previous.isLoggedIn != current.isLoggedIn,
          listener: _handleAuthStateChanges,
        ),
        // Listen for chat session state changes
        BlocListener<ChatSessionCubit, ChatSessionState>(
          listenWhen: (previous, current) =>
              previous.isUserCheckedFromChatService != current.isUserCheckedFromChatService ||
              previous.isChatUserConnected != current.isChatUserConnected,
          listener: _handleChatStateChanges,
        ),
      ],
      child: _buildMainContent(),
    );
  }

  /// Handles authentication state changes
  void _handleAuthStateChanges(BuildContext context, AuthSessionState authState) {
    if (!authState.isLoggedIn) {
      _navigateToSignIn();
    }
  }

  /// Handles chat session state changes
  void _handleChatStateChanges(BuildContext context, ChatSessionState state) {
    if (!mounted) return;

    if (state.isUserCheckedFromChatService && !state.isChatUserConnected) {
      final authState = context.read<AuthSessionCubit>().state;

      if (authState.isLoggedIn) {
        _attemptReconnection();
      }
    }
  }

  /// Builds the main content of the app based on auth and chat states
  Widget _buildMainContent() {
    return BlocBuilder<ChatSessionCubit, ChatSessionState>(
      buildWhen: (previous, current) =>
          previous.isUserCheckedFromChatService != current.isUserCheckedFromChatService ||
          previous.isChatUserConnected != current.isChatUserConnected,
      builder: (context, chatState) {
        return BlocBuilder<AuthSessionCubit, AuthSessionState>(
          buildWhen: (previous, current) =>
              previous.isInProgress != current.isInProgress || previous.isLoggedIn != current.isLoggedIn,
          builder: (context, authState) {
            // Determine if we should show loading state
            if (_shouldShowLoading(authState, chatState)) {
              return _buildLoadingScreen();
            }

            // Redirect to sign in if not logged in
            if (!authState.isLoggedIn) {
              _navigateToSignIn();
              return const SizedBox.shrink();
            }

            // Main app UI when fully authenticated and connected
            return _buildMainAppUI();
          },
        );
      },
    );
  }

  /// Determines if the loading screen should be displayed
  bool _shouldShowLoading(AuthSessionState authState, ChatSessionState chatState) {
    // Show loading when auth operations are in progress or chat isn't ready yet
    final isInLoadingState =
        authState.isInProgress || (authState.isLoggedIn && !chatState.isUserCheckedFromChatService);

    // Check if we're stuck in loading but actually connected
    if (isInLoadingState && authState.isLoggedIn) {
      final isActuallyConnected = _isStreamChatActuallyConnected();

      // If UI thinks we're loading but client is actually connected,
      // let's force a state refresh by syncing
      if (isActuallyConnected && !chatState.isUserCheckedFromChatService) {
        _syncChatClientState();
        return false; // Skip loading screen, we're actually connected
      }

      return !isActuallyConnected; // Only show loading if truly not connected
    }

    return isInLoadingState;
  }

  /// Builds the loading screen
  Widget _buildLoadingScreen() {
    return const PopScopeScaffold(
      body: Center(
        child: CustomProgressIndicator(progressIndicatorColor: customIndigoColor),
      ),
    );
  }

  /// Builds the main app UI with bottom navigation
  Widget _buildMainAppUI() {
    return PopScopeScaffold(
      backgroundColor: backgroundGrey,
      body: widget.child ?? const SizedBox.shrink(),
      bottomNavigationBar: bottomNavigationBuilder(context),
    );
  }
}
