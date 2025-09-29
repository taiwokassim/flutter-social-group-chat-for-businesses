import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_social_chat/presentation/blocs/phone_number_sign_in/phone_number_sign_in_cubit.dart';
import 'package:flutter_social_chat/presentation/blocs/phone_number_sign_in/phone_number_sign_in_state.dart';
import 'package:flutter_social_chat/presentation/design_system/colors.dart';
import 'package:flutter_social_chat/presentation/design_system/widgets/animated_gradient_button.dart';
import 'package:flutter_social_chat/presentation/design_system/widgets/custom_text.dart';
import 'package:flutter_social_chat/presentation/views/sign_in/widgets/sign_in_view_input_field.dart';

/// Card component that contains the phone number input form
class SignInViewInputCard extends StatelessWidget {
  const SignInViewInputCard({super.key});

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.sizeOf(context);
    final localizations = AppLocalizations.of(context);

    final String signInWithPhoneNumber = localizations?.signInWithPhoneNumber ?? '';
    final String smsInformationMessage = localizations?.smsInformationMessage ?? '';
    final String continueText = localizations?.continueText ?? '';

    return BlocBuilder<PhoneNumberSignInCubit, PhoneNumberSignInState>(
      buildWhen: (previous, current) => previous.isPhoneNumberInputValidated != current.isPhoneNumberInputValidated,
      builder: (context, state) {
        final bool isPhoneNumberInputValidated = state.isPhoneNumberInputValidated;

        return Container(
          width: size.width,
          padding: EdgeInsets.only(top: size.height / 3, right: 24, left: 24, bottom: 24),
          child: Card(
            color: white,
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 28, left: 28),
                  child: CustomText(
                    text: signInWithPhoneNumber,
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: black,
                  ),
                ),
                SignInViewInputField(state: state),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
                  child: CustomText(
                    text: smsInformationMessage,
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: secondaryTextColor,
                  ),
                ),
                AnimatedGradientButton(
                  text: continueText,
                  isEnabled: isPhoneNumberInputValidated,
                  onPressed: () => _handleSubmit(context, isPhoneNumberInputValidated),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _handleSubmit(BuildContext context, bool isPhoneNumberInputValidated) {
    if (isPhoneNumberInputValidated) {
      context.read<PhoneNumberSignInCubit>().signInWithPhoneNumber();
    }
  }
}
