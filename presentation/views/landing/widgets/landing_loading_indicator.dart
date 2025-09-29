import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_social_chat/presentation/design_system/colors.dart';
import 'package:flutter_social_chat/presentation/design_system/widgets/custom_progress_indicator.dart';
import 'package:flutter_social_chat/presentation/design_system/widgets/custom_text.dart';

/// Widget for displaying the bottom loading indicator
class LandingLoadingIndicator extends StatelessWidget {
  const LandingLoadingIndicator({super.key, required this.isReadyToNavigate});

  /// Whether navigation is ready
  final bool isReadyToNavigate;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return AnimatedOpacity(
      opacity: isReadyToNavigate ? 0 : 1,
      duration: const Duration(milliseconds: 300),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(color: customIndigoColor, borderRadius: BorderRadius.circular(20)),
        child: Row(
          spacing: 12,
          mainAxisSize: MainAxisSize.min,
          children: [
            const CustomProgressIndicator(size: 20, strokeWidth: 2.5, progressIndicatorColor: white),
            CustomText(text: localizations?.justAMoment ?? '', fontSize: 14, color: white, fontWeight: FontWeight.w500),
          ],
        ),
      ),
    );
  }
}
