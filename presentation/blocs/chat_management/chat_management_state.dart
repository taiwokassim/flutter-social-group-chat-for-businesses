import 'package:equatable/equatable.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';
import 'package:flutter_social_chat/core/constants/enums/chat_failure_enum.dart';

class ChatManagementState extends Equatable {
  const ChatManagementState({
    this.isInProgress = false,
    this.isChannelNameValid = false,
    this.isChannelCreated = false,
    this.isCapturedPhotoSent = false,
    this.channelName = '',
    this.userIndex = 0,
    this.listOfSelectedUserIDs = const {},
    this.listOfSelectedUsers = const {},
    this.currentUserChannels = const [],
    this.error,
  });

  final bool isInProgress;
  final bool isChannelNameValid;
  final bool isChannelCreated;
  final bool isCapturedPhotoSent;
  final String channelName;
  final int userIndex;
  final Set<String> listOfSelectedUserIDs;
  final Set<User> listOfSelectedUsers;
  final List<Channel> currentUserChannels;
  final ChatFailureEnum? error;

  @override
  List<Object?> get props => [
        isInProgress,
        isChannelNameValid,
        isChannelCreated,
        isCapturedPhotoSent,
        channelName,
        userIndex,
        listOfSelectedUserIDs,
        listOfSelectedUsers,
        currentUserChannels,
        error,
      ];

  ChatManagementState copyWith({
    bool? isInProgress,
    bool? isChannelNameValid,
    bool? isChannelCreated,
    bool? isCapturedPhotoSent,
    String? channelName,
    int? userIndex,
    Set<String>? listOfSelectedUserIDs,
    Set<User>? listOfSelectedUsers,
    List<Channel>? currentUserChannels,
    ChatFailureEnum? error,
  }) {
    return ChatManagementState(
      isInProgress: isInProgress ?? this.isInProgress,
      isChannelNameValid: isChannelNameValid ?? this.isChannelNameValid,
      isChannelCreated: isChannelCreated ?? this.isChannelCreated,
      isCapturedPhotoSent: isCapturedPhotoSent ?? this.isCapturedPhotoSent,
      channelName: channelName ?? this.channelName,
      userIndex: userIndex ?? this.userIndex,
      listOfSelectedUserIDs: listOfSelectedUserIDs ?? this.listOfSelectedUserIDs,
      listOfSelectedUsers: listOfSelectedUsers ?? this.listOfSelectedUsers,
      currentUserChannels: currentUserChannels ?? this.currentUserChannels,
      error: error ?? this.error,
    );
  }

  factory ChatManagementState.empty() => const ChatManagementState();
}
