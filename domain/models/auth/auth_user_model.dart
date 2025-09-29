import 'package:equatable/equatable.dart';

/// Model representing a user's authentication and profile information
/// 
/// This model is used throughout the application to represent the current user's
/// state, including their authentication status and profile information.
class AuthUserModel extends Equatable {
  /// Unique identifier for the user
  final String id;
  
  /// User's phone number (used for authentication)
  final String phoneNumber;
  
  /// Whether the user has completed the onboarding process
  final bool isOnboardingCompleted;
  
  /// User's display name (null if not set)
  final String? userName;
  
  /// URL to the user's profile photo (null if not set)
  final String? photoUrl;

  const AuthUserModel({
    required this.id,
    required this.phoneNumber,
    required this.isOnboardingCompleted,
    this.userName,
    this.photoUrl,
  });

  @override
  List<Object?> get props => [id, phoneNumber, isOnboardingCompleted, userName, photoUrl];

  /// Creates an empty user model representing an unauthenticated state
  factory AuthUserModel.empty() => const AuthUserModel(
        id: '',
        phoneNumber: '',
        isOnboardingCompleted: false,
        userName: '',
        photoUrl: '',
      );
      
  /// Checks if this is a valid authenticated user
  bool get isAuthenticated => id.isNotEmpty && phoneNumber.isNotEmpty;
  
  /// Checks if the user has a complete profile
  bool get hasCompleteProfile => isAuthenticated && userName != null && userName!.isNotEmpty && photoUrl != null && photoUrl!.isNotEmpty;

  /// Creates a copy of this model with some fields replaced
  AuthUserModel copyWith({
    String? id,
    String? phoneNumber,
    bool? isOnboardingCompleted,
    String? userName,
    String? photoUrl,
  }) {
    return AuthUserModel(
      id: id ?? this.id,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      isOnboardingCompleted: isOnboardingCompleted ?? this.isOnboardingCompleted,
      userName: userName ?? this.userName,
      photoUrl: photoUrl ?? this.photoUrl,
    );
  }

  /// Converts the model to JSON
  Map<String, dynamic> toJson() => {
        'id': id,
        'phoneNumber': phoneNumber,
        'isOnboardingCompleted': isOnboardingCompleted,
        'userName': userName,
        'photoUrl': photoUrl,
      };

  /// Creates a model from JSON data
  factory AuthUserModel.fromJson(Map<String, dynamic> json) => AuthUserModel(
        id: json['id'] as String? ?? '',
        phoneNumber: json['phoneNumber'] as String? ?? '',
        isOnboardingCompleted: json['isOnboardingCompleted'] as bool? ?? false,
        userName: json['userName'] as String?,
        photoUrl: json['photoUrl'] as String?,
      );
}
