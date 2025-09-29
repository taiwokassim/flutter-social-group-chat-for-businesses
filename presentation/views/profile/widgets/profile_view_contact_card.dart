import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_social_chat/presentation/design_system/colors.dart';
import 'package:flutter_social_chat/presentation/design_system/widgets/custom_text.dart';
import 'package:flutter_social_chat/presentation/views/profile/widgets/profile_view_contact_info_widget.dart';

/// Card showing detailed user contact information
///
/// Features:
/// - Shows phone number with appropriate icon
/// - Shows user ID with tag icon
/// - Clean card layout with title and dividers
/// - Uses design system colors and text styles
class ProfileViewContactCard extends StatelessWidget {
  const ProfileViewContactCard({
    super.key,
    required this.userPhoneNumber,
    required this.userId,
  });

  final String userPhoneNumber;
  final String userId;

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);

    return Expanded(
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 5)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomText(
              text: localization?.contactInformation ?? '',
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: customGreyColor900,
            ),
            const SizedBox(height: 12),
            ProfileViewContactInfoWidget(
              icon: Icons.phone,
              title: localization?.phoneNumber ?? '',
              value: userPhoneNumber,
            ),
            const Divider(height: 16),
            ProfileViewContactInfoWidget(
              icon: Icons.tag,
              title: localization?.userId ?? '',
              value: userId,
            ),
          ],
        ),
      ),
    );
  }
}
