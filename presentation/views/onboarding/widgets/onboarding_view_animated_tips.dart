import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_social_chat/presentation/design_system/colors.dart';
import 'package:flutter_social_chat/presentation/design_system/widgets/custom_text.dart';

/// Animated tips container that cycles through helpful onboarding tips
///
/// Displays a series of helpful tips with a fade animation between them.
/// Tips are localized and automatically cycle every few seconds.
class OnboardingViewAnimatedTips extends StatefulWidget {
  const OnboardingViewAnimatedTips({super.key});

  @override
  State<OnboardingViewAnimatedTips> createState() => _OnboardingViewAnimatedTipsState();
}

class _OnboardingViewAnimatedTipsState extends State<OnboardingViewAnimatedTips> with SingleTickerProviderStateMixin {
  // State tracking
  int _currentTipIndex = 0;
  bool _isAnimating = false;
  Timer? _timer;
  late List<String> _tips;

  // Animation and UI constants
  static const Duration _animationDuration = Duration(milliseconds: 300);
  static const Duration _tipChangeDuration = Duration(seconds: 3);

  @override
  void initState() {
    super.initState();
    _startTipsAnimation();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Initialize tips here where context is available
    _tips = _getTips();
  }

  /// Returns the list of localized tips to display
  List<String> _getTips() {
    final AppLocalizations? appLocalizations = AppLocalizations.of(context);

    return [
      appLocalizations?.animatedText2 ?? '',
      appLocalizations?.animatedText1 ?? '',
      appLocalizations?.animatedText3 ?? '',
      appLocalizations?.animatedText4 ?? '',
    ];
  }

  /// Starts the timer to cycle through tips automatically
  void _startTipsAnimation() {
    _timer = Timer.periodic(_tipChangeDuration, (_) => _animateToNextTip());
  }

  /// Animates to the next tip with a fade transition
  void _animateToNextTip() {
    if (_tips.isEmpty) return;

    setState(() => _isAnimating = true);

    Future.delayed(_animationDuration, () {
      if (mounted) {
        setState(() {
          _currentTipIndex = (_currentTipIndex + 1) % _tips.length;
          _isAnimating = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 12),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: customIndigoColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: customIndigoColor.withValues(alpha: 0.15),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTipsHeader(context),
          const SizedBox(height: 12),
          _buildAnimatedTip(),
        ],
      ),
    );
  }

  Widget _buildTipsHeader(BuildContext context) {
    final appLocalizations = AppLocalizations.of(context);

    return Row(
      spacing: 8,
      children: [
        const Icon(Icons.tips_and_updates_outlined, color: customIndigoColor, size: 24),
        CustomText(
          text: appLocalizations?.tips ?? '',
          fontWeight: FontWeight.bold,
          color: customIndigoColor,
          fontSize: 18,
        ),
      ],
    );
  }

  /// Builds the animated tip text with fade transition
  Widget _buildAnimatedTip() {
    // If tips list is empty, don't show anything
    if (_tips.isEmpty) return const SizedBox.shrink();

    return AnimatedOpacity(
      opacity: _isAnimating ? 0.0 : 1.0,
      duration: _animationDuration,
      curve: Curves.easeInOut,
      child: SizedBox(
        height: 85,
        child: CustomText(
          text: _tips[_currentTipIndex],
          color: customGreyColor500,
          fontSize: 16,
          maxLines: 4,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}
