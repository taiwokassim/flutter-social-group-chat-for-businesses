import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_social_chat/core/constants/enums/auth_failure_enum.dart';
import 'package:flutter_social_chat/core/constants/enums/router_enum.dart';
import 'package:flutter_social_chat/core/di/dependency_injector.dart';
import 'package:flutter_social_chat/core/init/router/navigation_state_codec.dart';
import 'package:flutter_social_chat/presentation/blocs/auth_session/auth_session_cubit.dart';
import 'package:flutter_social_chat/presentation/blocs/phone_number_sign_in/phone_number_sign_in_cubit.dart';
import 'package:flutter_social_chat/presentation/blocs/phone_number_sign_in/phone_number_sign_in_state.dart';
import 'package:flutter_social_chat/presentation/design_system/colors.dart';
import 'package:flutter_social_chat/presentation/design_system/widgets/custom_app_bar.dart';
import 'package:flutter_social_chat/presentation/design_system/widgets/custom_loading_indicator.dart';
import 'package:flutter_social_chat/presentation/design_system/widgets/popscope_scaffold.dart';
import 'package:flutter_social_chat/presentation/views/sign_in/widgets/sign_in_view_body.dart';
import 'package:go_router/go_router.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';

/// A view that handles phone number sign-in functionality,
/// including initialization, error handling, and navigation to SMS verification.
class SignInView extends StatefulWidget {
  const SignInView({super.key});

  @override
  State<SignInView> createState() => _SignInViewState();
}

class _SignInViewState extends State<SignInView> {
  @override
  void initState() {
    super.initState();
    // Reset loading indicator and SignIn cubit on entry
    CustomLoadingIndicator.reset();

    // Reset Stream Chat client if needed
    _resetStreamChatIfNeeded();

    // Reset the PhoneNumberSignInCubit state
    _initializeSignInState();
  }

  /// Initializes the sign-in state when the view is loaded
  void _initializeSignInState() {
    Future.microtask(() {
      if (!mounted) return;

      // Reset phone number sign-in state
      context.read<PhoneNumberSignInCubit>().reset();

      // Extra safety: Ensure we're fully signed out by checking auth session
      final authSessionCubit = context.read<AuthSessionCubit>();
      if (authSessionCubit.state.isInProgress) {
        // If sign out is in progress, wait for it to complete before proceeding
        _safelyShowLoadingIndicator();
      }
    });
  }

  /// Properly disconnects Stream Chat if a user session is still active
  void _resetStreamChatIfNeeded() {
    try {
      final client = getIt<StreamChatClient>();
      if (client.state.currentUser != null) {
        _cleanupStreamChat(client);
      }
    } catch (e) {
      // Ignore Stream Chat reset errors
    }
  }

  /// Performs a clean disconnect of the Stream Chat client
  void _cleanupStreamChat(StreamChatClient client) {
    // First, close any open channels to prevent resource leaks
    for (final entry in client.state.channels.entries) {
      try {
        entry.value.dispose();
      } catch (e) {
        // Ignore individual channel disposal errors
      }
    }

    // Add a delay to ensure channel disposal has completed
    Future.delayed(const Duration(milliseconds: 100), () {
      // Then disconnect the user with persistence flush
      client.disconnectUser(flushChatPersistence: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final String appBarTitle = AppLocalizations.of(context)?.signIn ?? '';

    return BlocConsumer<PhoneNumberSignInCubit, PhoneNumberSignInState>(
      listenWhen: (previous, current) =>
          (previous.failureMessageOption != current.failureMessageOption && current.failureMessageOption.isSome()) ||
          (previous.verificationIdOption != current.verificationIdOption && current.verificationIdOption.isSome()) ||
          previous.isInProgress != current.isInProgress,
      listener: _handleStateChanges,
      builder: (context, state) {
        return PopScopeScaffold(
          resizeToAvoidBottomInset: false,
          body: const SignInViewBody(),
          appBar: CustomAppBar(backgroundColor: customIndigoColor, title: appBarTitle, titleColor: white),
        );
      },
    );
  }

  /// Handles state changes in the PhoneNumberSignInCubit
  void _handleStateChanges(BuildContext context, PhoneNumberSignInState state) {
    if (!mounted) return;

    // Handle loading state
    _handleLoadingState(state);

    // Handle error state
    _handleErrorState(state);

    // Handle verification ID state
    _handleVerificationIdState(state);
  }

  /// Manages loading indicator based on state progress
  void _handleLoadingState(PhoneNumberSignInState state) {
    if (state.isInProgress) {
      _safelyShowLoadingIndicator();
    } else {
      _safelyHideLoadingIndicator();
    }
  }

  /// Handles error states and displays appropriate messages
  void _handleErrorState(PhoneNumberSignInState state) {
    state.failureMessageOption.fold(
      () {},
      (authFailure) {
        // Ensure loading indicator is hidden when there's an error
        _safelyHideLoadingIndicator();

        _showErrorToast(authFailure);
        // Reset only error state without clearing phone number
        if (mounted) {
          context.read<PhoneNumberSignInCubit>().resetErrorOnly();
        }
      },
    );
  }

  /// Handles verification ID and navigation to SMS verification
  void _handleVerificationIdState(PhoneNumberSignInState state) {
    state.verificationIdOption.fold(
      () {},
      (verificationId) {
        if (!mounted) return;

        final isValidVerificationId = verificationId.isNotEmpty;
        final canNavigate = isValidVerificationId && !state.hasNavigatedToVerification;

        if (canNavigate) {
          _navigateToSmsVerification(state);
        }
      },
    );
  }

  /// Safely shows the loading indicator
  void _safelyShowLoadingIndicator() {
    if (!mounted) return;

    try {
      CustomLoadingIndicator.of(context).show();
    } catch (e) {
      // Ignore loading indicator errors
    }
  }

  /// Safely hides the loading indicator
  void _safelyHideLoadingIndicator() {
    if (!mounted) return;

    try {
      CustomLoadingIndicator.of(context).hide();
    } catch (e) {
      // Ignore loading indicator errors
    }
  }

  /// Shows an error toast with the appropriate message
  void _showErrorToast(AuthFailureEnum authFailure) {
    if (!mounted) return;

    final errorMessage = _getErrorMessageForFailure(authFailure);
    BotToast.showText(text: errorMessage);
  }

  /// Gets the localized error message for a specific auth failure
  String _getErrorMessageForFailure(AuthFailureEnum authFailure) {
    if (!mounted) return '';

    final localizations = AppLocalizations.of(context);

    return switch (authFailure) {
      AuthFailureEnum.serverError => localizations?.serverError ?? '',
      AuthFailureEnum.tooManyRequests => localizations?.tooManyRequests ?? '',
      AuthFailureEnum.deviceNotSupported => localizations?.deviceNotSupported ?? '',
      AuthFailureEnum.smsTimeout => localizations?.smsTimeout ?? '',
      AuthFailureEnum.sessionExpired => localizations?.sessionExpired ?? '',
      AuthFailureEnum.invalidVerificationCode => localizations?.invalidVerificationCode ?? '',
    };
  }

  /// Safely navigates to the SMS verification view
  void _navigateToSmsVerification(PhoneNumberSignInState state) {
    if (!mounted) return;
    
    // Hide loading indicator before navigation
    _safelyHideLoadingIndicator();
    
    // Update navigation flag to prevent duplicate navigation
    if (mounted) {
      context.read<PhoneNumberSignInCubit>().updateNavigationFlag(hasNavigated: true);
      
      // Get the updated state from the BLoC after setting the navigation flag
      final currentState = context.read<PhoneNumberSignInCubit>().state;
      final encodedState = NavigationStateCodec.encodeMap(currentState.toJson());
      
      // Navigate to SMS verification using a safer approach with error handling
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        
        try {
          context.push(RouterEnum.smsVerificationView.routeName, extra: encodedState);
        } catch (e) {
          debugPrint('Navigation error: $e');
          // Handle navigation error if needed, but don't attempt again
          // as it might cause the same error in a loop
        }
      });
    }
  }
}
