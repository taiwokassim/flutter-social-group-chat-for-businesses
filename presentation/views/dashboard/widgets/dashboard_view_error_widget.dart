import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_social_chat/presentation/design_system/colors.dart';
import 'package:flutter_social_chat/presentation/design_system/widgets/custom_text.dart';

/// Error state widget for the Channels page
class DashboardViewErrorWidget extends StatelessWidget {
  const DashboardViewErrorWidget({super.key, required this.onRetry});

  /// Callback when retry button is pressed
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        spacing: 16,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: errorColor, size: 48),
          CustomText(
            text: AppLocalizations.of(context)?.somethingWentWrong ?? '',
            fontSize: 16,
            fontWeight: FontWeight.w600,
            textAlign: TextAlign.center,
          ),
          ElevatedButton(
            onPressed: onRetry,
            style: ElevatedButton.styleFrom(
              backgroundColor: customIndigoColor,
              foregroundColor: white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
            child: CustomText(text: AppLocalizations.of(context)?.retry ?? '', color: white),
          ),
        ],
      ),
    );
  }
}
