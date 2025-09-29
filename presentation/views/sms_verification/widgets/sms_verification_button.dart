import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_social_chat/presentation/blocs/phone_number_sign_in/phone_number_sign_in_cubit.dart';
import 'package:flutter_social_chat/presentation/design_system/colors.dart';
import 'package:flutter_social_chat/presentation/design_system/widgets/custom_text.dart';

/// Button to confirm and submit the SMS verification code
class SmsVerificationButton extends StatelessWidget {
  const SmsVerificationButton({super.key, required this.isEnabled});

  final bool isEnabled;
  @override
  Widget build(BuildContext context) {
    final String verifyCodeText = AppLocalizations.of(context)?.verifyCode ?? '';

    return AnimatedContainer(
      duration: const Duration(milliseconds: 120),
      curve: Curves.easeInOut,
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        color: isEnabled ? white : white.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(12),
        boxShadow: isEnabled
            ? [
                BoxShadow(
                  color: white.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Material(
        color: transparent,
        child: InkWell(
          onTap: isEnabled ? () => context.read<PhoneNumberSignInCubit>().verifySmsCode() : null,
          borderRadius: BorderRadius.circular(12),
          child: Center(
            child: AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 300),
              style: TextStyle(
                color: isEnabled ? customIndigoColor : customIndigoColor.withValues(alpha: 0.5),
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
              child: Row(
                spacing: 8,
                mainAxisSize: MainAxisSize.min,
                children: [
                  CustomText(
                    text: verifyCodeText,
                    color: isEnabled ? customIndigoColor : customIndigoColor.withValues(alpha: 0.5),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    child: Icon(
                      Icons.arrow_forward_rounded,
                      size: 20,
                      color: isEnabled ? customIndigoColor : customIndigoColor.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
