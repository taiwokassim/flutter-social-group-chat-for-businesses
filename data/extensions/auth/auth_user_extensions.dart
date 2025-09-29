import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_social_chat/domain/models/auth/auth_user_model.dart';

/// Extension to convert Firebase User to our domain model
extension AuthUserMapperExtensions on User {
  /// Converts a Firebase User to an AuthUserModel
  /// Note: isOnboardingCompleted is set to false by default and should be
  /// updated with the value from Firestore
  AuthUserModel toDomain() {
    return AuthUserModel(
      id: uid,
      phoneNumber: phoneNumber ?? '',
      photoUrl: photoURL,
      userName: displayName,
      isOnboardingCompleted: false,
    );
  }
}
