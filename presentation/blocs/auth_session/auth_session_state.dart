import 'package:equatable/equatable.dart';
import 'package:flutter_social_chat/domain/models/auth/auth_user_model.dart';

/// Represents the state of the user's authentication session
///
/// Contains information about the current user, whether they have been verified
/// with the authentication service, and the loading/error state of authentication operations.
class AuthSessionState extends Equatable {
  /// The currently authenticated user (or empty if not authenticated)
  final AuthUserModel authUser;

  /// Whether the user's authentication state has been verified with the auth service
  final bool isUserCheckedFromAuthService;

  /// Whether an authentication operation is currently in progress
  final bool isInProgress;

  /// Whether the last operation resulted in an error
  final bool hasError;

  const AuthSessionState({
    required this.authUser,
    required this.isUserCheckedFromAuthService,
    required this.isInProgress,
    this.hasError = false,
  });

  @override
  List<Object> get props => [authUser, isUserCheckedFromAuthService, isInProgress, hasError];

  /// Creates an empty state representing no authentication
  factory AuthSessionState.empty() => AuthSessionState(
        authUser: AuthUserModel.empty(),
        isUserCheckedFromAuthService: false,
        isInProgress: false,
      );

  /// Whether the user is currently logged in
  bool get isLoggedIn => authUser != AuthUserModel.empty();

  /// Creates a copy of this state with some fields replaced
  AuthSessionState copyWith({
    AuthUserModel? authUser,
    bool? isUserCheckedFromAuthService,
    bool? isInProgress,
    bool? hasError,
  }) {
    return AuthSessionState(
      authUser: authUser ?? this.authUser,
      isUserCheckedFromAuthService: isUserCheckedFromAuthService ?? this.isUserCheckedFromAuthService,
      isInProgress: isInProgress ?? this.isInProgress,
      hasError: hasError ?? this.hasError,
    );
  }
}
