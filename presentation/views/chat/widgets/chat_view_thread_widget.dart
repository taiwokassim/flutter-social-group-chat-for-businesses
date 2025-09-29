import 'package:flutter/material.dart';
import 'package:flutter_social_chat/presentation/design_system/colors.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';

/// Thread page shown when a thread is opened
class ChatViewThreadWidget extends StatelessWidget {
  const ChatViewThreadWidget({super.key, required this.parent});

  final Message parent;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: StreamThreadHeader(parent: parent),
      body: Column(
        children: [
          Expanded(
            child: StreamMessageListView(parentMessage: parent),
          ),
          const StreamMessageInput(
            activeSendIcon: Icon(Icons.send, size: 30, color: customIndigoColor),
            idleSendIcon: Icon(Icons.send, size: 30, color: customGreyColor600),
          ),
        ],
      ),
    );
  }
}
