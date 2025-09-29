import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_social_chat/presentation/blocs/phone_number_sign_in/phone_number_sign_in_cubit.dart';
import 'package:flutter_social_chat/presentation/blocs/phone_number_sign_in/phone_number_sign_in_state.dart';
import 'package:flutter_social_chat/presentation/design_system/colors.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

/// Widget that displays a custom PIN field for SMS code entry
class SmsVerificationPinField extends StatelessWidget {
  const SmsVerificationPinField({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          margin: const EdgeInsets.only(bottom: 16),
          width: size.width,
          height: 80,
          decoration: BoxDecoration(
            border: Border.all(color: white, width: 1.5),
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        BlocBuilder<PhoneNumberSignInCubit, PhoneNumberSignInState>(
          buildWhen: (previous, current) => previous.smsCode != current.smsCode,
          builder: (context, state) {
            return PinCodeTextField(
              appContext: context,
              controller: TextEditingController(text: state.smsCode),
              length: 6,
              animationType: AnimationType.fade,
              onChanged: (value) => context.read<PhoneNumberSignInCubit>().smsCodeChanged(smsCode: value),
              textStyle: const TextStyle(color: white, fontWeight: FontWeight.bold, fontSize: 20),
              keyboardType: TextInputType.number,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              cursorColor: white,
              cursorHeight: 22,
              enableActiveFill: true,
              backgroundColor: transparent,
              pinTheme: PinTheme(
                shape: PinCodeFieldShape.box,
                borderRadius: BorderRadius.circular(8),
                fieldHeight: 52,
                fieldWidth: 42,
                borderWidth: 0,
                selectedFillColor: white.withValues(alpha: 0.3),
                activeFillColor: white.withValues(alpha: 0.2),
                inactiveFillColor: white.withValues(alpha: 0.15),
                selectedColor: transparent,
                activeColor: transparent,
                inactiveColor: transparent,
              ),
            );
          },
        ),
      ],
    );
  }
}
