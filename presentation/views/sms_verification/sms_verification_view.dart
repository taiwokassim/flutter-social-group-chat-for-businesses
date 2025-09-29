import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_social_chat/core/constants/enums/auth_failure_enum.dart';
import 'package:flutter_social_chat/core/constants/enums/router_enum.dart';
import 'package:flutter_social_chat/presentation/blocs/auth_session/auth_session_cubit.dart';
import 'package:flutter_social_chat/presentation/blocs/auth_session/auth_session_state.dart';
import 'package:flutter_social_chat/presentation/blocs/phone_number_sign_in/phone_number_sign_in_cubit.dart';
import 'package:flutter_social_chat/presentation/blocs/phone_number_sign_in/phone_number_sign_in_state.dart';
import 'package:flutter_social_chat/presentation/design_system/colors.dart';
import 'package:flutter_social_chat/presentation/design_system/widgets/custom_app_bar.dart';
import 'package:flutter_social_chat/presentation/design_system/widgets/custom_loading_indicator.dart';
import 'package:flutter_social_chat/presentation/design_system/widgets/popscope_scaffold.dart';
import 'package:flutter_social_chat/presentation/views/sms_verification/widgets/sms_verification_view_body.dart';
import 'package:go_router/go_router.dart';

/// A view for SMS verification during the sign-in process
class SmsVerificationView extends StatefulWidget {
  const SmsVerificationView({super.key, required this.state});

  final PhoneNumberSignInState state;

  @override
  State<SmsVerificationView> createState() => _SmsVerificationViewState();
}

class _SmsVerificationViewState extends State<SmsVerificationView> {
  // Flag to prevent multiple navigations
  bool _hasNavigatedAway = false;

  // Critical auth failure types that should trigger navigation back to sign-in
  static const _criticalAuthFailures = {
    AuthFailureEnum.serverError,
    AuthFailureEnum.sessionExpired,
  };

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final String appBarTitle = localizations?.verification ?? '';

    return MultiBlocListener(
      listeners: [
        // Listen for authentication success
        BlocListener<AuthSessionCubit, AuthSessionState>(
          listenWhen: (previous, current) =>
              previous.isLoggedIn != current.isLoggedIn ||
              previous.authUser.isOnboardingCompleted != current.authUser.isOnboardingCompleted,
          listener: _handleAuthStateChanges,
        ),

        // Listen for phone number sign-in state changes
        BlocListener<PhoneNumberSignInCubit, PhoneNumberSignInState>(
          listenWhen: (previous, current) =>
              previous.isInProgress != current.isInProgress ||
              (previous.failureMessageOption != current.failureMessageOption && current.failureMessageOption.isSome()),
          listener: _handleSignInStateChanges,
        ),
      ],
      child: PopScopeScaffold(
        backgroundColor: customIndigoColor,
        resizeToAvoidBottomInset: false,
        onPopInvokedWithResult: (didPop, result) {
          if (!didPop) {
            _handleBackNavigation(context);
          }
        },
        appBar: CustomAppBar(
          leading: IconButton(
            onPressed: () => _handleBackNavigation(context),
            icon: const Icon(CupertinoIcons.back, color: white),
          ),
          backgroundColor: customIndigoColor,
          title: appBarTitle,
          titleColor: white,
        ),
        body: const SmsVerificationViewBody(),
      ),
    );
  }

  /// Handles authentication state changes
  void _handleAuthStateChanges(BuildContext context, AuthSessionState state) {
    if (!state.isLoggedIn || _hasNavigatedAway) return;

    // Prevent multiple navigations
    setState(() => _hasNavigatedAway = true);

    // Hide loading indicator before navigation
    _safelyHideLoadingIndicator(context);

    // Determine destination route based on onboarding status
    final route =
        state.authUser.isOnboardingCompleted ? RouterEnum.dashboardView.routeName : RouterEnum.onboardingView.routeName;

    // Navigate to appropriate route
    _safelyNavigateTo(context, route);
  }

  /// Safely navigates to the specified route
  void _safelyNavigateTo(BuildContext context, String route) {
    if (!mounted) return;

    // Use a single navigation approach with a post frame callback
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      try {
        context.go(route);
      } catch (e) {
        debugPrint('Navigation error: $e');
        // Error already logged, no need for additional attempts
      }
    });
  }

  /// Handles sign-in state changes
  void _handleSignInStateChanges(BuildContext context, PhoneNumberSignInState state) {
    if (state.isInProgress) {
      _safelyShowLoadingIndicator(context);
    } else {
      // Always reset completely when not in progress
      CustomLoadingIndicator.forceClose();

      // Handle errors if present
      state.failureMessageOption.fold(
        () {
          // Log successful operations for debugging
          if (state.verificationIdOption.isSome()) {
            debugPrint('Successfully completed phone operation (Verification/Resend)');
          }
        },
        (authFailure) {
          _showErrorToast(context, authFailure);

          if (_criticalAuthFailures.contains(authFailure)) {
            // For critical errors, go back to the sign-in screen
            _safelyNavigateBack(context);
          } else {
            // For validation errors like invalid code, just clear the error state
            context.read<PhoneNumberSignInCubit>().resetErrorOnly();
          }
        },
      );
    }
  }

  /// Safely shows the loading indicator
  void _safelyShowLoadingIndicator(BuildContext context) {
    if (!mounted) return;

    try {
      // Always reset first - this ensures we don't have multiple indicators
      CustomLoadingIndicator.reset();
      CustomLoadingIndicator.of(context).show();
    } catch (e) {
      // Ignore errors showing loading indicator
      debugPrint('Error showing loading indicator: $e');
    }
  }

  /// Safely hides the loading indicator
  void _safelyHideLoadingIndicator(BuildContext context) {
    if (!mounted) return;
    CustomLoadingIndicator.forceClose();
  }

  /// Shows an error toast with the appropriate message
  void _showErrorToast(BuildContext context, AuthFailureEnum authFailure) {
    final errorMessage = _getErrorMessageForFailure(context, authFailure);
    BotToast.showText(text: errorMessage);
  }

  /// Gets the appropriate error message for an auth failure
  String _getErrorMessageForFailure(BuildContext context, AuthFailureEnum authFailure) {
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

  /// Handles back navigation
  void _handleBackNavigation(BuildContext context) {
    _safelyHideLoadingIndicator(context);

    // Reset state in cubit to prevent verification ID from triggering navigation
    context.read<PhoneNumberSignInCubit>().reset();

    // Navigate back
    _safelyNavigateBack(context);
  }

  /// Safely navigates back to the previous screen
  void _safelyNavigateBack(BuildContext context) {
    if (_hasNavigatedAway) return;

    setState(() => _hasNavigatedAway = true);

    // Use a more reliable navigation approach
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      try {
        context.pop();
      } catch (e) {
        // If pop fails, try to go to sign-in view directly
        if (mounted) {
          context.go(RouterEnum.signInView.routeName);
        }
      }
    });
  }
}
