import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_social_chat/core/constants/enums/router_enum.dart';
import 'package:flutter_social_chat/presentation/design_system/colors.dart';
import 'package:flutter_social_chat/presentation/design_system/widgets/custom_text.dart';
import 'package:flutter_social_chat/presentation/views/dashboard/widgets/dashboard_view_messages_card.dart';
import 'package:go_router/go_router.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';

/// A header widget for the Channels page displaying the user's status, title, and profile avatar.
class DashboardViewHeader extends StatelessWidget {
  const DashboardViewHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 60, 24, 16),
      decoration: BoxDecoration(
        color: white,
        boxShadow: [
          BoxShadow(color: customGreyColor300.withValues(alpha: 0.2), blurRadius: 4, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: customIndigoColor.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      spacing: 8,
                      children: [
                        const SizedBox(
                          width: 8,
                          height: 8,
                          child: DecoratedBox(
                            decoration: BoxDecoration(color: successColor, shape: BoxShape.circle),
                          ),
                        ),
                        CustomText(
                          text: AppLocalizations.of(context)?.online ?? '',
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: customIndigoColor,
                        ),
                      ],
                    ),
                  ),
                  CustomText(
                    text: AppLocalizations.of(context)?.dashboard ?? '',
                    fontSize: 36,
                    fontWeight: FontWeight.w800,
                  ),
                ],
              ),
              GestureDetector(
                onTap: () => context.go(RouterEnum.profileView.routeName),
                child: Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [customIndigoColor, customIndigoColorSecondary],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: customGreyColor400.withValues(alpha: 0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                    border: Border.all(color: white, width: 3),
                  ),
                  child: _buildUserAvatar(context),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const DashboardViewMessagesCard(),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  /// Build the current user's avatar
  Widget _buildUserAvatar(BuildContext context) {
    // Get the current user from the Stream chat context
    final User? currentUser = StreamChat.of(context).client.state.currentUser;

    if (currentUser?.image != null && currentUser!.image!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Image.network(
          currentUser.image!,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => const Icon(Icons.person, color: white, size: 26),
        ),
      );
    }

    return const Icon(Icons.person, color: white, size: 26);
  }
}
