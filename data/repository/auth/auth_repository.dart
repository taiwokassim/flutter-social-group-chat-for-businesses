import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_social_chat/core/constants/enums/auth_failure_enum.dart';
import 'package:flutter_social_chat/domain/models/auth/auth_user_model.dart';
import 'package:flutter_social_chat/core/interfaces/i_auth_repository.dart';
import 'package:flutter_social_chat/data/extensions/auth/auth_user_extensions.dart';
import 'package:fpdart/fpdart.dart';

class AuthRepository implements IAuthRepository {
  AuthRepository(this._firebaseAuth, this._firestore) {
    // Disable verification for testing purposes
    // This will disable reCAPTCHA for phone auth verification
    // Only use this for development, not in production
    _firebaseAuth.setSettings(
      appVerificationDisabledForTesting: true,
      phoneNumber: '+905555555555',
      smsCode: '111111',
    );
  }

  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;

  @override
  Stream<AuthUserModel> get authStateChanges {
    return _firebaseAuth.authStateChanges().asyncMap((User? user) async {
      if (user == null) return AuthUserModel.empty();
      
      // Get the base user model from Firebase Auth
      final baseUserModel = user.toDomain();
      
      try {
        // Fetch the user document from Firestore to get isOnboardingCompleted
        final userDoc = await _firestore.collection('users').doc(user.uid).get();
        
        if (userDoc.exists) {
          final userData = userDoc.data();
          final bool isOnboardingCompleted = userData?['isOnboardingCompleted'] as bool? ?? false;
          
          // Return user model with the correct isOnboardingCompleted value from Firestore
          return baseUserModel.copyWith(isOnboardingCompleted: isOnboardingCompleted);
        }
      } catch (e) {
        debugPrint('Error fetching user data from Firestore: $e');
      }
      
      // If Firestore fetch fails, return the base model
      return baseUserModel;
    });
  }

  @override
  Future<Option<AuthUserModel>> getSignedInUser() async {
    final user = _firebaseAuth.currentUser;
    if (user == null) return none();
    
    try {
      final baseUserModel = user.toDomain();
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      
      if (userDoc.exists) {
        final userData = userDoc.data();
        final bool isOnboardingCompleted = userData?['isOnboardingCompleted'] as bool? ?? false;
        return some(baseUserModel.copyWith(isOnboardingCompleted: isOnboardingCompleted));
      }
      
      return some(baseUserModel);
    } catch (e) {
      debugPrint('Error getting signed in user data: $e');
      return optionOf(user.toDomain());
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
    } catch (e) {
      debugPrint('Error signing out: $e');
      // We don't rethrow, as signOut should be a silent operation that doesn't fail
    }
  }

  @override
  Stream<Either<AuthFailureEnum, (String, int?)>> signInWithPhoneNumber({
    required String phoneNumber,
    required Duration timeout,
    required int? resendToken,
  }) async* {
    final StreamController<Either<AuthFailureEnum, (String, int?)>> streamController =
        StreamController<Either<AuthFailureEnum, (String, int?)>>();

    // Add cleanup to prevent memory leaks
    Future<void> cleanUp() async {
      if (!streamController.isClosed) {
        await streamController.close();
      }
    }

    // Ensure cleanup when the stream is no longer listened to
    streamController.onCancel = cleanUp;

    try {
      // Configure Firebase Auth for iOS to improve Safari compatibility
      _firebaseAuth.setLanguageCode('en');

      await _firebaseAuth.verifyPhoneNumber(
        forceResendingToken: resendToken,
        timeout: timeout,
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          // Android Only - auto verification
          try {
            await _firebaseAuth.signInWithCredential(credential);
          } catch (e) {
            debugPrint('Auto verification failed: $e');
            streamController.add(left(AuthFailureEnum.serverError));
          }
        },
        codeSent: (String verificationId, int? resendToken) async {
          final resendMessage = resendToken != null ? ' (RESEND)' : '';
          debugPrint('SMS code sent successfully$resendMessage, verification ID: $verificationId');
          streamController.add(right((verificationId, resendToken)));
          
          // Ensure stream completes after delivering results for resend
          if (resendToken != null) {
            debugPrint('Completing resend code stream');
            await Future.delayed(const Duration(milliseconds: 100));
            await cleanUp();
          }
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          debugPrint('SMS code auto retrieval timed out');
          // Only add timeout if stream is still being listened to
          if (!streamController.isClosed) {
            streamController.add(left(AuthFailureEnum.smsTimeout));
          }
        },
        verificationFailed: (FirebaseAuthException e) {
          debugPrint('Phone verification failed: ${e.code} - ${e.message}');
          late final Either<AuthFailureEnum, (String, int?)> result;

          switch (e.code) {
            case 'too-many-requests':
              result = left(AuthFailureEnum.tooManyRequests);
              break;
            case 'app-not-authorized':
              result = left(AuthFailureEnum.deviceNotSupported);
              break;
            case 'invalid-phone-number':
              result = left(AuthFailureEnum.serverError);
              break;
            case 'captcha-check-failed':
              // This error occurs when reCAPTCHA verification fails
              result = left(AuthFailureEnum.serverError);
              break;
            default:
              result = left(AuthFailureEnum.serverError);
          }

          streamController.add(result);
        },
      );
    } catch (e) {
      debugPrint('Unexpected error in signInWithPhoneNumber: $e');
      streamController.add(left(AuthFailureEnum.serverError));
    }

    yield* streamController.stream;
  }

  @override
  Future<void> updateDisplayName({required String displayName}) async {
    final user = _firebaseAuth.currentUser;
    if (user == null) return;

    await user.updateDisplayName(displayName);
    await _updateUserDataInFirestore({'userName': displayName});
  }

  @override
  Future<void> updatePhotoURL({required String photoURL}) async {
    final user = _firebaseAuth.currentUser;
    if (user == null) return;

    await user.updatePhotoURL(photoURL);
    await _updateUserDataInFirestore({'photoUrl': photoURL});
  }

  @override
  Future<void> updateUserProfile({
    String? displayName,
    String? photoURL,
    bool? isOnboardingCompleted,
  }) async {
    final user = _firebaseAuth.currentUser;
    if (user == null) return;

    final Map<String, dynamic> firestoreData = {};

    if (displayName != null) {
      await user.updateDisplayName(displayName);
      firestoreData['userName'] = displayName;
    }

    if (photoURL != null) {
      await user.updatePhotoURL(photoURL);
      firestoreData['photoUrl'] = photoURL;
    }

    if (isOnboardingCompleted != null) {
      firestoreData['isOnboardingCompleted'] = isOnboardingCompleted;
    }

    if (firestoreData.isNotEmpty) {
      await _updateUserDataInFirestore(firestoreData);
    }
  }

  Future<void> _updateUserDataInFirestore(Map<String, dynamic> data) async {
    final user = _firebaseAuth.currentUser;
    if (user == null) return;

    final userDoc = _firestore.collection('users').doc(user.uid);

    try {
      // Optimized: Use transaction to ensure atomic operations
      await _firestore.runTransaction((transaction) async {
        final docSnapshot = await transaction.get(userDoc);

        if (docSnapshot.exists) {
          transaction.update(userDoc, data);
        } else {
          // Include required fields if creating a new document
          final completeData = {
            'userName': user.displayName ?? 'User',
            'phoneNumber': user.phoneNumber ?? '',
            'isOnboardingCompleted': false,
            'createdAt': FieldValue.serverTimestamp(),
            ...data,
          };
          transaction.set(userDoc, completeData);
        }
      });
    } catch (e) {
      debugPrint('Error updating Firestore data: $e');
    }
  }

  @override
  Future<Either<AuthFailureEnum, Unit>> verifySmsCode({
    required String smsCode,
    required String verificationId,
  }) async {
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );

      await _firebaseAuth.signInWithCredential(credential);

      // Create or update the user document
      final user = _firebaseAuth.currentUser;
      if (user != null) {
        // First check if the user document already exists
        final userDoc = _firestore.collection('users').doc(user.uid);
        final docSnapshot = await userDoc.get();
        
        if (docSnapshot.exists) {
          // User exists, only update lastLogin
          await userDoc.update({
            'lastLogin': FieldValue.serverTimestamp(),
          });
        } else {
          // New user, create a document with isOnboardingCompleted = false
          await userDoc.set({
            'userName': user.displayName ?? 'User',
            'phoneNumber': user.phoneNumber ?? '',
            'isOnboardingCompleted': false,
            'createdAt': FieldValue.serverTimestamp(),
            'lastLogin': FieldValue.serverTimestamp(),
          });
        }
      }

      return right(unit);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'session-expired') {
        return left(AuthFailureEnum.sessionExpired);
      } else if (e.code == 'invalid-verification-code') {
        return left(AuthFailureEnum.invalidVerificationCode);
      }
      return left(AuthFailureEnum.serverError);
    } catch (e) {
      debugPrint('Unexpected error during SMS verification: $e');
      return left(AuthFailureEnum.serverError);
    }
  }
}
