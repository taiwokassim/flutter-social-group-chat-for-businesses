import 'dart:async';

import 'package:flutter_social_chat/core/di/dependency_injector.dart';
import 'package:flutter_social_chat/presentation/blocs/chat_session/chat_session_state.dart';
import 'package:flutter_social_chat/domain/models/chat/chat_user_model.dart';
import 'package:flutter_social_chat/core/interfaces/i_chat_repository.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';

/// Manages the chat session state, including user data and connection status.
///
/// This cubit is responsible for:
/// 1. Tracking Stream Chat connection status
/// 2. Storing the current chat user information
/// 3. Providing methods to sync state with the actual Stream Chat client
/// 4. Persisting chat session data using HydratedBloc
class ChatSessionCubit extends HydratedCubit<ChatSessionState> {
  final IChatRepository _chatRepository;
  StreamSubscription<ChatUserModel>? _chatUserSubscription;
  Timer? _connectionCheckTimer;

  ChatSessionCubit(this._chatRepository) : super(ChatSessionState.empty()) {
    _initializeSubscriptions();
  }

  /// Initializes all subscriptions and listeners
  void _initializeSubscriptions() {
    _chatUserSubscription = _chatRepository.chatAuthStateChanges.listen(_listenChatUserAuthStateChangesStream);

    // Setup a periodic connection check to ensure UI state reflects reality
    _connectionCheckTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      _checkConnectionStatus();
    });
  }

  /// Checks if the actual connection status matches our state
  void _checkConnectionStatus() {
    try {
      final client = getIt<StreamChatClient>();
      final isClientConnected = client.state.currentUser != null;

      if (isClientConnected != state.isChatUserConnected) {
        syncWithClientState();
      }
    } catch (e) {
      // Ignore errors in periodic connection check
    }
  }

  @override
  Future<void> close() async {
    await _chatUserSubscription?.cancel();
    _chatUserSubscription = null;

    _connectionCheckTimer?.cancel();
    _connectionCheckTimer = null;

    super.close();
  }

  /// Resets the chat session state to empty
  ///
  /// This is used when signing out to clear any cached data and
  /// ensure a clean state for the next login session.
  void reset() {
    emit(ChatSessionState.empty());
  }

  /// Forces a synchronization between the UI state and the actual client connection state
  ///
  /// This is useful when:
  /// - We detect the UI is out of sync with the actual client state
  /// - After a reconnection to ensure state is accurate
  /// - When recovering from errors in the connection
  void syncWithClientState() {
    try {
      final client = getIt<StreamChatClient>();
      final streamUser = client.state.currentUser;
      final isActuallyConnected = streamUser != null;

      // If client is connected but our state doesn't reflect it, update state
      if (isActuallyConnected && !state.isUserCheckedFromChatService) {
        final chatUser = _extractChatUserFromStreamUser(streamUser);

        emit(
          state.copyWith(
            chatUser: chatUser,
            isUserCheckedFromChatService: true,
            webSocketConnectionStatus: ConnectionStatus.connected,
          ),
        );
      }
      // If client is not connected but our state indicates it is
      else if (!isActuallyConnected && state.isUserCheckedFromChatService) {
        emit(
          state.copyWith(
            chatUser: ChatUserModel.empty(),
            isUserCheckedFromChatService: false,
            webSocketConnectionStatus: ConnectionStatus.disconnected,
          ),
        );
      }
    } catch (e) {
      // If we encounter an error accessing the client, assume disconnected
      if (state.isUserCheckedFromChatService || state.isChatUserConnected) {
        emit(
          state.copyWith(
            chatUser: ChatUserModel.empty(),
            isUserCheckedFromChatService: false,
            webSocketConnectionStatus: ConnectionStatus.disconnected,
          ),
        );
      }
    }
  }

  /// Updates connection status to indicate disconnection
  ///
  /// Used when a disconnection is detected or during manual sign-out
  void setDisconnected() {
    emit(
      state.copyWith(
        chatUser: ChatUserModel.empty(),
        isUserCheckedFromChatService: false,
        webSocketConnectionStatus: ConnectionStatus.disconnected,
      ),
    );
  }

  /// Handles changes in the chat user state from the repository stream
  Future<void> _listenChatUserAuthStateChangesStream(
    ChatUserModel chatUser,
  ) async {
    emit(
      state.copyWith(
        chatUser: chatUser,
        isUserCheckedFromChatService: true,
        webSocketConnectionStatus: ConnectionStatus.connected,
      ),
    );
  }

  /// Extracts a ChatUserModel from a Stream chat User object
  ChatUserModel _extractChatUserFromStreamUser(User streamUser) {
    final createdAt = streamUser.createdAt?.toIso8601String() ?? DateTime.now().toIso8601String();
    final extraData = streamUser.extraData;
    final isUserBanned = extraData['banned'] as bool? ?? false;

    return ChatUserModel(
      createdAt: createdAt,
      isUserBanned: isUserBanned,
    );
  }

  // HydratedBloc implementation

  @override
  Map<String, dynamic> toJson(ChatSessionState state) {
    return {
      'chatUser': state.chatUser.toJson(),
      'isUserCheckedFromChatService': state.isUserCheckedFromChatService,
      'webSocketConnectionStatus': state.webSocketConnectionStatus.index,
    };
  }

  @override
  ChatSessionState fromJson(Map<String, dynamic> json) {
    return ChatSessionState.empty().copyWith(
      chatUser: ChatUserModel.fromJson(json['chatUser']),
      isUserCheckedFromChatService: json['isUserCheckedFromChatService'] as bool? ?? false,
      webSocketConnectionStatus:
          ConnectionStatus.values[json['webSocketConnectionStatus'] as int? ?? ConnectionStatus.disconnected.index],
    );
  }
}
