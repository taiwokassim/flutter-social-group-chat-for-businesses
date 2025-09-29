enum RouterEnum {
  initialLocation('/'),
  dashboardView('/dashboard_view'),
  profileView('/profile_view'),
  chatView('/chat_view'),
  signInView('/sign_in_view'),
  smsVerificationView('/sms_verification_view'),
  createChatView('/create_chat_view'),
  onboardingView('/onboarding_view');

  final String routeName;

  const RouterEnum(this.routeName);
}
