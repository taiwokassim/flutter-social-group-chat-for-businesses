import 'package:flutter_social_chat/core/constants/enums/chat_failure_enum.dart';
import 'package:flutter_social_chat/domain/models/chat/chat_user_model.dart';
import 'package:fpdart/fpdart.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart' hide Unit;

/// Provides an abstraction layer for chat functionality
/// regardless of the underlying implementation.
abstract class IChatRepository {
  /// Stream of changes to the current chat user's authentication state
  Stream<ChatUserModel> get chatAuthStateChanges;

  /// Stream of channels that the current user is a member of
  Stream<List<Channel>> get channelsThatTheUserIsIncluded;

  /// Disconnects the current user from the chat service
  Future<Either<ChatFailureEnum, Unit>> disconnectUser();

  /// Connects the current authenticated user to the chat service
  Future<Either<ChatFailureEnum, Unit>> connectTheCurrentUser();

  /// Creates a new chat channel with the specified members and metadata
  /// 
  /// [listOfMemberIDs] must contain at least one member
  /// [channelName] is the display name for the channel
  /// [channelImageUrl] is the avatar/image URL for the channel
  Future<Either<ChatFailureEnum, Unit>> createNewChannel({
    required List<String> listOfMemberIDs,
    required String channelName,
    required String channelImageUrl,
  });

  /// Sends a photo as a message to the selected channel
  /// 
  /// [sizeOfTheTakenPhoto] is the file size in bytes
  /// [channelId] is the unique identifier for the target channel
  /// [pathOfTheTakenPhoto] is the local file path to the photo
  Future<Either<ChatFailureEnum, Unit>> sendPhotoAsMessageToTheSelectedUser({
    required int sizeOfTheTakenPhoto,
    required String channelId,
    required String pathOfTheTakenPhoto,
  });
}
