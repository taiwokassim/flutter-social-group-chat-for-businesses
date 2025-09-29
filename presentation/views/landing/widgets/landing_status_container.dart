import 'package:flutter/material.dart';
import 'package:flutter_social_chat/presentation/design_system/colors.dart';
import 'package:flutter_social_chat/presentation/design_system/widgets/custom_text.dart';

/// Widget for displaying the current loading status and progress
class LandingStatusContainer extends StatelessWidget {
  const LandingStatusContainer({super.key, required this.loadingMessage, required this.loadingPhase});

  /// Current loading message to display
  final String loadingMessage;

  /// Current loading phase (0-4)
  final int loadingPhase;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: customIndigoColor.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: black.withValues(alpha: 0.1), blurRadius: 10, offset: const Offset(0, 5)),
        ],
      ),
      child: Column(
        spacing: 16,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: loadingPhase / 4,
              backgroundColor: white.withValues(alpha: 0.2),
              color: white,
              minHeight: 8,
            ),
          ),
          CustomText(text: loadingMessage, fontSize: 16, color: white, fontWeight: FontWeight.w500),
        ],
      ),
    );
  }
}
