import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_social_chat/presentation/blocs/phone_number_sign_in/phone_number_sign_in_state.dart';
import 'package:flutter_social_chat/core/constants/enums/auth_failure_enum.dart';
import 'package:flutter_social_chat/core/interfaces/i_auth_repository.dart';
import 'package:fpdart/fpdart.dart';

class PhoneNumberSignInCubit extends Cubit<PhoneNumberSignInState> {
  /// Repository for authentication operations
  final IAuthRepository _authRepository;
  
  /// Subscription to track phone number sign-in process
  StreamSubscription<Either<AuthFailureEnum, (String, int?)>>? _phoneNumberSignInSubscription;

  /// Duration after which the verification code expires
  final Duration verificationCodeTimeout = const Duration(seconds: 60);

  /// Creates a new instance of [PhoneNumberSignInCubit]
  PhoneNumberSignInCubit(this._authRepository) : super(PhoneNumberSignInState.empty());

  /// Updates the phone number in the state
  /// 
  /// [phoneNumber] - The new phone number to set
  void phoneNumberChanged({required String phoneNumber}) {
    if (state.phoneNumber == phoneNumber) return;
    emit(state.copyWith(phoneNumber: phoneNumber, isPhoneNumberInputValidated: false));
  }

  /// Updates the validation status for the phone number input
  /// 
  /// [isPhoneNumberInputValidated] - Whether the phone number is valid
  void updateNextButtonStatus({required bool isPhoneNumberInputValidated}) {
    if (state.isPhoneNumberInputValidated == isPhoneNumberInputValidated) return;
    emit(state.copyWith(isPhoneNumberInputValidated: isPhoneNumberInputValidated));
  }

  /// Updates the SMS verification code in the state
  /// 
  /// [smsCode] - The verification code entered by the user
  void smsCodeChanged({required String smsCode}) {
    if (state.smsCode == smsCode) return;
    emit(state.copyWith(smsCode: smsCode));
  }

  /// Updates the navigation flag indicating if the user has navigated to verification screen
  /// 
  /// [hasNavigated] - Whether navigation has occurred
  void updateNavigationFlag({required bool hasNavigated}) {
    emit(state.copyWith(hasNavigatedToVerification: hasNavigated));
  }

  /// Resets only the error state while keeping other state values
  void resetErrorOnly() {
    emit(state.copyWith(failureMessageOption: none(), isInProgress: false));
  }

  /// Resets the state to prepare for a new authentication attempt
  void reset() {
    emit(
      state.copyWith(
        failureMessageOption: none(),
        verificationIdOption: none(),
        smsCode: '',
        isInProgress: false,
        hasNavigatedToVerification: false,
      ),
    );
  }

  /// Resends the verification code to the user's phone number
  void resendCode() {
    if (state.isInProgress || state.phoneNumber.isEmpty) return;

    emit(state.copyWith(isInProgress: true, failureMessageOption: none(), smsCode: ''));

    _cancelSubscription();

    _initiatePhoneAuth(
      phoneNumber: state.phoneNumber,
      resendToken: state.phoneNumberAndResendTokenPair.$2,
      isResend: true,
    );
    
    // Add a safety timer to ensure isInProgress is reset after a max timeout
    // This prevents the loading indicator from getting stuck
    Future.delayed(const Duration(seconds: 10), () {
      if (isClosed) return;
      if (state.isInProgress) {
        debugPrint('Safety timer fired for resendCode - resetting isInProgress');
        emit(state.copyWith(isInProgress: false));
      }
    });
  }

  /// Verifies the SMS code entered by the user
  void verifySmsCode() {
    if (state.isInProgress) return;

    state.verificationIdOption.fold(
      () {
        // Verification id does not exist. This should not happen.
        emit(state.copyWith(failureMessageOption: some(AuthFailureEnum.sessionExpired), isInProgress: false));
      },
      (String verificationId) async {
        emit(state.copyWith(isInProgress: true, failureMessageOption: none()));

        try {
          final Either<AuthFailureEnum, Unit> failureOrSuccess =
              await _authRepository.verifySmsCode(smsCode: state.smsCode, verificationId: verificationId);

          if (isClosed) return;

          failureOrSuccess.fold(
            (AuthFailureEnum failure) {
              emit(state.copyWith(failureMessageOption: some(failure), isInProgress: false));
            },
            (Unit _) {
              emit(state.copyWith(isInProgress: false));
            },
          );
        } catch (e) {
          _handleError('verifySmsCode', e);
        }
      },
    );
  }

  /// Initiates the phone number sign-in process
  void signInWithPhoneNumber() {
    if (state.isInProgress) return;

    emit(state.copyWith(isInProgress: true, failureMessageOption: none()));

    _cancelSubscription();

    final useResendToken = state.phoneNumber == state.phoneNumberAndResendTokenPair.$1;
    final resendToken = useResendToken ? state.phoneNumberAndResendTokenPair.$2 : null;

    _initiatePhoneAuth(
      phoneNumber: state.phoneNumber,
      resendToken: resendToken,
      isResend: false,
    );
  }

  /// Initiates the phone authentication process with the authentication repository
  /// 
  /// [phoneNumber] - The phone number to authenticate
  /// [resendToken] - Optional token used when resending codes
  /// [isResend] - Whether this is a resend operation
  void _initiatePhoneAuth({
    required String phoneNumber,
    int? resendToken,
    required bool isResend,
  }) {
    try {
      _phoneNumberSignInSubscription = _authRepository
          .signInWithPhoneNumber(
        phoneNumber: phoneNumber,
        timeout: verificationCodeTimeout,
        resendToken: resendToken,
      )
          .listen(
        (Either<AuthFailureEnum, (String, int?)> failureOrVerificationId) {
          if (isClosed) return;

          failureOrVerificationId.fold(
            (AuthFailureEnum failure) {
              emit(state.copyWith(failureMessageOption: some(failure), isInProgress: false));
            },
            ((String, int?) verificationIdResendTokenPair) {
              final verificationId = verificationIdResendTokenPair.$1;
              final newResendToken = verificationIdResendTokenPair.$2;

              // For resend operations, we keep the existing verification ID to prevent navigation
              final verificationIdOption =
                  isResend && state.verificationIdOption.isSome() ? state.verificationIdOption : some(verificationId);

              emit(
                state.copyWith(
                  verificationIdOption: verificationIdOption,
                  isInProgress: false,
                  isPhoneNumberInputValidated: true,
                  phoneNumberAndResendTokenPair: (phoneNumber, newResendToken),
                ),
              );
            },
          );
        },
        onError: (error) => _handleError('signInWithPhoneNumber', error),
        onDone: () {
          if (isResend && state.isInProgress) {
            emit(state.copyWith(isInProgress: false));
          }
        },
      );
    } catch (e) {
      _handleError('signInWithPhoneNumber', e);
    }
  }

  /// Handles errors that occur during authentication process
  /// 
  /// [source] - The method where the error occurred
  /// [error] - The error that occurred
  void _handleError(String source, dynamic error) {
    debugPrint('Error in $source: $error');
    if (!isClosed) {
      emit(state.copyWith(failureMessageOption: some(AuthFailureEnum.serverError), isInProgress: false));
    }
  }

  @override
  Future<void> close() async {
    await _cancelSubscription();
    return super.close();
  }

  /// Cancels the current phone number sign-in subscription
  Future<void> _cancelSubscription() async {
    await _phoneNumberSignInSubscription?.cancel();
    _phoneNumberSignInSubscription = null;
  }
}
