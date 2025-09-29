import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_social_chat/presentation/blocs/chat_management/chat_management_cubit.dart';
import 'package:flutter_social_chat/presentation/blocs/chat_management/chat_management_state.dart';
import 'package:flutter_social_chat/presentation/design_system/colors.dart';
import 'package:flutter_social_chat/presentation/design_system/widgets/custom_text.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class CreateChatViewNewChatButton extends StatefulWidget {
  const CreateChatViewNewChatButton({
    super.key,
    required this.isCreateNewChatPageForCreatingGroup,
  });

  final bool isCreateNewChatPageForCreatingGroup;

  @override
  State<CreateChatViewNewChatButton> createState() => _CreateChatViewNewChatButtonState();
}

class _CreateChatViewNewChatButtonState extends State<CreateChatViewNewChatButton> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(vsync: this, duration: const Duration(milliseconds: 150));

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = AppLocalizations.of(context);

    return BlocBuilder<ChatManagementCubit, ChatManagementState>(
      buildWhen: (previous, current) =>
          previous.listOfSelectedUserIDs != current.listOfSelectedUserIDs ||
          previous.isChannelNameValid != current.isChannelNameValid ||
          previous.isInProgress != current.isInProgress,
      builder: (context, state) {
        // For group chat: require valid name AND at least 2 selected users
        // For private chat: require only 1 selected user
        final bool isUserSelected = state.listOfSelectedUserIDs.isNotEmpty;
        final bool hasEnoughUsers =
            widget.isCreateNewChatPageForCreatingGroup ? state.listOfSelectedUserIDs.length >= 2 : isUserSelected;

        final bool shouldEnableButton = hasEnoughUsers &&
            (widget.isCreateNewChatPageForCreatingGroup ? state.isChannelNameValid : true) &&
            !state.isInProgress;

        // Get appropriate button text based on state
        final String buttonText = state.isInProgress
            ? (widget.isCreateNewChatPageForCreatingGroup
                ? appLocalizations?.creatingGroup ?? ''
                : appLocalizations?.startingChat ?? '')
            : widget.isCreateNewChatPageForCreatingGroup
                ? (shouldEnableButton
                    ? (appLocalizations?.startGroupChat ?? '')
                    : (appLocalizations?.chatButtonDisabled ?? ''))
                : (shouldEnableButton
                    ? (appLocalizations?.startPrivateChat ?? '')
                    : (appLocalizations?.selectUserToChat ?? ''));

        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
          child: AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return Transform.scale(
                scale: _scaleAnimation.value,
                child: child,
              );
            },
            child: Material(
              elevation: shouldEnableButton ? 4 : 0,
              borderRadius: BorderRadius.circular(12),
              color: transparent,
              child: Tooltip(
                message: shouldEnableButton || state.isInProgress
                    ? ''
                    : widget.isCreateNewChatPageForCreatingGroup
                        ? appLocalizations?.selectUsersAndNameGroup ?? ''
                        : (appLocalizations?.selectUserToChat ?? ''),
                preferBelow: true,
                verticalOffset: 20,
                child: GestureDetector(
                  onTapDown: shouldEnableButton
                      ? (_) {
                          setState(() {
                            _isPressed = true;
                          });
                          _animationController.forward();
                        }
                      : null,
                  onTapUp: shouldEnableButton
                      ? (_) {
                          setState(() {
                            _isPressed = false;
                          });
                          _animationController.reverse();
                          context.read<ChatManagementCubit>().createNewChannel(
                                isCreateNewChatPageForCreatingGroup: widget.isCreateNewChatPageForCreatingGroup,
                              );
                        }
                      : null,
                  onTapCancel: shouldEnableButton
                      ? () {
                          setState(() {
                            _isPressed = false;
                          });
                          _animationController.reverse();
                        }
                      : null,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: double.infinity,
                    height: 56,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      gradient: LinearGradient(
                        colors: state.isInProgress
                            ? [
                                customIndigoColor.withValues(alpha: 0.7),
                                customIndigoColor.withValues(alpha: 0.6),
                              ]
                            : shouldEnableButton
                                ? (_isPressed
                                    ? [
                                        customIndigoColor.withValues(alpha: 0.8),
                                        customIndigoColor,
                                      ]
                                    : [
                                        customIndigoColor,
                                        customIndigoColor.withValues(alpha: 0.8),
                                      ])
                                : [
                                    customGreyColor400,
                                    customGreyColor300,
                                  ],
                      ),
                      boxShadow: shouldEnableButton && !state.isInProgress
                          ? [
                              BoxShadow(
                                color: customIndigoColor.withValues(alpha: 0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ]
                          : null,
                    ),
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (state.isInProgress)
                            const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(white),
                              ),
                            )
                          else
                            Icon(
                              widget.isCreateNewChatPageForCreatingGroup
                                  ? Icons.group_add_rounded
                                  : Icons.chat_bubble_outline_rounded,
                              color: white,
                              size: 24,
                            ),
                          const SizedBox(width: 12),
                          CustomText(
                            text: buttonText,
                            color: white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
