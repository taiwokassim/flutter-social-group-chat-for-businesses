import 'package:flutter/material.dart';
import 'package:flutter_social_chat/presentation/design_system/colors.dart';
import 'package:flutter_social_chat/presentation/gen/assets.gen.dart';
import 'package:lottie/lottie.dart';

/// Animated illustration shown at the top of the onboarding page
class OnboardingViewAnimation extends StatefulWidget {
  const OnboardingViewAnimation({super.key});

  @override
  State<OnboardingViewAnimation> createState() => _OnboardingViewAnimationState();
}

class _OnboardingViewAnimationState extends State<OnboardingViewAnimation> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 3));
    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 48, bottom: 20),
      child: Hero(
        tag: 'onboarding_animation',
        child: SizedBox(
          height: 180,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Background circle
              Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(shape: BoxShape.circle, color: customIndigoColor.withValues(alpha: 0.1)),
              ),
              Lottie.asset(
                Assets.animations.onboardingAnimation,
                width: 180,
                height: 180,
                controller: _controller,
                frameRate: const FrameRate(30), // Limit frame rate for better performance
                options: LottieOptions(enableMergePaths: true) // Improve performance by merging paths
                ,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
