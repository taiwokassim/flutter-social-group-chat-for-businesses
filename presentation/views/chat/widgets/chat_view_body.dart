import 'package:flutter/material.dart';
import 'package:flutter_social_chat/presentation/design_system/colors.dart';
import 'package:flutter_social_chat/presentation/design_system/widgets/custom_progress_indicator.dart';
import 'package:flutter_social_chat/presentation/design_system/widgets/custom_text.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_social_chat/presentation/views/chat/widgets/chat_view_thread_widget.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';

class ChatViewBody extends StatelessWidget {
  const ChatViewBody({super.key});

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);

    return Column(
      children: [
        Expanded(
          child: StreamMessageListView(
            threadBuilder: (_, parentMessage) {
              if (parentMessage == null) return const SizedBox.shrink();
              return ChatViewThreadWidget(parent: parentMessage);
            },
            messageBuilder: (context, details, messages, defaultMessage) {
              return defaultMessage.copyWith(showUserAvatar: DisplayWidget.show, showTimestamp: true);
            },
            emptyBuilder: (context) => Center(
              child: CustomText(text: localization?.sendMessageToStartConversation ?? ''),
            ),
            loadingBuilder: (context) => const Center(
              child: CustomProgressIndicator(progressIndicatorColor: customIndigoColor),
            ),
          ),
        ),
        const StreamMessageInput(
          autoCorrect: false,
          activeSendIcon: Icon(Icons.send, size: 30, color: customIndigoColor),
          idleSendIcon: Icon(Icons.send, size: 30, color: customGreyColor600),
        ),
      ],
    );
  }
}
