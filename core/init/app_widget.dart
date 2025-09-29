import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_social_chat/presentation/blocs/profile_management/profile_manager_cubit.dart';
import 'package:flutter_social_chat/presentation/blocs/chat_management/chat_management_cubit.dart';
import 'package:flutter_social_chat/presentation/blocs/chat_session/chat_session_cubit.dart';
import 'package:flutter_social_chat/presentation/blocs/connectivity/connectivity_cubit.dart';
import 'package:flutter_social_chat/presentation/blocs/connectivity/connectivity_state.dart';
import 'package:flutter_social_chat/presentation/design_system/theme.dart';
import 'package:flutter_social_chat/core/di/dependency_injector.dart';
import 'package:flutter_social_chat/core/init/router/app_router.dart';
import 'package:flutter_social_chat/presentation/blocs/phone_number_sign_in/phone_number_sign_in_cubit.dart';
import 'package:flutter_social_chat/presentation/blocs/auth_session/auth_session_cubit.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';

class AppWidget extends StatelessWidget {
  const AppWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final appRouter = getIt<AppRouter>();
    final botToastBuilder = BotToastInit();

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          lazy: false,
          create: (context) => getIt<ProfileManagerCubit>(),
        ),
        BlocProvider(
          lazy: false,
          create: (context) => getIt<AuthSessionCubit>(),
        ),
        BlocProvider(
          lazy: false,
          create: (context) => getIt<ConnectivityCubit>(),
        ),
        BlocProvider(
          lazy: false,
          create: (context) => getIt<ChatSessionCubit>(),
        ),
        BlocProvider(
          create: (context) => getIt<PhoneNumberSignInCubit>(),
        ),
        BlocProvider(
          create: (context) => getIt<ChatManagementCubit>()..reset(),
        ),
      ],
      child: BlocListener<ConnectivityCubit, ConnectivityState>(
        listener: _handleConnectivityChanges,
        child: MaterialApp.router(
          theme: AppTheme.lightTheme,
          debugShowCheckedModeBanner: false,
          routerConfig: appRouter.router,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          builder: (context, child) => _buildAppWithStreamChat(context, child, botToastBuilder),
        ),
      ),
    );
  }

  /// Manages connectivity state changes and shows appropriate notifications
  void _handleConnectivityChanges(BuildContext context, ConnectivityState state) {
    if (!state.isUserConnectedToTheInternet) {
      _showConnectivityToast(context, true);
    } else if (state.isUserConnectedToTheInternet) {
      BotToast.cleanAll();
    }
  }

  /// Shows a connectivity error toast message
  void _showConnectivityToast(BuildContext context, bool hasConnectionFailed) {
    if (hasConnectionFailed) {
      final localizations = AppLocalizations.of(context);

      BotToast.showText(
        text: localizations?.connectionFailed ?? '',
        duration: const Duration(seconds: 30),
        clickClose: true,
      );
    }
  }

  /// Builds the app with StreamChat integration and toast capabilities
  Widget _buildAppWithStreamChat(BuildContext context, Widget? child, TransitionBuilder botToastBuilder) {
    final client = getIt<StreamChatClient>();

    child = StreamChat(client: client, child: child);
    child = botToastBuilder(context, child);

    return child;
  }
}
