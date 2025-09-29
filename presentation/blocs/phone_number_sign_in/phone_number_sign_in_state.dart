import 'package:equatable/equatable.dart';
import 'package:flutter_social_chat/core/constants/enums/auth_failure_enum.dart';
import 'package:fpdart/fpdart.dart';

class PhoneNumberSignInState extends Equatable {
  const PhoneNumberSignInState({
    this.phoneNumber = '',
    this.smsCode = '',
    this.verificationIdOption = const None(),
    this.failureMessageOption = const None(),
    this.isInProgress = false,
    this.isPhoneNumberInputValidated = false,
    this.phoneNumberAndResendTokenPair = const ('', null),
    this.hasNavigatedToVerification = false,
  });

  final String phoneNumber;
  final String smsCode;
  final Option<String> verificationIdOption;
  final Option<AuthFailureEnum> failureMessageOption;
  final bool isInProgress;
  final bool isPhoneNumberInputValidated;
  final bool hasNavigatedToVerification;
  final (String, int?) phoneNumberAndResendTokenPair;

  @override
  List<Object?> get props => [
        phoneNumber,
        smsCode,
        verificationIdOption,
        failureMessageOption,
        isInProgress,
        isPhoneNumberInputValidated,
        phoneNumberAndResendTokenPair,
        hasNavigatedToVerification,
      ];

  factory PhoneNumberSignInState.empty() => const PhoneNumberSignInState();

  PhoneNumberSignInState copyWith({
    String? phoneNumber,
    String? smsCode,
    Option<String>? verificationIdOption,
    Option<AuthFailureEnum>? failureMessageOption,
    bool? isInProgress,
    bool? isPhoneNumberInputValidated,
    (String, int?)? phoneNumberAndResendTokenPair,
    bool? hasNavigatedToVerification,
  }) {
    return PhoneNumberSignInState(
      phoneNumber: phoneNumber ?? this.phoneNumber,
      smsCode: smsCode ?? this.smsCode,
      verificationIdOption: verificationIdOption ?? this.verificationIdOption,
      failureMessageOption: failureMessageOption ?? this.failureMessageOption,
      isInProgress: isInProgress ?? this.isInProgress,
      isPhoneNumberInputValidated: isPhoneNumberInputValidated ?? this.isPhoneNumberInputValidated,
      phoneNumberAndResendTokenPair: phoneNumberAndResendTokenPair ?? this.phoneNumberAndResendTokenPair,
      hasNavigatedToVerification: hasNavigatedToVerification ?? this.hasNavigatedToVerification,
    );
  }

  factory PhoneNumberSignInState.fromJson(Map<String, dynamic> json) {
    final verificationId = json['verificationId'] as String?;

    return PhoneNumberSignInState(
      phoneNumber: json['phoneNumber'] as String? ?? '',
      smsCode: json['smsCode'] as String? ?? '',
      verificationIdOption: verificationId != null ? some(verificationId) : none(),
      isInProgress: json['isInProgress'] as bool? ?? false,
      isPhoneNumberInputValidated: json['isPhoneNumberInputValidated'] as bool? ?? false,
      phoneNumberAndResendTokenPair: (
        json['phoneNumberPair'] as String? ?? '',
        json['resendToken'] as int?,
      ),
      hasNavigatedToVerification: json['hasNavigatedToVerification'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    String? verificationId;
    verificationIdOption.fold(
      () => verificationId = null,
      (id) => verificationId = id,
    );

    return {
      'phoneNumber': phoneNumber,
      'smsCode': smsCode,
      'verificationId': verificationId,
      'isInProgress': isInProgress,
      'isPhoneNumberInputValidated': isPhoneNumberInputValidated,
      'phoneNumberPair': phoneNumberAndResendTokenPair.$1,
      'resendToken': phoneNumberAndResendTokenPair.$2,
      'hasNavigatedToVerification': hasNavigatedToVerification,
    };
  }
}
