import 'dart:async';

import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_social_chat/presentation/blocs/phone_number_sign_in/phone_number_sign_in_cubit.dart';
import 'package:flutter_social_chat/presentation/blocs/phone_number_sign_in/phone_number_sign_in_state.dart';
import 'package:flutter_social_chat/presentation/design_system/colors.dart';
import 'package:flutter_social_chat/presentation/design_system/widgets/custom_text.dart';

/// Button that allows users to request a new SMS code
class SmsVerificationResendCodeButton extends StatefulWidget {
  const SmsVerificationResendCodeButton({super.key});

  @override
  State<SmsVerificationResendCodeButton> createState() => _SmsVerificationResendCodeButtonState();
}

class _SmsVerificationResendCodeButtonState extends State<SmsVerificationResendCodeButton> {
  // Button state tracking
  bool _isResending = false;
  Timer? _safetyTimer;

  @override
  void dispose() {
    _safetyTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final String resendCodeText = AppLocalizations.of(context)?.resendCode ?? '';

    return BlocConsumer<PhoneNumberSignInCubit, PhoneNumberSignInState>(
      listenWhen: (previous, current) =>
          previous.isInProgress != current.isInProgress ||
          (previous.failureMessageOption != current.failureMessageOption && current.failureMessageOption.isSome()),
      listener: (context, state) {
        // When the state changes from in-progress to not in-progress during a resend operation
        if (_isResending) {
          if (!state.isInProgress) {
            setState(() => _isResending = false);
            _safetyTimer?.cancel();

            state.failureMessageOption.fold(
              () {
                // Success case - show toast with localized message
                BotToast.showText(text: AppLocalizations.of(context)?.codeResent ?? '');
              },
              (_) {
                // Error is already handled by the parent view
              },
            );
          }
        }
      },
      buildWhen: (previous, current) => previous.isInProgress != current.isInProgress,
      builder: (context, state) {
        final bool isDisabled = state.isInProgress || _isResending;

        return Align(
          alignment: Alignment.centerLeft,
          child: InkWell(
            onTap: isDisabled ? null : () => _resendCode(context),
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.refresh_rounded, size: 18, color: white),
                  const SizedBox(width: 8),
                  CustomText(
                    text: resendCodeText,
                    color: white.withValues(alpha: isDisabled ? 0.5 : 1.0),
                    fontSize: 14,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _resendCode(BuildContext context) {
    // Already resending, don't trigger again
    if (_isResending) return;

    // Cancel any existing safety timer
    _safetyTimer?.cancel();

    // Track that we're in a resend operation
    setState(() => _isResending = true);

    // Use a safety timer as a backup - if after 8 seconds we're still resending,
    // reset our state
    _safetyTimer = Timer(const Duration(seconds: 8), () {
      if (mounted && _isResending) {
        setState(() => _isResending = false);
        debugPrint('ResendCodeButton safety timer fired');
      }
    });

    // Initiate the resend through the cubit
    context.read<PhoneNumberSignInCubit>().resendCode();
  }
}
