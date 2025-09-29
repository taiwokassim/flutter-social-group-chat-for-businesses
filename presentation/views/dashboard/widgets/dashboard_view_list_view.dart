import 'package:flutter/material.dart';
import 'package:flutter_social_chat/presentation/views/dashboard/widgets/dashboard_view_error_widget.dart';
import 'package:flutter_social_chat/presentation/views/dashboard/widgets/dashboard_view_loading_widget.dart';
import 'package:flutter_social_chat/presentation/views/dashboard/widgets/dashboard_view_list_item_builder.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';

/// A widget for displaying a list of channels with search functionality
class DashboardViewListView extends StatefulWidget {
  const DashboardViewListView({
    super.key,
    required this.controller,
    required this.searchText,
    required this.onChannelTap,
    required this.onSearchResultsChanged,
  });

  /// The controller for the Stream channel list
  final StreamChannelListController controller;

  /// Current search query text
  final String searchText;

  /// Callback when a channel is tapped
  final void Function(Channel) onChannelTap;

  /// Callback to notify when search results change
  final Function(bool hasNoResults) onSearchResultsChanged;

  @override
  State<DashboardViewListView> createState() => _DashboardViewListViewState();
}

class _DashboardViewListViewState extends State<DashboardViewListView> {
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: StreamChannelListView(
        padding: const EdgeInsets.only(top: 8),
        controller: widget.controller,
        onChannelTap: widget.onChannelTap,
        errorBuilder: (_, __) => DashboardViewErrorWidget(onRetry: () => widget.controller.refresh()),
        loadingBuilder: (_) => const DashboardViewLoadingWidget(),
        itemBuilder: (context, channels, index, defaultWidget) {
          return DashboardViewListItemBuilder(
            channels: channels,
            index: index,
            defaultWidget: defaultWidget,
            searchText: widget.searchText,
            onSearchResultsChanged: widget.onSearchResultsChanged,
          );
        },
      ),
    );
  }
}
