import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_social_chat/presentation/design_system/colors.dart';
import 'package:flutter_social_chat/presentation/design_system/widgets/custom_text.dart';

class ProfileViewDetails extends StatelessWidget {
  const ProfileViewDetails({
    super.key,
    required this.createdAt,
    required this.isUserBannedStatus,
  });

  final String createdAt;
  final bool isUserBannedStatus;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 20),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 5)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 8,
        children: [
          CustomText(
            text: l10n?.accountDetails ?? '',
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: customGreyColor900,
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: customIndigoColorSecondary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.calendar_today, color: customIndigoColorSecondary, size: 18),
            ),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CustomText(
                  text: l10n?.createdAtText ?? '',
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: customGreyColor900,
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: customIndigoColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: CustomText(
                    text: l10n?.regularUser ?? '',
                    fontSize: 12,
                    color: customIndigoColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            subtitle: CustomText(text: createdAt, fontSize: 13, color: customGreyColor600),
          ),
        ],
      ),
    );
  }
}
