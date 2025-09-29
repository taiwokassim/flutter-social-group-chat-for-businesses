import 'package:flutter_social_chat/core/constants/enums/auth_failure_enum.dart';
import 'package:flutter_social_chat/domain/models/auth/auth_user_model.dart';
import 'package:fpdart/fpdart.dart';

abstract class IAuthRepository {
  Stream<AuthUserModel> get authStateChanges;

  Future<Option<AuthUserModel>> getSignedInUser();

  Future<void> signOut();

  Stream<Either<AuthFailureEnum, (String, int?)>> signInWithPhoneNumber({
    required String phoneNumber,
    required Duration timeout,
    required int? resendToken,
  });

  Future<Either<AuthFailureEnum, Unit>> verifySmsCode({
    required String smsCode,
    required String verificationId,
  });

  Future<void> updateDisplayName({required String displayName});

  Future<void> updatePhotoURL({required String photoURL});
  
  Future<void> updateUserProfile({
    String? displayName,
    String? photoURL,
    bool? isOnboardingCompleted,
  });
}
