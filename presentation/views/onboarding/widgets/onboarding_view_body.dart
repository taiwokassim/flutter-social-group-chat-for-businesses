import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_social_chat/presentation/design_system/colors.dart';
import 'package:flutter_social_chat/presentation/design_system/widgets/custom_text.dart';
import 'package:flutter_social_chat/presentation/views/onboarding/widgets/onboarding_view_animated_tips.dart';
import 'package:flutter_social_chat/presentation/views/onboarding/widgets/onboarding_view_animation.dart';
import 'package:flutter_social_chat/presentation/views/onboarding/widgets/onboarding_view_profile_image.dart';
import 'package:flutter_social_chat/presentation/views/onboarding/widgets/onboarding_view_submit_button.dart';
import 'package:flutter_social_chat/presentation/views/onboarding/widgets/onboarding_view_username_form_field.dart';

/// Main content container for the onboarding page
///
/// Displays:
/// - Animated illustration at the top
/// - Profile image selection
/// - Username input field
/// - Animated tips at the bottom
/// - Submit button
class OnboardingViewBody extends StatelessWidget {
  const OnboardingViewBody({super.key});

  @override
  Widget build(BuildContext context) {
    final appLocalizations = AppLocalizations.of(context);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            customIndigoColor.withValues(alpha: 0.15),
            customIndigoColor.withValues(alpha: 0.03),
            white,
          ],
          stops: const [0.0, 0.25, 0.5],
        ),
      ),
      child: Column(
        children: [
          const OnboardingViewAnimation(),
          Expanded(
            child: _buildMainContentContainer(appLocalizations),
          ),
        ],
      ),
    );
  }

  /// Builds the main rounded container with all form elements
  Widget _buildMainContentContainer(AppLocalizations? appLocalizations) {
    return Container(
      padding: const EdgeInsets.only(top: 40, left: 24, right: 24),
      decoration: BoxDecoration(
        color: white,
        borderRadius: const BorderRadius.only(topLeft: Radius.circular(28), topRight: Radius.circular(28)),
        boxShadow: [
          BoxShadow(color: customIndigoColor.withValues(alpha: 0.08), blurRadius: 15, offset: const Offset(0, -5)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(appLocalizations),
          const SizedBox(height: 32),
          _buildProfileSection(appLocalizations),
          const Spacer(),
          const OnboardingViewAnimatedTips(),
          const SizedBox(height: 24),
          const OnboardingViewSubmitButton(),
          const SizedBox(height: 36),
        ],
      ),
    );
  }

  /// Builds the welcome header with title and subtitle
  Widget _buildHeader(AppLocalizations? appLocalizations) {
    return Column(
      children: [
        Center(
          child: CustomText(
            text: appLocalizations?.welcomeToSocialChat ?? '',
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: customIndigoColor,
          ),
        ),
        const SizedBox(height: 8),
        Center(
          child: CustomText(
            text: appLocalizations?.letsSetupYourProfile ?? '',
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: customGreyColor600,
          ),
        ),
      ],
    );
  }

  /// Builds the profile image and username input section
  Widget _buildProfileSection(AppLocalizations? appLocalizations) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const OnboardingViewProfileImage(),
        const SizedBox(width: 20),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              CustomText(
                text: appLocalizations?.addYourDetails ?? '',
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: customIndigoColor,
              ),
              const SizedBox(height: 16),
              const OnboardingViewUsernameFormField(),
            ],
          ),
        ),
      ],
    );
  }
}
