import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_social_chat/presentation/blocs/profile_management/profile_manager_cubit.dart';
import 'package:flutter_social_chat/presentation/blocs/profile_management/profile_manager_state.dart';
import 'package:flutter_social_chat/presentation/blocs/auth_session/auth_session_cubit.dart';
import 'package:flutter_social_chat/presentation/design_system/colors.dart';
import 'package:flutter_social_chat/presentation/design_system/styles/input_styles.dart';
import 'package:flutter_social_chat/presentation/design_system/widgets/custom_text.dart';

/// Form field for username input with validation
///
/// Validates that the username:
/// - Is between 3 and 20 characters
/// - Only contains letters, numbers, underscores, and hyphens
class OnboardingViewUsernameFormField extends StatelessWidget {
  const OnboardingViewUsernameFormField({super.key});

  // Username validation regex - only allows letters, numbers, underscores and hyphens
  static final RegExp _usernameRegExp = RegExp(r'^[a-zA-Z0-9_\-]+$');

  @override
  Widget build(BuildContext context) {
    final appLocalizations = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        BlocSelector<ProfileManagerCubit, ProfileManagerState, bool>(
          selector: (state) => state.isUserNameValid,
          builder: (context, isUserNameValid) {
            return TextFormField(
              onChanged: (userName) {
                context.read<AuthSessionCubit>().changeUserName(userName: userName);
                _validateUsername(context, userName);
              },
              validator: (userName) => _getValidationMessage(context, userName),
              style: const TextStyle(
                color: customGreyColor600,
                fontSize: 16,
              ),
              decoration: InputStyles.baseOutlineDecoration.copyWith(
                hintText: appLocalizations?.username ?? '',
                hintStyle: const TextStyle(
                  color: customGreyColor400,
                  fontWeight: FontWeight.normal,
                ),
                prefixIcon: const Icon(
                  Icons.person_outline,
                  color: customIndigoColor,
                  size: 22,
                ),
                suffixIcon: isUserNameValid ? const Icon(Icons.check_circle, color: successColor, size: 22) : null,
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 14.0,
                  horizontal: 16.0,
                ),
                enabledBorder: InputStyles.createOutlineBorder(
                  color: isUserNameValid ? successColor : customGreyColor400,
                  width: 1.5,
                  radius: 12,
                ),
                focusedBorder: InputStyles.createOutlineBorder(
                  color: isUserNameValid ? successColor : customIndigoColor,
                  width: 1.5,
                  radius: 12,
                ),
                border: InputStyles.createOutlineBorder(radius: 12),
              ),
            );
          },
        ),
        Padding(
          padding: const EdgeInsets.only(top: 8.0, left: 8.0, right: 8.0),
          child: CustomText(
            text: appLocalizations?.usernameValidationMessage ?? '',
            color: customGreyColor500,
            fontSize: 12,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  /// Updates the username validity in the ProfileManagerCubit
  void _validateUsername(BuildContext context, String? userName) {
    final bool isValid = _isUsernameValid(userName);
    context.read<ProfileManagerCubit>().updateUsernameValidity(isValid: isValid);
  }

  /// Checks if the username meets all validation criteria
  bool _isUsernameValid(String? userName) {
    if (userName == null || userName.isEmpty) {
      return false;
    }

    final bool isValidLength = userName.length >= 3 && userName.length <= 20;
    final bool hasValidCharacters = _usernameRegExp.hasMatch(userName);

    return isValidLength && hasValidCharacters;
  }

  /// Returns a specific validation error message based on the validation failure
  String? _getValidationMessage(BuildContext context, String? userName) {
    final appLocalizations = AppLocalizations.of(context);

    if (userName == null || userName.isEmpty) {
      return null;
    }

    if (userName.length > 20) {
      return appLocalizations?.userNameCanNotBeLongerThanTwentyCharacters ?? '';
    } else if (userName.length < 3) {
      return appLocalizations?.userNameCanNotBeShorterThanThreeCharacters ?? '';
    } else if (!_usernameRegExp.hasMatch(userName)) {
      return appLocalizations?.invalidUsername ?? '';
    }

    return null;
  }
}
