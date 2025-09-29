// ignore_for_file: avoid_redundant_argument_values

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_social_chat/presentation/blocs/profile_management/profile_manager_state.dart';
import 'package:flutter_social_chat/presentation/blocs/auth_session/auth_session_cubit.dart';
import 'package:flutter_social_chat/core/interfaces/i_auth_repository.dart';
import 'package:flutter_social_chat/core/interfaces/i_chat_repository.dart';
import 'package:flutter/foundation.dart';

/// Manages user profile creation and validation
///
/// This cubit handles the profile creation process, including:
/// - Username validation
/// - User profile data updates with default image
class ProfileManagerCubit extends Cubit<ProfileManagerState> {
  ProfileManagerCubit({
    required IAuthRepository authRepository,
    required FirebaseFirestore firebaseFirestore,
    required AuthSessionCubit authSessionCubit,
    required IChatRepository chatRepository,
  })  : _authRepository = authRepository,
        _firebaseFirestore = firebaseFirestore,
        _authSessionCubit = authSessionCubit,
        _chatRepository = chatRepository,
        super(ProfileManagerState.empty());

  final IAuthRepository _authRepository;
  final FirebaseFirestore _firebaseFirestore;
  final AuthSessionCubit _authSessionCubit;
  final IChatRepository _chatRepository;

  // Default remote image URL
  static const String defaultProfileImageUrl =
      'https://pbs.twimg.com/profile_images/1870429866643869696/K1jmpXsk_400x400.jpg';

  /// Validates the username and updates the state
  ///
  /// The username validation rules are handled in the UI (UsernameFormField)
  /// This method simply stores the validation result in the state
  void updateUsernameValidity({required bool isValid}) {
    emit(state.copyWith(isUserNameValid: isValid));
  }

  /// Creates a user profile with the validated username and default profile image
  ///
  /// Returns the profile photo URL if successful, empty string if fails
  Future<String> createUserProfile() async {
    if (state.isInProgress) return '';
    if (!state.isUserNameValid) {
      return '';
    }

    emit(state.copyWith(isInProgress: true));

    try {
      final userId = _authSessionCubit.state.authUser.id;
      final username = _authSessionCubit.state.authUser.userName;

      if (username == null || username.isEmpty) {
        emit(state.copyWith(isInProgress: false));
        return '';
      }

      // Use the default profile image URL
      final String profileImageUrl = defaultProfileImageUrl;

      // Update profile data in Firebase Auth and Firestore
      await _persistUserProfileData(userId, username, profileImageUrl);

      // Update local state with success
      emit(state.copyWith(isInProgress: false, userProfilePhotoUrl: profileImageUrl));

      // Update auth session status
      await _authSessionCubit.completeProfileSetup(Future.value(profileImageUrl));

      // Reconnect to GetStream to sync the updated profile data
      await _reconnectToGetStream();

      return profileImageUrl;
    } catch (e) {
      debugPrint('Error creating profile: $e');
      emit(
        state.copyWith(
          isInProgress: false,
        ),
      );
      return '';
    }
  }

  /// Reconnects to GetStream to sync updated profile information
  Future<void> _reconnectToGetStream() async {
    try {
      // Disconnect first to ensure a clean reconnection
      await _chatRepository.disconnectUser();
      
      // Short delay to ensure disconnection completes
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Reconnect with the updated profile information
      final result = await _chatRepository.connectTheCurrentUser();
      
      result.fold(
        (failure) => debugPrint('Failed to reconnect to GetStream: $failure'),
        (_) => debugPrint('Successfully reconnected to GetStream with updated profile'),
      );
    } catch (e) {
      debugPrint('Error reconnecting to GetStream: $e');
    }
  }

  /// Updates user profile data in both Firebase Auth and Firestore
  ///
  /// Sets isOnboardingCompleted to true to mark completion of the onboarding process
  Future<void> _persistUserProfileData(String userId, String username, String profileImageUrl) async {
    try {
      await Future.wait([
        _authRepository.updateUserProfile(
          displayName: username,
          photoURL: profileImageUrl,
          isOnboardingCompleted: true,
        ),
        _firebaseFirestore.collection('users').doc(userId).set(
          {
            'photoUrl': profileImageUrl,
            'displayName': username,
            'isOnboardingCompleted': true,
            'lastUpdated': FieldValue.serverTimestamp(),
          },
          SetOptions(merge: true),
        ),
      ]);
    } catch (e) {
      debugPrint('Error updating user profile data: $e');
      throw Exception('Failed to update user profile data: $e');
    }
  }

  /// Retries profile creation after an error
  Future<String> retryProfileCreation() async {
    return createUserProfile();
  }

  /// Resets the state to its initial values
  void reset() {
    emit(ProfileManagerState.empty());
  }
}
