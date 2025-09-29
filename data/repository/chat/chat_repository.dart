import 'package:flutter/foundation.dart';
import 'package:flutter_social_chat/core/interfaces/i_auth_repository.dart';
import 'package:flutter_social_chat/domain/models/chat/chat_user_model.dart';
import 'package:flutter_social_chat/core/interfaces/i_chat_repository.dart';
import 'package:flutter_social_chat/data/extensions/chat/chat_user_extensions.dart';
import 'package:flutter_social_chat/core/constants/enums/chat_failure_enum.dart';
import 'package:flutter_social_chat/core/config/env_config.dart';
import 'package:fpdart/fpdart.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart' hide Unit;
import 'dart:convert';
import 'package:crypto/crypto.dart';

class ChatRepository implements IChatRepository {
  ChatRepository(this._authRepository, this._streamChatClient);

  final IAuthRepository _authRepository;
  final StreamChatClient _streamChatClient;

  // Stream Chat API Secret is retrieved from environment configuration
  // No hardcoded secrets

  @override
  Stream<ChatUserModel> get chatAuthStateChanges {
    return _streamChatClient.state.currentUserStream.map(
      (OwnUser? user) => user?.toDomain() ?? ChatUserModel.empty(),
    );
  }

  @override
  Future<Either<ChatFailureEnum, Unit>> disconnectUser() async {
    try {
      await _streamChatClient.disconnectUser();
      return right(unit);
    } catch (e) {
      debugPrint('Error disconnecting user: $e');
      return left(ChatFailureEnum.serverError);
    }
  }

  @override
  Stream<List<Channel>> get channelsThatTheUserIsIncluded {
    try {
      final currentUser = _streamChatClient.state.currentUser;
      if (currentUser == null) {
        return Stream.value([]);
      }

      return _streamChatClient
          .queryChannels(
            filter: Filter.in_('members', [currentUser.id]),
          )
          .map((channels) => channels);
    } catch (e) {
      debugPrint('Error fetching channels: $e');
      return Stream.value([]);
    }
  }

  /// Generates a Stream Chat token for the given user ID
  String _generateToken(String userId) {
    // In production, token generation should happen on the server
    // This is only for development purposes
    
    // Get API secret from environment config
    final apiSecret = EnvConfig.instance.streamChatApiSecret;

    // Header
    final header = {'alg': 'HS256', 'typ': 'JWT'};
    final encodedHeader = base64Url.encode(utf8.encode(json.encode(header)));

    // Payload with the user ID
    final payload = {'user_id': userId};
    final encodedPayload = base64Url.encode(utf8.encode(json.encode(payload)));

    // Create signature
    final message = '$encodedHeader.$encodedPayload';
    final hmac = Hmac(sha256, utf8.encode(apiSecret));
    final digest = hmac.convert(utf8.encode(message));
    final signature = base64Url.encode(digest.bytes);

    // Return the JWT token
    return '$encodedHeader.$encodedPayload.$signature';
  }

  @override
  Future<Either<ChatFailureEnum, Unit>> connectTheCurrentUser() async {
    try {
      final signedInUserOption = await _authRepository.getSignedInUser();

      final signedInUser = signedInUserOption.fold(
        () => throw Exception('User not authenticated'),
        (user) => user,
      );

      // Generate a token specific to this user
      final userToken = _generateToken(signedInUser.id);

      // Log token info for debugging
      debugPrint('Connecting user: ${signedInUser.id}');

      await _streamChatClient.connectUser(
        User(
          id: signedInUser.id,
          name: signedInUser.userName,
          image: signedInUser.photoUrl,
        ),
        userToken,
      );
      return right(unit);
    } catch (e) {
      debugPrint('Error connecting user: $e');
      return left(ChatFailureEnum.connectionFailure);
    }
  }

  @override
  Future<Either<ChatFailureEnum, Unit>> createNewChannel({
    required List<String> listOfMemberIDs,
    required String channelName,
    required String channelImageUrl,
  }) async {
    try {
      if (listOfMemberIDs.isEmpty) {
        return left(ChatFailureEnum.channelCreateFailure);
      }

      final randomId = const Uuid().v1();

      await _streamChatClient.createChannel(
        'messaging',
        channelId: randomId,
        channelData: {
          'members': listOfMemberIDs,
          'name': channelName,
          'image': channelImageUrl,
          'created_at': DateTime.now().toIso8601String(),
        },
      );
      return right(unit);
    } catch (e) {
      debugPrint('Error creating channel: $e');
      return left(ChatFailureEnum.channelCreateFailure);
    }
  }

  @override
  Future<Either<ChatFailureEnum, Unit>> sendPhotoAsMessageToTheSelectedUser({
    required String channelId,
    required int sizeOfTheTakenPhoto,
    required String pathOfTheTakenPhoto,
  }) async {
    if (channelId.isEmpty || pathOfTheTakenPhoto.isEmpty) {
      return left(ChatFailureEnum.imageUploadFailure);
    }

    try {
      final randomMessageId = const Uuid().v1();

      final signedInUserOption = await _authRepository.getSignedInUser();
      final signedInUser = signedInUserOption.fold(
        () => throw Exception('User not authenticated'),
        (user) => user,
      );
      final user = User(id: signedInUser.id);

      // Upload the image first
      final response = await _streamChatClient.sendImage(
        AttachmentFile(
          size: sizeOfTheTakenPhoto,
          path: pathOfTheTakenPhoto,
        ),
        channelId,
        'messaging',
      );

      // Create and send the message with the image
      final imageUrl = response.file;
      final image = Attachment(
        type: 'image',
        imageUrl: imageUrl,
      );

      final message = Message(
        user: user,
        id: randomMessageId,
        createdAt: DateTime.now(),
        attachments: [image],
      );

      await _streamChatClient.sendMessage(message, channelId, 'messaging');
      return right(unit);
    } catch (e) {
      debugPrint('Error sending photo message: $e');
      return left(ChatFailureEnum.imageUploadFailure);
    }
  }
}
