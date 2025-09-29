import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_social_chat/core/constants/enums/router_enum.dart';
import 'package:flutter_social_chat/presentation/blocs/auth_session/auth_session_cubit.dart';
import 'package:flutter_social_chat/presentation/blocs/auth_session/auth_session_state.dart';
import 'package:flutter_social_chat/presentation/blocs/chat_session/chat_session_cubit.dart';
import 'package:flutter_social_chat/presentation/blocs/chat_session/chat_session_state.dart';
import 'package:flutter_social_chat/presentation/design_system/widgets/popscope_scaffold.dart';
import 'package:flutter_social_chat/presentation/views/dashboard/widgets/dashboard_view_animated_chat_button.dart';
import 'package:flutter_social_chat/presentation/views/dashboard/widgets/dashboard_view_empty_state_widget.dart';
import 'package:flutter_social_chat/presentation/views/dashboard/widgets/dashboard_view_header.dart';
import 'package:flutter_social_chat/presentation/views/dashboard/widgets/dashboard_view_list_view.dart';
import 'package:flutter_social_chat/presentation/views/dashboard/widgets/dashboard_view_loading_widget.dart';
import 'package:flutter_social_chat/presentation/views/dashboard/widgets/dashboard_view_search_field.dart';
import 'package:go_router/go_router.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';

/// A beautifully designed page that displays the list of chat channels for the user.
///
/// This page shows all channels the current user is a member of and provides
/// search functionality to filter channels with modern UI and animations.
class DashboardView extends StatefulWidget {
  const DashboardView({super.key});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> with AutomaticKeepAliveClientMixin {
  /// Controller for the list of channels
  StreamChannelListController? _channelListController;

  /// Current search query text
  String _searchText = '';

  /// Text controller for search
  final _searchController = TextEditingController();

  /// Flag to indicate if there are no results for the current search
  bool _hasNoResults = false;

  /// Flag to prevent multiple reconnection attempts
  bool _isAttemptingReconnection = false;

  /// Timer for connection timeout
  Timer? _connectionTimeoutTimer;

  /// Flag to track if we've shown content despite connection issues
  bool _hasShownContentDespiteConnectionIssues = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _ensureChatConnection();
      // Set a timeout to show content even if chat isn't connected yet
      _startConnectionTimeout();
    });
  }

  @override
  void dispose() {
    _channelListController?.dispose();
    _searchController.dispose();
    _cancelConnectionTimeout();
    super.dispose();
  }

  /// Starts a timeout to show content even if chat connection is taking too long
  void _startConnectionTimeout() {
    _cancelConnectionTimeout();

    _connectionTimeoutTimer = Timer(const Duration(milliseconds: 3000), () {
      if (mounted && _channelListController == null) {
        debugPrint('Connection timeout reached, showing content without channels');
        setState(() {
          _hasShownContentDespiteConnectionIssues = true;
        });

        // Continue trying to connect in background
        _scheduleReconnectionAttempt(silent: true);
      }
    });
  }

  /// Cancels the connection timeout timer
  void _cancelConnectionTimeout() {
    _connectionTimeoutTimer?.cancel();
    _connectionTimeoutTimer = null;
  }

  /// Ensures chat connection is active before initializing controllers
  void _ensureChatConnection() {
    if (!mounted) return;

    try {
      final chatSessionState = context.read<ChatSessionCubit>().state;
      final authSessionState = context.read<AuthSessionCubit>().state;

      // Only proceed if we actually have a logged in user
      if (!authSessionState.isLoggedIn) return;

      // Check if user is connected to chat
      if (chatSessionState.isChatUserConnected) {
        _initControllers();
      } else {
        // If not connected, trigger reconnection if not already in progress
        if (!_isAttemptingReconnection) {
          _isAttemptingReconnection = true;

          // Attempt to reconnect with a small timeout
          context.read<AuthSessionCubit>().reconnectToChatService().timeout(
            const Duration(milliseconds: 2000),
            onTimeout: () {
              debugPrint('Chat reconnection timed out');
              return;
            },
          ).then((_) {
            _isAttemptingReconnection = false;

            // After reconnection attempt, check if we're mounted and try to init controllers
            if (mounted) {
              _initControllers();
            }
          }).catchError((error) {
            _isAttemptingReconnection = false;

            // If the error is "Connection already available" - that's actually good!
            // It means the user is already connected, so try to init controllers
            if (error.toString().contains('Connection already available')) {
              if (mounted) {
                debugPrint('User already connected to chat, initializing controllers');
                _initControllers();
                return;
              }
            }

            // For other errors, show UI anyway
            if (mounted && !_hasShownContentDespiteConnectionIssues) {
              setState(() {
                _hasShownContentDespiteConnectionIssues = true;
              });
            }
          });
        }
      }
    } catch (e) {
      debugPrint('Error ensuring chat connection: $e');
      // Show content despite connection error
      if (mounted && !_hasShownContentDespiteConnectionIssues) {
        setState(() {
          _hasShownContentDespiteConnectionIssues = true;
        });
      }
    }
  }

  /// Initialize Stream controllers
  void _initControllers() {
    if (!mounted) return;

    try {
      final client = StreamChat.of(context).client;

      final currentUser = client.state.currentUser;

      if (currentUser != null) {
        // Channel list controller
        _channelListController = StreamChannelListController(
          client: client,
          filter: Filter.in_('members', [currentUser.id]),
          channelStateSort: const [SortOption('last_message_at')],
          limit: 20,
        );

        // Cancel timeout since we're now connected
        _cancelConnectionTimeout();

        if (mounted) setState(() {});
      } else {
        debugPrint('StreamChat current user is null, retrying connection...');
        // If currentUser is null but we're supposed to be logged in, try reconnecting
        _scheduleReconnectionAttempt();
      }
    } catch (e) {
      debugPrint('Error initializing controllers: $e');
      // If we encounter an error, schedule a reconnection attempt
      _scheduleReconnectionAttempt();
    }
  }

  /// Schedules a reconnection attempt after a short delay
  void _scheduleReconnectionAttempt({bool silent = false}) {
    if (!mounted || _isAttemptingReconnection) return;

    _isAttemptingReconnection = true;

    // Use a shorter delay for reconnection attempts
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        context.read<AuthSessionCubit>().reconnectToChatService().timeout(
          const Duration(milliseconds: 1500),
          onTimeout: () {
            debugPrint('Reconnection attempt timed out');
            return;
          },
        ).then((_) {
          _isAttemptingReconnection = false;
          if (mounted) _initControllers();
        }).catchError((error) {
          _isAttemptingReconnection = false;

          // Check if this is actually a "already connected" error
          if (error.toString().contains('Connection already available')) {
            if (mounted) {
              debugPrint('User already connected to chat, initializing controllers');
              _initControllers();
              return;
            }
          }

          // In silent mode, we've already shown content so just keep trying in background
          if (!silent && mounted && !_hasShownContentDespiteConnectionIssues) {
            setState(() {
              _hasShownContentDespiteConnectionIssues = true;
            });
          }
        });
      } else {
        _isAttemptingReconnection = false;
      }
    });
  }

  /// Handle search text changes
  void _handleSearchTextChanged(String text) {
    setState(() {
      _searchText = text;
    });
    _channelListController?.refresh();
  }

  /// Navigate to channel view
  void _navigateToChannel(Channel channel) {
    context.go(RouterEnum.chatView.routeName, extra: {'channel': channel});
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return MultiBlocListener(
      listeners: [
        BlocListener<ChatSessionCubit, ChatSessionState>(
          listenWhen: (previous, current) => !previous.isChatUserConnected && current.isChatUserConnected,
          listener: (context, state) {
            if (state.isChatUserConnected && _channelListController == null) {
              _initControllers();
            }
          },
        ),
        BlocListener<AuthSessionCubit, AuthSessionState>(
          listenWhen: (previous, current) => previous.isInProgress != current.isInProgress && !current.isInProgress,
          listener: (context, state) {
            if (!state.isInProgress && _channelListController == null) {
              _ensureChatConnection();
            }
          },
        ),
      ],
      child: PopScopeScaffold(
        primary: false,
        floatingActionButton: const DashboardViewAnimatedChatButton(),
        body: BlocBuilder<AuthSessionCubit, AuthSessionState>(
          buildWhen: (previous, current) => previous.isInProgress != current.isInProgress,
          builder: (context, state) =>
              state.isInProgress || (_channelListController == null && !_hasShownContentDespiteConnectionIssues)
                  ? const DashboardViewLoadingWidget()
                  : _buildContent(),
        ),
      ),
    );
  }

  Widget _buildContent() {
    return Column(
      children: [
        const DashboardViewHeader(),
        DashboardViewSearchField(controller: _searchController, onSearchChanged: _handleSearchTextChanged),
         _channelListController == null
                ? DashboardViewEmptyStateWidget(onRetry: _ensureChatConnection)
                : DashboardViewListView(
                    controller: _channelListController!,
                    searchText: _searchText,
                    onChannelTap: _navigateToChannel,
                    onSearchResultsChanged: (hasNoResults) {
                      if (_hasNoResults != hasNoResults) {
                        setState(() => _hasNoResults = hasNoResults);
                      }
                    },
                  ),
      ],
    );
  }
}
