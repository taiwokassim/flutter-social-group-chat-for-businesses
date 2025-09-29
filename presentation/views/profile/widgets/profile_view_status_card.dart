import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_social_chat/presentation/design_system/colors.dart';
import 'package:flutter_social_chat/presentation/views/profile/widgets/profile_view_activity_status_widget.dart';

/// Card displaying user account status information
///
/// Features:
/// - Shows account activity status (active/inactive)
/// - Shows account restriction status (normal/restricted)
/// - Uses appropriate icons and colors for different states
/// - Presents information in a clean card layout with shadow
class ProfileViewStatusCard extends StatelessWidget {
  const ProfileViewStatusCard({super.key, required this.isUserBannedStatus});

  final bool isUserBannedStatus;

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 5)),
        ],
      ),
      child: Row(
        spacing: 16,
        children: [
          ProfileViewActivityStatusWidget(
            title: localization?.accountActivity ?? '',
            value: localization?.activeStatus ?? '',
            icon: Icons.notifications_active_outlined,
            color: customIndigoColor,
          ),
          ProfileViewActivityStatusWidget(
            title: localization?.accountStatus ?? '',
            value: isUserBannedStatus ? localization?.restrictedStatus ?? '' : localization?.normalStatus ?? '',
            icon: isUserBannedStatus ? Icons.block : Icons.check_circle,
            color: isUserBannedStatus ? errorColor : successColor,
          ),
        ],
      ),
    );
  }
}
