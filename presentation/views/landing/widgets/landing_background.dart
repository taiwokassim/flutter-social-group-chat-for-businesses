import 'package:flutter/material.dart';
import 'package:flutter_social_chat/presentation/design_system/colors.dart';

/// Widget for displaying the background gradient of the landing page
class LandingBackground extends StatelessWidget {
  const LandingBackground({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return Container(
      width: size.width,
      height: size.height,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [customIndigoColor, customIndigoColorSecondary, customGreyColor300],
          stops: [0.0, 0.5, 1.0],
        ),
      ),
    );
  }
}
