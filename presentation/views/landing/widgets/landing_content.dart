import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter_social_chat/presentation/design_system/colors.dart';
import 'package:flutter_social_chat/presentation/design_system/widgets/custom_text.dart';
import 'package:flutter_social_chat/presentation/gen/assets.gen.dart';
import 'package:flutter_social_chat/presentation/views/landing/widgets/landing_loading_indicator.dart';
import 'package:flutter_social_chat/presentation/views/landing/widgets/landing_status_container.dart';

/// Main content widget for the landing page
class LandingContent extends StatelessWidget {
  const LandingContent({
    super.key,
    required this.loadingMessage,
    required this.loadingPhase,
    required this.isReadyToNavigate,
  });

  /// Current loading message to display
  final String loadingMessage;

  /// Current loading phase (0-4)
  final int loadingPhase;

  /// Whether navigation is ready
  final bool isReadyToNavigate;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final localizations = AppLocalizations.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 40),
          Lottie.asset(
            Assets.animations.chatAnimation,
            width: size.width * 0.7,
            height: size.height * 0.3,
            fit: BoxFit.contain,
            frameRate: const FrameRate(30), // Limit frame rate to improve performance
          ),
          const SizedBox(height: 32),
          CustomText(
            text: localizations?.appName ?? '',
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: white,
            letterSpacing: 1.2,
          ),
          const SizedBox(height: 16),
          CustomText(text: localizations?.appTagline ?? '', fontSize: 16, color: white),
          const SizedBox(height: 60),
          LandingLoadingIndicator(isReadyToNavigate: isReadyToNavigate),
          const Spacer(),
          LandingStatusContainer(loadingMessage: loadingMessage, loadingPhase: loadingPhase),
          const SizedBox(height: 60),
        ],
      ),
    );
  }
}
