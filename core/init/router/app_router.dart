import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_social_chat/core/constants/enums/router_enum.dart';
import 'package:flutter_social_chat/core/init/router/navigation_state_codec.dart';
import 'package:flutter_social_chat/core/init/router/custom_page_builder_widget.dart';
import 'package:flutter_social_chat/presentation/blocs/phone_number_sign_in/phone_number_sign_in_state.dart';
import 'package:flutter_social_chat/presentation/views/bottom_tab/bottom_tab_view.dart';
import 'package:flutter_social_chat/presentation/views/dashboard/dashboard_view.dart';
import 'package:flutter_social_chat/presentation/views/chat/chat_view.dart';
import 'package:flutter_social_chat/presentation/views/create_chat/create_chat_view.dart';
import 'package:flutter_social_chat/presentation/views/landing/landing_view.dart';
import 'package:flutter_social_chat/presentation/views/onboarding/onboarding_view.dart';
import 'package:flutter_social_chat/presentation/views/profile/profile_view.dart';
import 'package:flutter_social_chat/presentation/views/sign_in/sign_in_view.dart';
import 'package:flutter_social_chat/presentation/views/sms_verification/sms_verification_view.dart';
import 'package:go_router/go_router.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';
import 'package:fpdart/fpdart.dart';

/// Manages application routing configuration and navigation
class AppRouter {
  AppRouter();

  // Navigator keys for different navigation scopes
  static final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');
  static final GlobalKey<NavigatorState> _shellNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'shell');

  // Toast observer for notifications
  final BotToastNavigatorObserver botToastNavigatorObserver = BotToastNavigatorObserver();

  // Main router configuration
  late final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    debugLogDiagnostics: kDebugMode,
    observers: [botToastNavigatorObserver],
    initialLocation: RouterEnum.initialLocation.routeName,
    extraCodec: NavigationStateCodec(),
    routes: [
      _initialRoute,
      _bottomTabShellRoute,
      _chatRoute,
      _signInRoute,
      _smsVerificationRoute,
      _createNewChatRoute,
      _onboardingRoute,
    ],
  );

  // Route definitions
  GoRoute get _initialRoute => GoRoute(
        path: RouterEnum.initialLocation.routeName,
        pageBuilder: (context, state) => customPageBuilderWidget(
          context,
          state,
          const LandingView(),
        ),
      );

  ShellRoute get _bottomTabShellRoute => ShellRoute(
        navigatorKey: _shellNavigatorKey,
        pageBuilder: (context, state, child) {
          return customPageBuilderWidget(
            context,
            state,
            BottomTabView(child: child),
          );
        },
        routes: [
          GoRoute(
            path: RouterEnum.dashboardView.routeName,
            pageBuilder: (context, state) {
              return customPageBuilderWidget(
                context,
                state,
                const DashboardView(),
              );
            },
          ),
          GoRoute(
            path: RouterEnum.profileView.routeName,
            pageBuilder: (context, state) => customPageBuilderWidget(
              context,
              state,
              const ProfileView(),
            ),
          ),
        ],
      );

  GoRoute get _chatRoute => GoRoute(
        path: RouterEnum.chatView.routeName,
        builder: (context, state) {
          final extraParameters = state.extra is Map<String, dynamic>
              ? state.extra as Map<String, dynamic>
              : {'channel': state.extra as Channel?};

          final channel = extraParameters['channel'] as Channel?;
          if (channel == null) {
            throw Exception('Missing required channel parameter for ChatView');
          }

          return ChatView(channel: channel);
        },
      );

  GoRoute get _signInRoute => GoRoute(
        path: RouterEnum.signInView.routeName,
        pageBuilder: (context, state) => customPageBuilderWidget(
          context,
          state,
          const SignInView(),
        ),
      );

  GoRoute get _smsVerificationRoute => GoRoute(
        path: RouterEnum.smsVerificationView.routeName,
        builder: (context, state) {
          final String? encodedExtras = state.extra as String?;
          final extras = encodedExtras != null ? NavigationStateCodec.decodeString(encodedExtras) : {};

          final phoneNumberSignInState = PhoneNumberSignInState(
            phoneNumber: extras['phoneNumber'] ?? '',
            smsCode: extras['smsCode'] ?? '',
            verificationIdOption: Option.of(extras['verificationId'] as String? ?? ''),
            isInProgress: extras['isInProgress'] ?? false,
            isPhoneNumberInputValidated: extras['isPhoneNumberInputValidated'] ?? false,
            phoneNumberAndResendTokenPair: (
              extras['phoneNumberPair'] ?? '',
              extras['resendToken'] as int?,
            ),
            hasNavigatedToVerification: extras['hasNavigatedToVerification'] ?? false,
          );

          return SmsVerificationView(state: phoneNumberSignInState);
        },
      );

  GoRoute get _createNewChatRoute => GoRoute(
        path: RouterEnum.createChatView.routeName,
        builder: (context, state) {
          final extraParameters = state.extra as Map<String, dynamic>?;
          if (extraParameters == null) {
            throw Exception('Missing required parameters for CreateChatView');
          }

          // Get user list controller or create a default one if not provided
          final userListController = extraParameters['userListController'] as StreamUserListController?;
          final isCreateNewChatPageForCreatingGroup =
              extraParameters['isCreateNewChatPageForCreatingGroup'] as bool? ?? false;

          return CreateChatView(
            userListController: userListController ?? _createDefaultUserListController(context),
            isCreateNewChatPageForCreatingGroup: isCreateNewChatPageForCreatingGroup,
          );
        },
      );

  GoRoute get _onboardingRoute => GoRoute(
        path: RouterEnum.onboardingView.routeName,
        pageBuilder: (context, state) => customPageBuilderWidget(
          context,
          state,
          const OnboardingView(),
        ),
      );

  StreamUserListController _createDefaultUserListController(BuildContext context) {
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
}
