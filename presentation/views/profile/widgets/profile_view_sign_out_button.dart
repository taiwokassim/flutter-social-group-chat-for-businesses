import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_social_chat/core/constants/enums/router_enum.dart';
import 'package:flutter_social_chat/core/di/dependency_injector.dart';
import 'package:flutter_social_chat/presentation/blocs/auth_session/auth_session_cubit.dart';
import 'package:flutter_social_chat/presentation/blocs/auth_session/auth_session_state.dart';
import 'package:flutter_social_chat/presentation/blocs/chat_management/chat_management_cubit.dart';
import 'package:flutter_social_chat/presentation/blocs/chat_session/chat_session_cubit.dart';
import 'package:flutter_social_chat/presentation/blocs/phone_number_sign_in/phone_number_sign_in_cubit.dart';
import 'package:flutter_social_chat/presentation/design_system/colors.dart';
import 'package:flutter_social_chat/presentation/design_system/widgets/custom_loading_indicator.dart';
import 'package:flutter_social_chat/presentation/design_system/widgets/custom_text.dart';
import 'package:go_router/go_router.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';

/// A button that handles the sign-out process including confirmation dialog,
/// disconnection from Stream Chat, and navigation to the sign-in view.
class ProfileViewSignOutButton extends StatefulWidget {
  const ProfileViewSignOutButton({super.key});

  @override
  State<ProfileViewSignOutButton> createState() => _ProfileViewSignOutButtonState();
}

class _ProfileViewSignOutButtonState extends State<ProfileViewSignOutButton> {
  /// Flag to prevent multiple simultaneous sign-out attempts
  bool _isSigningOut = false;

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);

    return BlocListener<AuthSessionCubit, AuthSessionState>(
      listenWhen: (previous, current) =>
          !_isSigningOut || // When not signing out already
          (previous.isInProgress != current.isInProgress) || // When progress state changes
          (previous.isLoggedIn && !current.isLoggedIn), // When actually logged out
      listener: _handleAuthStateChanges,
      child: Container(
        margin: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
        width: double.infinity,
        child: ElevatedButton(
          onPressed: _isSigningOut ? null : () => _showSignOutConfirmationDialog(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: customIndigoColor,
            foregroundColor: white,
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 2,
            shadowColor: black.withValues(alpha: 0.2),
          ),
          child: _buildButtonContent(localization),
        ),
      ),
    );
  }

  /// Builds the button content with icon and text
  Widget _buildButtonContent(AppLocalizations? localization) {
    return Row(
      spacing: 8,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.logout_rounded, color: white, size: 18),
        CustomText(
          text: localization?.signOut ?? '',
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: white,
        ),
      ],
    );
  }

  /// Handles auth state changes, managing loading indicator and navigation
  void _handleAuthStateChanges(BuildContext context, AuthSessionState state) {
    if (state.isInProgress) {
      _safelyShowLoadingIndicator(context);
    } else {
      _safelyHideLoadingIndicator(context);

      // Handle successful sign out - navigate only if we're actually signed out
      if (!state.isLoggedIn && !state.isInProgress && mounted && _isSigningOut) {
        _safelyNavigateToSignIn(context);
      }
    }
  }

  /// Safely shows the loading indicator
  void _safelyShowLoadingIndicator(BuildContext context) {
    if (!mounted) return;

    try {
      CustomLoadingIndicator.of(context).show();
    } catch (e) {
      // Ignore loading indicator errors
    }
  }

  /// Safely hides the loading indicator
  void _safelyHideLoadingIndicator(BuildContext context) {
    if (!mounted) return;

    try {
      CustomLoadingIndicator.of(context).hide();
    } catch (e) {
      // Ignore loading indicator errors
    }
  }

  /// Safely navigates to the sign-in view
  void _safelyNavigateToSignIn(BuildContext context) {
    Future.microtask(() {
      if (!mounted) return;

      try {
        context.go(RouterEnum.signInView.routeName);
        setState(() => _isSigningOut = false);
      } catch (e) {
        // If first navigation attempt fails, try again on next frame
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            GoRouter.of(context).go(RouterEnum.signInView.routeName);
          }
        });
      }
    });
  }

  /// Shows a confirmation dialog before signing out
  void _showSignOutConfirmationDialog(BuildContext context) {
    final localization = AppLocalizations.of(context);

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: CustomText(
            text: localization?.signOut ?? '',
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: customGreyColor900,
          ),
          content: CustomText(text: localization?.signOutConfirmation ?? '', color: customGreyColor800),
          actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            Row(
              spacing: 12,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(child: _buildCancelButton(dialogContext, localization)),
                Expanded(child: _buildConfirmButton(dialogContext, context, localization)),
              ],
            ),
          ],
        );
      },
    );
  }

  /// Builds the cancel button for the confirmation dialog
  Widget _buildCancelButton(BuildContext dialogContext, AppLocalizations? localization) {
    return TextButton(
      onPressed: () => Navigator.of(dialogContext).pop(),
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: CustomText(text: localization?.cancel ?? '', color: customGreyColor700),
    );
  }

  /// Builds the confirm button for the confirmation dialog
  Widget _buildConfirmButton(BuildContext dialogContext, BuildContext parentContext, AppLocalizations? localization) {
    return ElevatedButton(
      onPressed: () {
        Navigator.of(dialogContext).pop();
        _performSignOut(parentContext);
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: customIndigoColor,
        foregroundColor: white,
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: CustomText(text: localization?.signOut ?? '', color: white),
    );
  }

  /// Carefully handles Stream Chat disconnection to prevent race conditions
  Future<void> _disconnectStreamChat() async {
    // Store reference to ChatManagementCubit to avoid context use during async operation
    ChatManagementCubit? chatManagementCubit;
    if (mounted) {
      try {
        chatManagementCubit = context.read<ChatManagementCubit>();
      } catch (e) {
        // Ignore error getting cubit reference
      }
    }

    try {
      final client = getIt<StreamChatClient>();

      // Check if client exists and is connected
      if (client.state.currentUser != null) {
        // Reset Chat Management cubit to clean up subscriptions first
        if (chatManagementCubit != null) {
          await chatManagementCubit.reset();
          // Give time for subscriptions to be cleaned up
          await Future.delayed(const Duration(milliseconds: 200));
        }

        // Disconnect in stages to prevent race conditions
        await _disconnectChannels(client);
        await _disconnectUser(client);

        // Verify disconnection was successful
        if (client.state.currentUser != null) {
          // Force disconnect as a fallback mechanism
          await client.disconnectUser(flushChatPersistence: true);
          await Future.delayed(const Duration(milliseconds: 300));
        }
      }
    } catch (e) {
      // Log the error but continue with sign-out process
      debugPrint('Error disconnecting from Stream Chat: $e');
    }
  }

  /// Disconnects all active channels
  Future<void> _disconnectChannels(StreamChatClient client) async {
    try {
      // Create a copy of the channels to avoid concurrent modification
      final channelsCopy = Map<String, Channel>.from(client.state.channels);

      // Close all active channels
      for (final entry in channelsCopy.entries) {
        try {
          // Don't await inside loop to avoid waiting sequentially
          entry.value.dispose();
        } catch (e) {
          // Ignore individual channel disposal errors
        }
      }

      // Allow time for channel disposal to complete
      await Future.delayed(const Duration(milliseconds: 200));
    } catch (e) {
      debugPrint('Error disposing channels: $e');
    }
  }

  /// Disconnects the user from Stream Chat
  Future<void> _disconnectUser(StreamChatClient client) async {
    try {
      // Check if the client is still connected
      if (client.state.currentUser != null) {
        // Disconnect with persistence flush
        await client.disconnectUser(flushChatPersistence: true);

        // Allow more time for disconnection to complete
        await Future.delayed(const Duration(milliseconds: 300));

        // Verify disconnection was successful
        if (client.state.currentUser != null) {
          debugPrint('First disconnect attempt failed, trying again...');
          // Try again with different approach
          await Future.delayed(const Duration(milliseconds: 200));
          await client.dispose();
        }
      }
    } catch (e) {
      debugPrint('Error disconnecting user: $e');
      // Try alternative disconnection method as fallback
      try {
        await client.dispose();
      } catch (e2) {
        debugPrint('Error on fallback disposal: $e2');
      }
    }
  }

  /// Performs the sign-out process
  Future<void> _performSignOut(BuildContext context) async {
    // Prevent multiple sign-out attempts
    if (_isSigningOut) return;
    setState(() => _isSigningOut = true);

    // Get references to required cubits before async operations
    final cubits = _getCubitReferences(context);

    // Show loading indicator
    CustomLoadingIndicator.reset();
    _safelyShowLoadingIndicator(context);

    try {
      // Perform sign-out steps in sequence with proper error handling
      await _disconnectStreamChat();
      await _resetCubits(cubits);
      await _clearStorage();

      // Finally trigger auth sign-out
      await cubits.authCubit.signOut();
    } catch (e) {
      debugPrint('Error during sign-out process: $e');
      // Reset sign-out flag if there was an error
      if (mounted) {
        setState(() => _isSigningOut = false);
      }
    }
  }

  /// Gets references to all required cubits
  ({PhoneNumberSignInCubit phoneCubit, ChatSessionCubit chatCubit, AuthSessionCubit authCubit}) _getCubitReferences(
    BuildContext context,
  ) {
    return (
      phoneCubit: context.read<PhoneNumberSignInCubit>(),
      chatCubit: context.read<ChatSessionCubit>(),
      authCubit: context.read<AuthSessionCubit>()
    );
  }

  /// Resets all cubits to clear state
  Future<void> _resetCubits(
    ({PhoneNumberSignInCubit phoneCubit, ChatSessionCubit chatCubit, AuthSessionCubit authCubit}) cubits,
  ) async {
    cubits.phoneCubit.reset();
    cubits.chatCubit.reset();
  }

  /// Clears the hydrated storage
  Future<void> _clearStorage() async {
    try {
      await HydratedBloc.storage.clear();
    } catch (e) {
      // Ignore storage clearing errors
    }
  }
}
