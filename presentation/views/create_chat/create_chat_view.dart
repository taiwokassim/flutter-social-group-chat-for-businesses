import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_social_chat/presentation/blocs/chat_management/chat_management_cubit.dart';
import 'package:flutter_social_chat/presentation/blocs/chat_management/chat_management_state.dart';
import 'package:flutter_social_chat/presentation/design_system/colors.dart';
import 'package:flutter_social_chat/presentation/design_system/widgets/custom_app_bar.dart';
import 'package:flutter_social_chat/presentation/design_system/widgets/custom_progress_indicator.dart';
import 'package:flutter_social_chat/presentation/design_system/widgets/popscope_scaffold.dart';
import 'package:flutter_social_chat/core/constants/enums/router_enum.dart';
import 'package:go_router/go_router.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';
import 'package:flutter_social_chat/presentation/views/create_chat/widgets/create_chat_view_body.dart';

class CreateChatView extends StatefulWidget {
  const CreateChatView({super.key, required this.userListController, this.isCreateNewChatPageForCreatingGroup});

  final StreamUserListController userListController;
  final bool? isCreateNewChatPageForCreatingGroup;

  @override
  State<CreateChatView> createState() => _CreateChatViewState();
}

class _CreateChatViewState extends State<CreateChatView> {
  late final StreamUserListController _userListController;
  bool _isControllerOwned = false;

  @override
  void initState() {
    super.initState();
    // If the controller is active, use it. Otherwise create a new one
    if (widget.userListController.client.state.currentUser != null) {
      _userListController = widget.userListController;
    } else {
      // Create a new controller if the provided one is not valid
      _isControllerOwned = true;
      _userListController = _createFreshController();
    }
  }

  @override
  void dispose() {
    // Only dispose the controller if we created it
    if (_isControllerOwned) {
      _userListController.dispose();
    }
    super.dispose();
  }

  StreamUserListController _createFreshController() {
    final client = StreamChat.of(context).client;
    final currentUser = client.state.currentUser;

    if (currentUser == null) {
      throw Exception('Cannot create user list controller: No authenticated user found');
    }

    return StreamUserListController(
      client: client,
      limit: 25,
      filter: Filter.and([Filter.notEqual('id', currentUser.id)]),
      sort: [const SortOption('name', direction: 1)],
    );
  }

  void _navigateBack() {
    context.read<ChatManagementCubit>().reset();
    context.go(RouterEnum.dashboardView.routeName);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ChatManagementCubit, ChatManagementState>(
      listener: (context, state) {
        if (state.isChannelCreated) {
          context.read<ChatManagementCubit>().reset();
          context.go(RouterEnum.dashboardView.routeName);
        }
      },
      child: PopScopeScaffold(
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop) {
            _navigateBack();
          }
        },
        appBar: CustomAppBar(
          isTitleCentered: false,
          leading: IconButton(
            onPressed: _navigateBack,
            icon: const Icon(CupertinoIcons.back, color: black),
          ),
        ),
        body: BlocBuilder<ChatManagementCubit, ChatManagementState>(
          builder: (context, state) {
            if (state.isInProgress) {
              return const CustomProgressIndicator(progressIndicatorColor: customIndigoColor);
            } else {
              return CreateChatViewBody(
                userListController: _userListController,
                isCreateNewChatPageForCreatingGroup: widget.isCreateNewChatPageForCreatingGroup,
              );
            }
          },
        ),
      ),
    );
  }
}
