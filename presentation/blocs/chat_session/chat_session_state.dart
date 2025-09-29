import 'package:equatable/equatable.dart';
import 'package:flutter_social_chat/domain/models/chat/chat_user_model.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';

class ChatSessionState extends Equatable {
  final ChatUserModel chatUser;
  final ConnectionStatus webSocketConnectionStatus;
  final bool isUserCheckedFromChatService;

  const ChatSessionState({
    required this.chatUser,
    required this.webSocketConnectionStatus,
    required this.isUserCheckedFromChatService,
  });

  @override
  List<Object> get props => [chatUser, webSocketConnectionStatus, isUserCheckedFromChatService];

  ChatSessionState copyWith({
    ChatUserModel? chatUser,
    ConnectionStatus? webSocketConnectionStatus,
    bool? isUserCheckedFromChatService,
  }) {
    return ChatSessionState(
      chatUser: chatUser ?? this.chatUser,
      webSocketConnectionStatus: webSocketConnectionStatus ?? this.webSocketConnectionStatus,
      isUserCheckedFromChatService: isUserCheckedFromChatService ?? this.isUserCheckedFromChatService,
    );
  }

  factory ChatSessionState.empty() {
    return ChatSessionState(
      chatUser: ChatUserModel.empty(),
      webSocketConnectionStatus: ConnectionStatus.disconnected,
      isUserCheckedFromChatService: false,
    );
  }

  bool get isChatUserConnected => chatUser != ChatUserModel.empty();
}
