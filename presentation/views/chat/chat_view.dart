import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_social_chat/core/constants/enums/router_enum.dart';
import 'package:flutter_social_chat/presentation/blocs/auth_session/auth_session_cubit.dart';
import 'package:flutter_social_chat/presentation/design_system/colors.dart';
import 'package:flutter_social_chat/presentation/design_system/widgets/custom_progress_indicator.dart';
import 'package:flutter_social_chat/presentation/design_system/widgets/custom_text.dart';
import 'package:flutter_social_chat/presentation/views/chat/widgets/chat_view_body.dart';
import 'package:go_router/go_router.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';

class ChatView extends StatefulWidget {
  const ChatView({super.key, required this.channel});

  final Channel channel;

  @override
  State<ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView> {
  @override
  void initState() {
    super.initState();
    _markChannelAsRead();
  }

  void _markChannelAsRead() {
    widget.channel.markRead();
  }

  @override
  Widget build(BuildContext context) {
    return StreamChannel(
      channel: widget.channel,
      child: Scaffold(
        appBar: _buildAppBar(context),
        body: const ChatViewBody(),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    final localization = AppLocalizations.of(context);
    final currentUserId = context.read<AuthSessionCubit>().state.authUser.id;
    final channelMembers = widget.channel.state?.members ?? [];
    final isOneToOneChat = channelMembers.length == 2;

    User? otherUser;
    if (isOneToOneChat) {
      try {
        otherUser = channelMembers.firstWhere((member) => member.userId != currentUserId).user;
      } catch (e) {
        // No other user found
      }
    }

    final displayName =
        isOneToOneChat && otherUser != null ? otherUser.name : widget.channel.name ?? localization?.unnamedGroup;

    final imageUrl = isOneToOneChat && otherUser != null ? otherUser.image : widget.channel.image;

    return AppBar(
      backgroundColor: white,
      elevation: 0,
      titleSpacing: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, color: customGreyColor800),
        onPressed: () => context.go(RouterEnum.dashboardView.routeName),
      ),
      title: Row(
        children: [
          _buildAvatar(imageUrl, isOneToOneChat),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomText(
                  text: displayName ?? '',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (isOneToOneChat && otherUser?.online == true)
                  CustomText(text: localization?.online ?? '', fontSize: 12, color: successColor),
              ],
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.call, color: customGreyColor800),
          onPressed: () {
            // Handle call action
          },
        ),
        IconButton(
          icon: const Icon(Icons.more_vert, color: customGreyColor800),
          onPressed: () {
            // Show channel options menu
          },
        ),
      ],
    );
  }

  Widget _buildAvatar(String? imageUrl, bool isOneToOneChat) {
    const double avatarSize = 36;

    final Widget defaultAvatar = CircleAvatar(
      radius: avatarSize / 2,
      backgroundColor: customIndigoColor.withValues(alpha: 0.1),
      child: Icon(
        isOneToOneChat ? Icons.person : Icons.group,
        color: customIndigoColor,
        size: avatarSize / 2.5,
      ),
    );

    if (imageUrl == null || imageUrl.isEmpty) {
      return defaultAvatar;
    }

    return CachedNetworkImage(
      imageUrl: imageUrl,
      imageBuilder: (context, imageProvider) => CircleAvatar(
        radius: avatarSize / 2,
        backgroundImage: imageProvider,
      ),
      placeholder: (context, url) => const CircleAvatar(
        radius: avatarSize / 2,
        backgroundColor: customGreyColor200,
        child: CustomProgressIndicator(
          size: 20,
          progressIndicatorColor: customIndigoColor,
        ),
      ),
      errorWidget: (context, url, error) => defaultAvatar,
    );
  }
}
