import 'package:flutter/material.dart';
import 'package:flutter_social_chat/presentation/design_system/colors.dart';
import 'package:flutter_social_chat/presentation/design_system/widgets/keyboard_dismiss_wrapper.dart';
import 'package:flutter_social_chat/presentation/gen/assets.gen.dart';
import 'package:flutter_social_chat/presentation/views/sign_in/widgets/sign_in_view_input_card.dart';
import 'package:lottie/lottie.dart';

/// The main content of the sign-in view
///
/// Displays a colored background, animation, and the phone input card
class SignInViewBody extends StatelessWidget {
  const SignInViewBody({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return KeyboardDismissWrapper(
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          Container(
            width: size.width,
            height: size.height / 2.4,
            decoration: const BoxDecoration(
              color: customIndigoColor,
              borderRadius: BorderRadius.only(bottomRight: Radius.circular(28), bottomLeft: Radius.circular(28)),
            ),
          ),
          Lottie.asset(
            Assets.animations.chatAnimation,
            width: size.width / 1.5,
            repeat: true,
            frameRate: const FrameRate(30), // Limit frame rate for better performance
            options: LottieOptions(
              enableMergePaths: true, // Enable path merging for better performance
            ),
          ),
          const SignInViewInputCard(),
        ],
      ),
    );
  }
}
