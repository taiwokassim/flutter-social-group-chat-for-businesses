import 'dart:async';

import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:flutter_social_chat/core/interfaces/i_auth_repository.dart';
import 'package:flutter_social_chat/core/interfaces/i_chat_repository.dart';
import 'package:flutter_social_chat/domain/models/auth/auth_user_model.dart';
import 'package:flutter_social_chat/presentation/blocs/auth_session/auth_session_state.dart';
import 'package:flutter_social_chat/core/di/dependency_injector.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';

/// Manages the authentication session state of the application
/// using HydratedBloc for persistence between app restarts.
///
/// This cubit is responsible for:
/// 1. Tracking authentication state changes
/// 2. Connecting to Stream Chat service when authenticated
/// 3. Managing sign-out process
/// 4. Persisting authentication state across app restarts
/// 5. Handling profile setup and updates
class AuthSessionCubit extends HydratedCubit<AuthSessionState> {
  /// Creates a new instance of [AuthSessionCubit]
  AuthSessionCubit({
    required IAuthRepository authRepository,
    required IChatRepository chatRepository,
  })  : _authRepository = authRepository,
        _chatRepository = chatRepository,
        super(AuthSessionState.empty()) {
    _subscribeToAuthChanges();
  }

  final IAuthRepository _authRepository;
  final IChatRepository _chatRepository;
  StreamSubscription<AuthUserModel>? _authUserSubscription;

  /// Flag to prevent multiple simultaneous connection attempts
  bool _isConnecting = false;

  /// Subscribes to authentication state changes
  void _subscribeToAuthChanges() {
    _authUserSubscription = _authRepository.authStateChanges.listen(_handleAuthStateChanges);
  }

  @override
  Future<void> close() async {
    await _authUserSubscription?.cancel();
    _authUserSubscription = null;
    super.close();
  }

  //
  // Authentication Methods
  //

  /// Signs out the current user from both auth and chat services
  Future<void> signOut() async {
    // Prevent multiple simultaneous sign-out attempts
    if (state.isInProgress) return;

    emit(state.copyWith(isInProgress: true));

    try {
      // Sign out from auth service
      await _authRepository.signOut();

      // Clean up auth state subscription
      await _cleanupSubscriptions();

      // Reset state to empty but preserve authentication check flag
      _resetToSignedOutState();

      // Clear persisted data
      await _clearPersistedData();

      // Reattach the auth state listener
      _subscribeToAuthChanges();
    } catch (e) {
      // Even on error, reset to signed out state to prevent being stuck
      _resetToSignedOutState(hasError: true);

      // Reattach the auth state listener
      _subscribeToAuthChanges();
    }
  }

  /// Cleans up auth state subscription
  Future<void> _cleanupSubscriptions() async {
    await _authUserSubscription?.cancel();
    _authUserSubscription = null;
  }

  /// Resets state to empty signed-out state
  void _resetToSignedOutState({bool hasError = false}) {
    emit(
      AuthSessionState.empty().copyWith(
        isInProgress: false,
        isUserCheckedFromAuthService: true,
        hasError: hasError,
      ),
    );
  }

  /// Clears persisted authentication data
  Future<void> _clearPersistedData() async {
    try {
      await HydratedBloc.storage.delete(storageToken);
    } catch (e) {
      // Continue even if storage deletion fails
    }
  }

  /// Handles authentication state changes by connecting to chat service when logged in
  Future<void> _handleAuthStateChanges(AuthUserModel authUser) async {
    emit(state.copyWith(isInProgress: true, authUser: authUser, isUserCheckedFromAuthService: true));

    // If user is signed out, update state and return
    if (authUser == AuthUserModel.empty()) {
      emit(state.copyWith(isInProgress: false));
      return;
    }

    // If user is signed in, connect to chat service
    await _connectToChatService(authUser);
  }

  /// Connects to Stream Chat service using the authenticated user
  Future<void> _connectToChatService(AuthUserModel authUser) async {
    // Prevent multiple simultaneous connection attempts
    if (_isConnecting) return;

    _isConnecting = true;

    try {
      final result = await _chatRepository.connectTheCurrentUser();

      result.fold(
        (failure) {
          // Try one more time before failing
          _retryConnectToChatService(authUser);
        },
        (_) => emit(
          state.copyWith(
            authUser: authUser,
            isInProgress: false,
          ),
        ),
      );
    } catch (e) {
      // Try one more time before failing
      _retryConnectToChatService(authUser);
    } finally {
      _isConnecting = false;
    }
  }

  /// Attempts to reconnect to the chat service one more time before failing
  Future<void> _retryConnectToChatService(AuthUserModel authUser) async {
    try {
      // Add a small delay before retry
      await Future.delayed(const Duration(seconds: 1));

      final result = await _chatRepository.connectTheCurrentUser();

      result.fold(
        (failure) {
          emit(
            state.copyWith(
              authUser: authUser,
              isInProgress: false,
              hasError: true,
            ),
          );
        },
        (_) {
          emit(
            state.copyWith(
              authUser: authUser,
              isInProgress: false,
            ),
          );
        },
      );
    } catch (e) {
      emit(
        state.copyWith(
          authUser: authUser,
          isInProgress: false,
          hasError: true,
        ),
      );
    }
  }

  /// Reconnects to chat service if the connection is lost
  /// This should be called when the app detects a missing chat connection
  Future<void> reconnectToChatService() async {
    if (!state.isLoggedIn) return;

    // Prevent multiple simultaneous reconnection attempts
    if (_isConnecting) return;

    _isConnecting = true;

    try {
      // First check if already connected but state doesn't reflect it
      if (await _isStreamChatAlreadyConnected()) {
        emit(state.copyWith(isInProgress: false));
        _isConnecting = false;
        return;
      }

      // If not connected, start reconnection process
      emit(state.copyWith(isInProgress: true));

      final result = await _chatRepository.connectTheCurrentUser();

      result.fold(
        (failure) {
          // Check if failure is because connection is already in progress
          if (_isAlreadyConnectingError(failure)) {
            emit(state.copyWith(isInProgress: false));
          } else {
            emit(state.copyWith(isInProgress: false, hasError: true));
          }
        },
        (_) {
          emit(state.copyWith(isInProgress: false));
        },
      );
    } catch (e) {
      // Ensure UI doesn't get stuck in loading state
      emit(state.copyWith(isInProgress: false, hasError: true));
    } finally {
      _isConnecting = false;
    }
  }

  /// Checks if Stream Chat is already connected
  Future<bool> _isStreamChatAlreadyConnected() async {
    try {
      final client = getIt<StreamChatClient>();
      return client.state.currentUser != null;
    } catch (e) {
      return false;
    }
  }

  /// Determines if an error is due to a connection already in progress
  bool _isAlreadyConnectingError(Object failure) {
    return failure.toString().contains('User already getting connected');
  }

  //
  // Profile Update Methods
  //

  /// Updates the user's display name in the local state
  void changeUserName({required String userName}) {
    if (userName.isEmpty) return;

    emit(
      state.copyWith(
        authUser: state.authUser.copyWith(userName: userName),
      ),
    );
  }

  /// Completes profile setup with the provided profile photo URL
  Future<void> completeProfileSetup(Future<String> getProfilePhotoUrl) async {
    emit(state.copyWith(isInProgress: true));

    try {
      final userProfilePhotoUrl = await getProfilePhotoUrl;

      if (userProfilePhotoUrl.isEmpty) {
        emit(state.copyWith(isInProgress: false));
        return;
      }

      emit(
        state.copyWith(
          isInProgress: false,
          authUser: state.authUser.copyWith(
            photoUrl: userProfilePhotoUrl,
            isOnboardingCompleted: true,
          ),
        ),
      );
    } catch (e) {
      emit(state.copyWith(isInProgress: false, hasError: true));
    }
  }

  //
  // State Persistence Methods
  //

  @override
  Map<String, dynamic> toJson(AuthSessionState state) {
    return {
      'authUser': state.authUser.toJson(),
      'isUserCheckedFromAuthService': state.isUserCheckedFromAuthService,
    };
  }

  @override
  AuthSessionState? fromJson(Map<String, dynamic> json) {
    try {
      // Create a base state from the cached data
      final cachedState = AuthSessionState.empty().copyWith(
        authUser: AuthUserModel.fromJson(json['authUser'] as Map<String, dynamic>),
        isUserCheckedFromAuthService: json['isUserCheckedFromAuthService'] as bool? ?? false,
      );

      // If the user is logged in according to cached data, verify with repository
      if (cachedState.isLoggedIn) {
        _verifyUserSession(cachedState);
      }

      return cachedState;
    } catch (e) {
      return AuthSessionState.empty();
    }
  }

  /// Verifies the user session against the repository
  /// This is used during hydration to ensure cached data is still valid
  void _verifyUserSession(AuthSessionState cachedState) {
    // We don't await here intentionally - returning initial state from cache
    // while the auth stream will update with fresh data
    _authRepository.getSignedInUser().then((userOption) {
      userOption.fold(
        () => emit(AuthSessionState.empty().copyWith(isUserCheckedFromAuthService: true)),
        (latestUserData) => emit(cachedState.copyWith(authUser: latestUserData)),
      );
    });
  }
}
