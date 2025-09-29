import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_social_chat/presentation/design_system/colors.dart';
import 'package:flutter_social_chat/presentation/design_system/widgets/custom_text.dart';

/// Empty state widget when channels couldn't be loaded
class DashboardViewEmptyStateWidget extends StatelessWidget {
  const DashboardViewEmptyStateWidget({super.key, required this.onRetry});

  /// Callback when retry button is pressed
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.forum_outlined, size: 64, color: customGreyColor500),
            const SizedBox(height: 16),
            CustomText(
              text: AppLocalizations.of(context)?.connectingToChat ?? '',
              fontSize: 18,
              fontWeight: FontWeight.w600,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
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
      ),
    );
  }
}
