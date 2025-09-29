import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_social_chat/presentation/blocs/phone_number_sign_in/phone_number_sign_in_cubit.dart';
import 'package:flutter_social_chat/presentation/blocs/phone_number_sign_in/phone_number_sign_in_state.dart';
import 'package:flutter_social_chat/presentation/design_system/colors.dart';
import 'package:flutter_social_chat/presentation/design_system/styles/input_styles.dart';
import 'package:flutter_social_chat/presentation/design_system/widgets/custom_text.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';

/// Widget for handling phone number input with validation
class SignInViewInputField extends StatefulWidget {
  const SignInViewInputField({super.key, required this.state});

  final PhoneNumberSignInState state;

  @override
  State<SignInViewInputField> createState() => _SignInViewInputFieldState();
}

class _SignInViewInputFieldState extends State<SignInViewInputField> {
  // Constants
  final PhoneNumber initialPhone = PhoneNumber(isoCode: 'TR');
  final TextEditingController _phoneController = TextEditingController();
  bool _hasAttemptedValidation = false;
  bool _isInputValid = true;
  String _errorText = '';

  @override
  void initState() {
    super.initState();
    _initializePhoneNumber();
  }

  void _initializePhoneNumber() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<PhoneNumberSignInCubit>().phoneNumberChanged(phoneNumber: initialPhone.phoneNumber ?? '');
      }
    });
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final String hintText = AppLocalizations.of(context)?.phoneNumber ?? '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Theme(
            data: Theme.of(context).copyWith(splashColor: transparent, highlightColor: transparent),
            child: InternationalPhoneNumberInput(
              textFieldController: _phoneController,
              onInputChanged: _handlePhoneNumberChange,
              onInputValidated: _handleValidationChange,
              spaceBetweenSelectorAndTextField: 0,
              selectorButtonOnErrorPadding: 0,
              inputDecoration: InputStyles.phoneNumberInputDecoration(hintText: hintText),
              selectorConfig: const SelectorConfig(
                selectorType: PhoneInputSelectorType.BOTTOM_SHEET,
                useBottomSheetSafeArea: true,
                setSelectorButtonAsPrefixIcon: true,
              ),
              textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: black),
              autoValidateMode: AutovalidateMode.onUserInteraction,
              initialValue: initialPhone,
              inputBorder: InputBorder.none,
              cursorColor: customIndigoColor,
              keyboardType: TextInputType.number,
              validator: (_) {
                _updateErrorText();
                return null;
              },
            ),
          ),
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          child: _hasAttemptedValidation && !_isInputValid
              ? Padding(
                  padding: const EdgeInsets.only(left: 24, top: 4),
                  child: CustomText(text: _errorText, color: errorColor, fontSize: 12, fontWeight: FontWeight.w400),
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }

  void _handlePhoneNumberChange(PhoneNumber phoneNumber) {
    final newPhoneNumber = phoneNumber.phoneNumber ?? '';

    if (widget.state.phoneNumber != newPhoneNumber) {
      context.read<PhoneNumberSignInCubit>().phoneNumberChanged(phoneNumber: newPhoneNumber);
    }

    if (newPhoneNumber.isNotEmpty && !_hasAttemptedValidation) {
      setState(() {
        _hasAttemptedValidation = true;
      });
    }
  }

  void _handleValidationChange(bool isPhoneNumberInputValidated) {
    if (_isInputValid != isPhoneNumberInputValidated) {
      setState(() {
        _isInputValid = isPhoneNumberInputValidated;
        _updateErrorText();
      });

      if (widget.state.isPhoneNumberInputValidated != isPhoneNumberInputValidated) {
        context.read<PhoneNumberSignInCubit>().updateNextButtonStatus(
              isPhoneNumberInputValidated: isPhoneNumberInputValidated,
            );
      }
    }
  }

  void _updateErrorText() {
    final localizations = AppLocalizations.of(context);

    if (_phoneController.text.isEmpty) {
      _errorText = localizations?.phoneNumberRequired ?? '';
    } else if (!_isInputValid) {
      _errorText = localizations?.invalidPhoneNumber ?? '';
    } else {
      _errorText = '';
    }
  }
}
