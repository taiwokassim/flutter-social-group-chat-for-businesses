import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_social_chat/presentation/blocs/auth_session/auth_session_cubit.dart';
import 'package:flutter_social_chat/presentation/blocs/chat_management/chat_management_cubit.dart';
import 'package:flutter_social_chat/presentation/design_system/colors.dart';
import 'package:flutter_social_chat/presentation/views/dashboard/widgets/dashboard_view_searched_chat.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';

/// A widget for building individual channel list items with search capabilities
class DashboardViewListItemBuilder extends StatefulWidget {
  const DashboardViewListItemBuilder({
    super.key,
    required this.channels,
    required this.index,
    required this.defaultWidget,
    required this.searchText,
    required this.onSearchResultsChanged,
  });

  /// List of all channels
  final List<Channel> channels;

  /// Index of this channel in the list
  final int index;

  /// Default widget provided by StreamChannelListView
  final StreamChannelListTile defaultWidget;

  /// Current search text
  final String searchText;

  /// Callback to notify when search results change
  final Function(bool hasNoResults) onSearchResultsChanged;

  @override
  State<DashboardViewListItemBuilder> createState() => _DashboardViewListItemBuilderState();
}

class _DashboardViewListItemBuilderState extends State<DashboardViewListItemBuilder> {
  @override
  Widget build(BuildContext context) {
    // Check if this channel should be visible with search
    final isVisible = _isChannelVisible();
    if (!isVisible) return const SizedBox.shrink();

    // If this is the first visible channel and we're searching
    if (widget.searchText.isNotEmpty && widget.index == 0) {
      // Check for any visible channels
      bool anyVisible = false;
      for (int i = 0; i < widget.channels.length; i++) {
        if (_isChannelVisibleAt(i)) {
          anyVisible = true;
          break;
        }
      }

      // Update search results state
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.onSearchResultsChanged(!anyVisible);
      });
    }

    final hasBottomDivider = widget.index < widget.channels.length - 1;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: DashboardViewSearchedChat(
            listOfChannels: widget.channels,
            searchedText: widget.searchText,
            index: widget.index,
            defaultWidget: widget.defaultWidget,
          ),
        ),
        if (hasBottomDivider)
          const Padding(
            padding: EdgeInsets.only(left: 72, right: 16),
            child: Divider(height: 1, thickness: 1, color: customGreyColor200),
          ),
      ],
    );
  }

  /// Check if a channel should be visible with current search
  bool _isChannelVisible() {
    return _isChannelVisibleAt(widget.index);
  }

  /// Check if a channel at given index should be visible with current search
  bool _isChannelVisibleAt(int index) {
    if (widget.searchText.isEmpty) return true;

    final channel = widget.channels[index];
    final members = channel.state?.members ?? [];
    final currentUserId = context.read<AuthSessionCubit>().state.authUser.id;

    try {
      final otherMember = members.firstWhere((member) => member.userId != currentUserId);
      if (otherMember.user == null) return false;

      return context.read<ChatManagementCubit>().searchInsideExistingChannels(
            listOfChannels: widget.channels,
            searchedText: widget.searchText,
            index: index,
            oneToOneChatMember: otherMember.user!,
            lengthOfTheChannelMembers: members.length,
          );
    } catch (_) {
      return false;
    }
  }
}
