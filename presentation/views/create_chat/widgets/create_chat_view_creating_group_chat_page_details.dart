import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_social_chat/presentation/blocs/chat_management/chat_management_cubit.dart';
import 'package:flutter_social_chat/presentation/blocs/chat_management/chat_management_state.dart';
import 'package:flutter_social_chat/presentation/design_system/colors.dart';
import 'package:flutter_social_chat/presentation/design_system/widgets/custom_text.dart';
import 'package:flutter_social_chat/presentation/views/create_chat/widgets/create_chat_view_group_name_form_field.dart';
import 'package:flutter_social_chat/presentation/views/create_chat/widgets/create_chat_view_new_chat_button.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class CreateChatViewCreatingGroupChatPageDetails extends StatelessWidget {
  const CreateChatViewCreatingGroupChatPageDetails({
    super.key,
    this.isCreateNewChatPageForCreatingGroup,
  });

  final bool? isCreateNewChatPageForCreatingGroup;

  @override
  Widget build(BuildContext context) {
    final appLocalizations = AppLocalizations.of(context);

    return BlocBuilder<ChatManagementCubit, ChatManagementState>(
      builder: (context, state) {
        return Container(
          decoration: BoxDecoration(
            color: white,
            boxShadow: [
              BoxShadow(color: black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, -2)),
            ],
          ),
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (state.listOfSelectedUserIDs.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: customIndigoColor.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: customIndigoColor.withValues(alpha: 0.1)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.people_alt_outlined, size: 18, color: customIndigoColor),
                        const SizedBox(width: 8),
                        Expanded(
                          child: CustomText(
                            text: '${state.listOfSelectedUserIDs.length} ${appLocalizations?.usersSelected ?? ''}',
                            fontSize: 14,
                            color: customIndigoColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        // Minimum members indicator
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: state.listOfSelectedUserIDs.length >= 2
                                ? successColor.withValues(alpha: 0.1)
                                : customOrangeColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: CustomText(
                            text: state.listOfSelectedUserIDs.length >= 2
                                ? appLocalizations?.enough ?? ''
                                : appLocalizations?.min2Required ?? '',
                            fontSize: 12,
                            color: state.listOfSelectedUserIDs.length >= 2 ? successColor : customOrangeColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              const CreateChatViewGroupNameFormField(),
              CreateChatViewNewChatButton(
                isCreateNewChatPageForCreatingGroup: isCreateNewChatPageForCreatingGroup!,
              ),
            ],
          ),
        );
      },
    );
  }
}
