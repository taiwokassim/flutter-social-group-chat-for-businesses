import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_social_chat/core/constants/enums/router_enum.dart';
import 'package:flutter_social_chat/presentation/blocs/profile_management/profile_manager_cubit.dart';
import 'package:flutter_social_chat/presentation/blocs/profile_management/profile_manager_state.dart';
import 'package:flutter_social_chat/presentation/blocs/auth_session/auth_session_cubit.dart';
import 'package:flutter_social_chat/presentation/blocs/auth_session/auth_session_state.dart';
import 'package:flutter_social_chat/presentation/design_system/widgets/custom_loading_indicator.dart';
import 'package:flutter_social_chat/presentation/design_system/widgets/popscope_scaffold.dart';
import 'package:flutter_social_chat/presentation/views/onboarding/widgets/onboarding_view_body.dart';
import 'package:go_router/go_router.dart';

/// User onboarding page shown after successful authentication
///
/// This page allows users to complete their profile setup by:
/// 1. Entering a valid username
/// 2. Viewing their default profile image (which can be changed later)
/// 3. Submitting their profile information
///
/// The page listens to two BLoC states:
/// - AuthSessionCubit: To detect when onboarding is completed and navigate accordingly
/// - ProfileManagerCubit: To manage loading states during profile creation
class OnboardingView extends StatelessWidget {
  const OnboardingView({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        // Listen for onboarding completion in AuthSessionCubit
        BlocListener<AuthSessionCubit, AuthSessionState>(
          listenWhen: (previous, current) =>
              !previous.authUser.isOnboardingCompleted && current.authUser.isOnboardingCompleted,
          listener: _handleOnboardingCompleted,
        ),
        
        // Listen for loading state changes in ProfileManagerCubit
        BlocListener<ProfileManagerCubit, ProfileManagerState>(
          listenWhen: (previous, current) => previous.isInProgress != current.isInProgress,
          listener: _handleLoadingStateChanges,
        ),
      ],
      child: const PopScopeScaffold(
        body: OnboardingViewBody(),
      ),
    );
  }
  
  /// Handles navigation when onboarding is completed
  void _handleOnboardingCompleted(BuildContext context, _) {
    CustomLoadingIndicator.of(context).hide();
    context.go(RouterEnum.dashboardView.routeName);
  }
  
  /// Manages loading indicator based on profile creation state
  void _handleLoadingStateChanges(BuildContext context, ProfileManagerState state) {
    if (state.isInProgress) {
      CustomLoadingIndicator.of(context).show();
    } else {
      CustomLoadingIndicator.of(context).hide();
    }
  }
}
