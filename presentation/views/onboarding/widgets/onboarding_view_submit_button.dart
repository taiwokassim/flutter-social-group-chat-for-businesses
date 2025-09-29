import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_social_chat/presentation/blocs/profile_management/profile_manager_cubit.dart';
import 'package:flutter_social_chat/presentation/blocs/profile_management/profile_manager_state.dart';
import 'package:flutter_social_chat/presentation/design_system/widgets/animated_gradient_button.dart';

/// Button used to submit the onboarding form and create the user profile
///
/// This button is enabled only when the username is valid.
/// When pressed, it triggers the profile creation process through the ProfileManagerCubit.
class OnboardingViewSubmitButton extends StatelessWidget {
  const OnboardingViewSubmitButton({super.key});

  @override
  Widget build(BuildContext context) {
    final appLocalizations = AppLocalizations.of(context);

    return BlocBuilder<ProfileManagerCubit, ProfileManagerState>(
      buildWhen: (previous, current) => previous.isUserNameValid != current.isUserNameValid,
      builder: (context, state) {
        return AnimatedGradientButton(
          text: appLocalizations?.createYourProfile ?? '',
          onPressed: state.isUserNameValid ? () => _handleSubmit(context) : null,
          isEnabled: state.isUserNameValid,
          height: 56,
          borderRadius: 14,
        );
      },
    );
  }

  /// Handles the submit button press by triggering profile creation
  ///
  /// The ProfileManagerCubit handles:
  /// 1. Creating the user profile in the database
  /// 2. Updating the AuthSessionCubit to reflect the completed onboarding
  /// 3. Reconnecting to chat services with the new profile data
  void _handleSubmit(BuildContext context) {
    context.read<ProfileManagerCubit>().createUserProfile();
  }
}
