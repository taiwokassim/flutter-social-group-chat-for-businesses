import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_social_chat/presentation/design_system/colors.dart';
import 'package:flutter_social_chat/presentation/design_system/widgets/custom_text.dart';

/// A card displaying the user's messages information
class DashboardViewMessagesCard extends StatelessWidget {
  const DashboardViewMessagesCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            customIndigoColor.withValues(alpha: 0.08),
            customIndigoColorSecondary.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: customIndigoColor.withValues(alpha: 0.1), shape: BoxShape.circle),
            child: const Icon(Icons.forum_rounded, color: customIndigoColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              spacing: 4,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomText(
                  text: AppLocalizations.of(context)?.yourMessages ?? '',
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: customGreyColor800,
                ),
                CustomText(
                  text: AppLocalizations.of(context)?.tapToChat ?? '',
                  fontSize: 13,
                  color: customGreyColor600,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: customIndigoColor, borderRadius: BorderRadius.circular(16)),
            child: CustomText(
              text: AppLocalizations.of(context)?.newLabel ?? '',
              fontSize: 12,
              color: white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
