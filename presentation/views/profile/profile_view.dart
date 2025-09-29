import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_social_chat/core/constants/enums/router_enum.dart';
import 'package:flutter_social_chat/core/di/dependency_injector.dart';
import 'package:flutter_social_chat/presentation/blocs/auth_session/auth_session_cubit.dart';
import 'package:flutter_social_chat/presentation/blocs/auth_session/auth_session_state.dart';
import 'package:flutter_social_chat/presentation/blocs/chat_session/chat_session_cubit.dart';
import 'package:flutter_social_chat/presentation/blocs/chat_session/chat_session_state.dart';
import 'package:flutter_social_chat/presentation/design_system/colors.dart';
import 'package:flutter_social_chat/presentation/views/profile/widgets/profile_view_contact_card.dart';
import 'package:flutter_social_chat/presentation/views/profile/widgets/profile_view_cover_card.dart';
import 'package:flutter_social_chat/presentation/views/profile/widgets/profile_view_details.dart';
import 'package:flutter_social_chat/presentation/views/profile/widgets/profile_view_loading_view.dart';
import 'package:flutter_social_chat/presentation/views/profile/widgets/profile_view_sign_out_button.dart';
import 'package:flutter_social_chat/presentation/views/profile/widgets/profile_view_status_card.dart';
import 'package:go_router/go_router.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';

/// Displays the user's profile information and account settings.
///
/// This page shows:
/// - User profile information (name, photo, ID)
/// - Account activity and status
/// - Account creation date
/// - Contact information
/// - Sign-out functionality
///
/// It handles both authentication state and Stream Chat connection state
/// to ensure the display of accurate and up-to-date user information.
class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthSessionCubit, AuthSessionState>(
      listenWhen: (previous, current) => previous.isLoggedIn != current.isLoggedIn,
      listener: _handleAuthStateChanges,
      child: _buildProfileContent(context),
    );
  }

  /// Handles authentication state changes for navigation
  void _handleAuthStateChanges(BuildContext context, AuthSessionState state) {
    if (!state.isLoggedIn) {
      _safelyNavigateToSignIn(context);
    }
  }

  /// Safely navigates to the sign-in view
  void _safelyNavigateToSignIn(BuildContext context) {
    try {
      context.go(RouterEnum.signInView.routeName);
    } catch (e) {
      // Ignore navigation errors
    }
  }

  /// Builds the main profile content with state awareness
  Widget _buildProfileContent(BuildContext context) {
    return BlocBuilder<AuthSessionCubit, AuthSessionState>(
      builder: (context, authState) {
        return BlocBuilder<ChatSessionCubit, ChatSessionState>(
          builder: (context, chatState) {
            // Check if Stream Chat is ready
            if (!_isStreamChatReady(context, chatState)) {
              return const ProfileViewLoadingView();
            }

            // Extract user information
            final userInfo = _extractUserInfo(authState, chatState);

            // Build profile UI
            return Container(
              color: backgroundGrey,
              child: Column(
                children: [
                  ProfileViewCoverCard(
                    userName: userInfo.userName,
                    userPhotoUrl: userInfo.photoUrl,
                    userId: userInfo.userId,
                    userPhoneNumber: userInfo.phoneNumber,
                  ),
                  ProfileViewStatusCard(
                    isUserBannedStatus: userInfo.isUserBanned,
                  ),
                  ProfileViewDetails(
                    createdAt: userInfo.createdAt,
                    isUserBannedStatus: userInfo.isUserBanned,
                  ),
                  ProfileViewContactCard(
                    userPhoneNumber: userInfo.phoneNumber,
                    userId: userInfo.userId,
                  ),
                  const ProfileViewSignOutButton(),
                ],
              ),
            );
          },
        );
      },
    );
  }

  /// Checks if Stream Chat is ready for use
  /// Returns true if chat is ready or successfully connected
  bool _isStreamChatReady(BuildContext context, ChatSessionState chatState) {
    // If chat service is already initialized, we're good to go
    if (chatState.isUserCheckedFromChatService) {
      return true;
    }

    // If not initialized, check if Stream Chat is actually connected
    try {
      final client = getIt<StreamChatClient>();
      final isStreamChatConnected = client.state.currentUser != null;

      if (isStreamChatConnected) {
        // Force a sync if client is connected but state doesn't reflect it
        context.read<ChatSessionCubit>().syncWithClientState();
        return true;
      }
    } catch (e) {
      // If error checking connection, return false
    }

    // Chat is not ready
    return false;
  }

  /// Extracts and formats user information from state objects
  ({String userName, String photoUrl, String userId, String phoneNumber, String createdAt, bool isUserBanned})
      _extractUserInfo(AuthSessionState authState, ChatSessionState chatState) {
    return (
      userName: authState.authUser.userName ?? '',
      photoUrl: authState.authUser.photoUrl ?? '',
      userId: authState.authUser.id.replaceRange(8, 25, '*****'),
      phoneNumber: authState.authUser.phoneNumber,
      createdAt: chatState.chatUser.createdAt,
      isUserBanned: chatState.chatUser.isUserBanned
    );
  }
}
