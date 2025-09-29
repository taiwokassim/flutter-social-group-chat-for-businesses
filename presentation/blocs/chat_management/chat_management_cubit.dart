// ignore_for_file: avoid_redundant_argument_values

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_social_chat/presentation/blocs/auth_session/auth_session_cubit.dart';
import 'package:flutter_social_chat/presentation/blocs/chat_management/chat_management_state.dart';
import 'package:flutter_social_chat/core/interfaces/i_chat_repository.dart';
import 'package:flutter_social_chat/core/constants/enums/chat_failure_enum.dart';
import 'package:flutter_social_chat/data/extensions/auth/database_extensions.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';

/// Manages chat-related functionality including channel creation, user selection,
/// message sending, and channel subscriptions.
class ChatManagementCubit extends Cubit<ChatManagementState> {
  /// Default image URL for new group chats
  final String randomGroupProfilePhoto = 'https://picsum.photos/200/300';

  final IChatRepository _chatRepository;
  final FirebaseFirestore _firebaseFirestore;
  final AuthSessionCubit _authCubit;

  /// Subscription to channel changes for the current user
  StreamSubscription<List<Channel>>? _currentUserChannelsSubscription;

  ChatManagementCubit(this._chatRepository, this._firebaseFirestore, this._authCubit)
      : super(ChatManagementState.empty()) {
    _subscribeToChannels();
  }

  @override
  Future<void> close() async {
    await _cancelSubscriptions();
    super.close();
  }

  //
  // Channel subscription methods
  //

  /// Subscribes to channel changes from the chat service
  void _subscribeToChannels() {
    _currentUserChannelsSubscription =
        _chatRepository.channelsThatTheUserIsIncluded.listen(_listenCurrentUserChannelsChangeStream);
  }

  /// Cancels all active subscriptions
  /// This is used when signing out or when cleaning up resources
  Future<void> _cancelSubscriptions() async {
    await _currentUserChannelsSubscription?.cancel();
    _currentUserChannelsSubscription = null;
  }

  /// Updates state when channel list changes
  Future<void> _listenCurrentUserChannelsChangeStream(List<Channel> currentUserChannels) async {
    emit(state.copyWith(currentUserChannels: currentUserChannels));
  }

  /// Resets the cubit state and cancels subscriptions
  /// Used during sign-out or when needing to clear all state
  Future<void> reset() async {
    await _cancelSubscriptions();

    emit(
      state.copyWith(
        isInProgress: false,
        isChannelCreated: false,
        isCapturedPhotoSent: false,
        listOfSelectedUsers: {},
        listOfSelectedUserIDs: {},
        channelName: '',
        currentUserChannels: [],
      ),
    );
  }

  //
  // Channel management methods
  //

  /// Updates the channel name in state
  void channelNameChanged({required String channelName}) {
    emit(state.copyWith(channelName: channelName));
  }

  /// Updates channel name validation status
  void validateChannelName({required bool isChannelNameValid}) {
    emit(
      state.copyWith(isChannelNameValid: isChannelNameValid),
    );
  }

  /// Creates a new chat channel based on selected users
  ///
  /// If [isCreateNewChatPageForCreatingGroup] is true, creates a group chat with multiple users
  /// Otherwise creates a one-to-one chat with a single selected user
  Future<void> createNewChannel({
    required bool isCreateNewChatPageForCreatingGroup,
  }) async {
    // Prevent multiple simultaneous operations
    if (state.isInProgress) {
      return;
    }

    // Check if we have necessary data
    if (state.listOfSelectedUserIDs.isEmpty) {
      emit(state.copyWith(error: ChatFailureEnum.channelCreateFailure));
      return;
    }

    // Initialize channel details
    String channelImageUrl = '';
    String channelName = state.channelName;
    final listOfMemberIDs = {...state.listOfSelectedUserIDs};

    // Always include current user in the channel
    final currentUserId = _authCubit.state.authUser.id;
    if (!listOfMemberIDs.contains(currentUserId)) {
      listOfMemberIDs.add(currentUserId);
    }

    // Validate according to chat type
    final bool hasEnoughMembers = listOfMemberIDs.length >= 2;
    final bool isValidName = isCreateNewChatPageForCreatingGroup ? state.isChannelNameValid : true;

    if (!hasEnoughMembers || !isValidName) {
      emit(state.copyWith(error: ChatFailureEnum.channelCreateFailure));
      return;
    }

    // Start operation and show loading
    emit(state.copyWith(isInProgress: true, isChannelCreated: false, error: null));

    try {
      // Handle different channel creation scenarios
      if (isCreateNewChatPageForCreatingGroup) {
        // Group chat case: use provided name and default group image
        channelName = state.channelName;
        channelImageUrl = randomGroupProfilePhoto;
      } else {
        // One-to-one chat case: use selected user's name and profile image
        if (listOfMemberIDs.length == 2) {
          // Find the other user's ID (not current user)
          final String selectedUserId = listOfMemberIDs.where((memberID) => memberID != currentUserId).toList().first;

          // Fetch user data from Firestore
          try {
            final selectedUserFromFirestore = await _firebaseFirestore.userDocument(userId: selectedUserId);
            final getSelectedUserDataFromFirestore = await selectedUserFromFirestore.get();
            final selectedUserData = getSelectedUserDataFromFirestore.data() as Map<String, dynamic>?;

            if (selectedUserData != null) {
              // Use selected user's display name and photo for the channel
              channelName = selectedUserData['displayName'] ?? 'Chat';
              channelImageUrl = selectedUserData['photoUrl'] ?? randomGroupProfilePhoto;
            } else {
              channelName = 'Chat';
              channelImageUrl = randomGroupProfilePhoto;
            }
          } catch (e) {
            // If user data fetch fails, use defaults
            channelName = 'Chat';
            channelImageUrl = randomGroupProfilePhoto;
          }
        }
      }

      // Create the channel
      final result = await _chatRepository.createNewChannel(
        listOfMemberIDs: listOfMemberIDs.toList(),
        channelName: channelName,
        channelImageUrl: channelImageUrl,
      );

      // Handle result
      result.fold(
        (failure) => emit(state.copyWith(isInProgress: false, isChannelCreated: false, error: failure)),
        (_) => emit(
          state.copyWith(
            isInProgress: false,
            isChannelCreated: true,
            // Reset user selection and channel name after successful creation
            listOfSelectedUsers: {},
            listOfSelectedUserIDs: {},
            channelName: '',
            isChannelNameValid: false,
          ),
        ),
      );
    } catch (e) {
      // Handle unexpected errors
      emit(
        state.copyWith(
          isInProgress: false,
          isChannelCreated: false,
          error: ChatFailureEnum.channelCreateFailure,
        ),
      );
    }
  }

  //
  // User selection methods
  //

  /// Selects or deselects a user when creating a chat
  ///
  /// Behavior differs based on [isCreateNewChatPageForCreatingGroup]:
  /// - For one-to-one chats, only one user can be selected, and can be toggled
  /// - For group chats, multiple users can be selected or deselected
  void selectUserWhenCreatingAGroup({
    required User user,
    required bool isCreateNewChatPageForCreatingGroup,
  }) {
    final listOfSelectedUserIDs = {...state.listOfSelectedUserIDs};
    final listOfSelectedUsers = {...state.listOfSelectedUsers};

    // Check if the user is already selected
    final isUserAlreadySelected = listOfSelectedUserIDs.contains(user.id);

    if (isUserAlreadySelected) {
      // If user is already selected, remove them (toggle off)
      listOfSelectedUserIDs.remove(user.id);
      listOfSelectedUsers.removeWhere((u) => u.id == user.id);
    } else {
      // If user is not selected yet
      if (!isCreateNewChatPageForCreatingGroup) {
        // For private chat: Clear any existing selection first (max 1)
        listOfSelectedUserIDs.clear();
        listOfSelectedUsers.clear();
        // Then add the new selection
        listOfSelectedUserIDs.add(user.id);
        listOfSelectedUsers.add(user);
      } else {
        // For group chat: Add to existing selections
        listOfSelectedUserIDs.add(user.id);
        listOfSelectedUsers.add(user);
      }
    }

    emit(
      state.copyWith(
        listOfSelectedUserIDs: listOfSelectedUserIDs,
        listOfSelectedUsers: listOfSelectedUsers,
      ),
    );
  }

  /// Selects a user and channel to send a captured photo to
  void selectUserToSendCapturedPhoto({
    required User user,
    required int userIndex,
  }) {
    final listOfSelectedUserIDs = {...state.listOfSelectedUserIDs};

    if (listOfSelectedUserIDs.isEmpty) {
      listOfSelectedUserIDs.add(user.id);
    }

    emit(state.copyWith(listOfSelectedUserIDs: listOfSelectedUserIDs, userIndex: userIndex));
  }

  /// Removes a user from the selection for sending captured photo
  void removeUserToSendCapturedPhoto({
    required User user,
  }) {
    final listOfSelectedUserIDs = {...state.listOfSelectedUserIDs};
    listOfSelectedUserIDs.remove(user.id);
    emit(state.copyWith(listOfSelectedUserIDs: listOfSelectedUserIDs, userIndex: 0));
  }

  //
  // Message sending methods
  //

  /// Sends a captured photo to selected users in a channel
  Future<void> sendCapturedPhotoToSelectedUsers({
    required String pathOfTheTakenPhoto,
    required int sizeOfTheTakenPhoto,
  }) async {
    // Prevent multiple simultaneous operations
    if (state.isInProgress) {
      return;
    }

    emit(state.copyWith(isInProgress: true));

    // Get the channel ID for the selected user
    final channelId = state.currentUserChannels[state.userIndex].id;
    if (channelId == null) {
      emit(
        state.copyWith(isInProgress: false, isCapturedPhotoSent: false, error: ChatFailureEnum.channelCreateFailure),
      );
      return;
    }

    // Add a small delay to show loading indicator for better UX
    await Future.delayed(const Duration(seconds: 1));

    // Send the photo through the chat service
    final result = await _chatRepository.sendPhotoAsMessageToTheSelectedUser(
      channelId: channelId,
      pathOfTheTakenPhoto: pathOfTheTakenPhoto,
      sizeOfTheTakenPhoto: sizeOfTheTakenPhoto,
    );

    // Update state based on result
    result.fold(
      (failure) => emit(state.copyWith(isInProgress: false, isCapturedPhotoSent: false, error: failure)),
      (_) => emit(state.copyWith(isInProgress: false, isCapturedPhotoSent: true)),
    );
  }

  //
  // Search methods
  //

  /// Searches for a channel in the existing channels list
  ///
  /// Returns true if the channel at [index] matches the [searchedText]
  /// based on channel name or member name for one-to-one chats.
  bool searchInsideExistingChannels({
    required List<Channel> listOfChannels,
    required String searchedText,
    required int index,
    required int lengthOfTheChannelMembers,
    required User oneToOneChatMember,
  }) {
    // If search text is empty, always show all channels
    if (searchedText.isEmpty) {
      return true;
    }

    // Clean up search text for case-insensitive comparison
    final editedSearchedText = searchedText.toLowerCase().trim();

    // Safety check for index bounds
    if (index < 0 || index >= listOfChannels.length) {
      return false;
    }

    // Get the channel to search in
    final channel = listOfChannels[index];

    if (lengthOfTheChannelMembers == 2) {
      // For one-to-one chats, search by member name
      return oneToOneChatMember.name.toLowerCase().trim().contains(editedSearchedText);
    } else {
      // For group chats, search by channel name
      final channelName = channel.name ?? '';
      return channelName.toLowerCase().trim().contains(editedSearchedText);
    }
  }
}
