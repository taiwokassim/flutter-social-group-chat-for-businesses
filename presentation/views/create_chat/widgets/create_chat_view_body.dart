import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_social_chat/presentation/blocs/chat_management/chat_management_cubit.dart';
import 'package:flutter_social_chat/presentation/blocs/chat_management/chat_management_state.dart';
import 'package:flutter_social_chat/presentation/design_system/colors.dart';
import 'package:flutter_social_chat/presentation/design_system/widgets/custom_progress_indicator.dart';
import 'package:flutter_social_chat/presentation/design_system/widgets/custom_text.dart';
import 'package:flutter_social_chat/presentation/views/create_chat/widgets/create_chat_view_new_chat_button.dart';
import 'package:flutter_social_chat/presentation/views/create_chat/widgets/create_chat_view_creating_group_chat_page_details.dart';
import 'package:flutter_social_chat/presentation/views/create_chat/widgets/create_chat_view_user_list_view.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';

/// A stateless widget that displays the body content of the create chat view.
///
/// This widget includes the status header, user list view, and appropriate
/// bottom action components based on whether creating a group or private chat.
class CreateChatViewBody extends StatelessWidget {
  const CreateChatViewBody({
    super.key,
    required this.userListController,
    required this.isCreateNewChatPageForCreatingGroup,
  });

  /// Controller for the user list view.
  final StreamUserListController userListController;

  /// Whether the view is for creating a group chat (true) or private chat (false).
  final bool? isCreateNewChatPageForCreatingGroup;

  @override
  Widget build(BuildContext context) {
    final appLocalizations = AppLocalizations.of(context);

    return BlocBuilder<ChatManagementCubit, ChatManagementState>(
      builder: (context, state) {
        if (state.isInProgress) {
          return const CustomProgressIndicator(progressIndicatorColor: customIndigoColor);
        } else {
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  decoration: BoxDecoration(
                    color: state.listOfSelectedUserIDs.isEmpty
                        ? customIndigoColor.withValues(alpha: 0.05)
                        : successColor.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: state.listOfSelectedUserIDs.isEmpty
                          ? customIndigoColor.withValues(alpha: 0.1)
                          : successColor.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        state.listOfSelectedUserIDs.isEmpty
                            ? (isCreateNewChatPageForCreatingGroup!
                                ? Icons.group_add_outlined
                                : Icons.person_add_alt_outlined)
                            : (isCreateNewChatPageForCreatingGroup! ? Icons.group : Icons.person),
                        color: state.listOfSelectedUserIDs.isEmpty ? customIndigoColor : successColor,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: CustomText(
                          text: state.listOfSelectedUserIDs.isEmpty
                              ? (appLocalizations?.selectUserToChat ?? '')
                              : (isCreateNewChatPageForCreatingGroup!
                                  ? '${state.listOfSelectedUserIDs.length} ${appLocalizations?.usersSelected ?? ''}'
                                  : (appLocalizations?.readyToCreateGroup ?? '')),
                          color: state.listOfSelectedUserIDs.isEmpty ? customIndigoColor : successColor,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // User List - Scrollable
              Expanded(
                child: CreateChatViewUserListView(
                  userListController: userListController,
                  isCreateNewChatPageForCreatingGroup: isCreateNewChatPageForCreatingGroup,
                ),
              ),

              SafeArea(
                child: isCreateNewChatPageForCreatingGroup!
                    ? CreateChatViewCreatingGroupChatPageDetails(
                        isCreateNewChatPageForCreatingGroup: isCreateNewChatPageForCreatingGroup,
                      )
                    : CreateChatViewNewChatButton(
                        isCreateNewChatPageForCreatingGroup: isCreateNewChatPageForCreatingGroup!,
                      ),
              ),
            ],
          );
        }
      },
    );
  }
}
