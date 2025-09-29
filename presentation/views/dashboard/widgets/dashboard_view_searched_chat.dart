import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_social_chat/presentation/blocs/auth_session/auth_session_cubit.dart';
import 'package:flutter_social_chat/presentation/blocs/chat_management/chat_management_cubit.dart';
import 'package:flutter_social_chat/presentation/design_system/colors.dart';
import 'package:flutter_social_chat/presentation/design_system/widgets/custom_progress_indicator.dart';
import 'package:flutter_social_chat/presentation/design_system/widgets/custom_text.dart';
import 'package:intl/intl.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';

/// A beautifully designed widget that displays a single chat channel in the channels list
///
/// This widget handles both one-to-one and group chats, showing appropriate
/// title, avatar, and last message preview with modern design elements.
class DashboardViewSearchedChat extends StatelessWidget {
  const DashboardViewSearchedChat({
    super.key,
    required this.listOfChannels,
    required this.searchedText,
    required this.index,
    required this.defaultWidget,
  });

  /// List of all available channels
  final List<Channel> listOfChannels;

  /// Current search query text
  final String searchedText;

  /// Index of this channel in the list
  final int index;

  /// Default widget provided by StreamChannelListView
  final StreamChannelListTile defaultWidget;

  @override
  Widget build(BuildContext context) {
    final channel = listOfChannels[index];
    final channelMembers = channel.state?.members ?? [];
    final lengthOfTheChannelMembers = channelMembers.length;
    final currentUserId = context.read<AuthSessionCubit>().state.authUser.id;
    final appLocalizations = AppLocalizations.of(context);
    // Find the other user in a one-to-one chat
    Member? otherMember;

    if (lengthOfTheChannelMembers > 0) {
      try {
        otherMember = channelMembers.firstWhere((member) => member.userId != currentUserId);
      } catch (e) {
        // If we can't find another member, default to first member (might be the current user)
        otherMember = channelMembers.isNotEmpty ? channelMembers.first : null;
      }
    }

    final oneToOneChatMember = otherMember?.user;

    // Check if this channel should be shown based on search criteria
    final isTheSearchedChannelExist = oneToOneChatMember != null &&
        context.read<ChatManagementCubit>().searchInsideExistingChannels(
              listOfChannels: listOfChannels,
              searchedText: searchedText,
              index: index,
              oneToOneChatMember: oneToOneChatMember,
              lengthOfTheChannelMembers: lengthOfTheChannelMembers,
            );

    // Don't render anything if this channel doesn't match search criteria
    if (!isTheSearchedChannelExist) {
      return const SizedBox.shrink();
    }

    // Extract message details
    final lastMessage = channel.state?.lastMessage;
    final messageText = _getMessageText(context, lastMessage);

    // Determine name and image based on chat type
    final isOneToOneChat = lengthOfTheChannelMembers == 2;
    final String displayName =
        isOneToOneChat ? oneToOneChatMember.name : channel.name ?? appLocalizations?.unnamedGroup ?? '';
    final String? imageUrl = isOneToOneChat ? oneToOneChatMember.image : channel.image;

    // Get unread count and online status
    final unreadCount = channel.state?.unreadCount ?? 0;
    final isUserOnline = isOneToOneChat && (otherMember?.user?.online ?? false);

    // Format timestamp for last message
    final lastMessageAt = channel.lastMessageAt;
    final String timeString = lastMessageAt != null ? _formatTimestamp(lastMessageAt) : '';

    // Check if this is the sender of the last message
    final isCurrentUserLastMessageSender = lastMessage?.user?.id == currentUserId;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        splashColor: customIndigoColor.withValues(alpha: 0.1),
        highlightColor: customIndigoColor.withValues(alpha: 0.05),
        onTap: () => defaultWidget.onTap?.call(),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          child: Row(
            children: [
              Stack(
                children: [
                  _buildAvatar(imageUrl, isOneToOneChat),
                  if (isUserOnline)
                    Positioned(
                      right: 2,
                      bottom: 2,
                      child: Container(
                        width: 14,
                        height: 14,
                        decoration: BoxDecoration(
                          color: successColor,
                          shape: BoxShape.circle,
                          border: Border.all(color: white, width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: customGreyColor600.withValues(alpha: 0.3),
                              blurRadius: 4,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 4,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: CustomText(
                            text: displayName,
                            fontSize: 16,
                            fontWeight: unreadCount > 0 ? FontWeight.w700 : FontWeight.w600,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Row(
                          children: [
                            if (unreadCount > 0)
                              Container(
                                margin: const EdgeInsets.only(right: 8),
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: customIndigoColor,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            if (timeString.isNotEmpty)
                              CustomText(
                                text: timeString,
                                fontSize: 12,
                                color: unreadCount > 0 ? customIndigoColor : customGreyColor600,
                                fontWeight: unreadCount > 0 ? FontWeight.w600 : FontWeight.w400,
                              ),
                          ],
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        if (isCurrentUserLastMessageSender && lastMessage != null)
                          const Padding(
                            padding: EdgeInsets.only(right: 4),
                            child: CustomText(
                              text: 'You: ',
                              fontSize: 14,
                              color: customGreyColor800,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        Expanded(
                          child: CustomText(
                            text: messageText,
                            fontSize: 14,
                            color: unreadCount > 0 ? customGreyColor800 : customGreyColor700,
                            fontWeight: unreadCount > 0 ? FontWeight.w500 : FontWeight.w400,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (unreadCount > 0)
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: const EdgeInsets.only(left: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [customIndigoColor, customIndigoColorSecondary],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: customIndigoColor.withValues(alpha: 0.3),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: CustomText(
                              text: unreadCount > 99 ? '99+' : '$unreadCount',
                              fontSize: 12,
                              color: white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Gets the message text to display as preview
  String _getMessageText(BuildContext context, Message? lastMessage) {
    if (lastMessage == null) {
      return AppLocalizations.of(context)?.beDeepIntoTheConversation ?? '';
    }

    if (lastMessage.attachments.isNotEmpty) {
      final attachmentType = lastMessage.attachments.first.type;

      switch (attachmentType) {
        case 'image':
          return '📷 ${AppLocalizations.of(context)?.attachment}';
        case 'video':
          return '🎬 ${AppLocalizations.of(context)?.attachment}';
        case 'file':
          return '📎 ${AppLocalizations.of(context)?.attachment}';
        case 'audio':
          return '🎵 ${AppLocalizations.of(context)?.attachment}';
        default:
          return AppLocalizations.of(context)?.attachment ?? '';
      }
    }

    return lastMessage.text ?? '';
  }

  /// Builds the avatar for the channel
  Widget _buildAvatar(String? imageUrl, bool isOneToOneChat) {
    final Widget placeholderWidget = const CustomProgressIndicator(size: 20, progressIndicatorColor: customIndigoColor);

    final Widget defaultAvatar = Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            customIndigoColor.withValues(alpha: 0.2),
            customIndigoColorSecondary.withValues(alpha: 0.3),
          ],
        ),
      ),
      child: Center(child: Icon(isOneToOneChat ? Icons.person : Icons.group, color: customIndigoColor, size: 56 / 2.2)),
    );

    if (imageUrl == null || imageUrl.isEmpty) {
      return defaultAvatar;
    }

    return CachedNetworkImage(
      imageUrl: imageUrl,
      imageBuilder: (context, imageProvider) => Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
          boxShadow: [
            BoxShadow(color: customGreyColor400.withValues(alpha: 0.4), blurRadius: 4, offset: const Offset(0, 2)),
          ],
          border: Border.all(color: white, width: 2),
        ),
      ),
      placeholder: (context, url) => SizedBox(
        width: 56,
        height: 56,
        child: Center(child: placeholderWidget),
      ),
      errorWidget: (context, url, error) => defaultAvatar,
    );
  }

  /// Formats a timestamp into a readable string
  String _formatTimestamp(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 365) {
      // More than a year ago
      return DateFormat('MMM d, yy').format(dateTime);
    } else if (difference.inDays > 7) {
      // More than a week ago - show date
      return DateFormat('MMM d').format(dateTime);
    } else if (difference.inDays > 0) {
      // Less than a week but more than a day
      return DateFormat('E').format(dateTime); // Day name
    } else if (difference.inHours > 0) {
      // Today but hours ago
      return DateFormat('h:mm a').format(dateTime);
    } else if (difference.inMinutes > 0) {
      // Minutes ago
      return '${difference.inMinutes}m ago';
    } else {
      // Just now
      return 'now';
    }
  }
}
