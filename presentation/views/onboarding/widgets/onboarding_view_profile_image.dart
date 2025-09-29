import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_social_chat/presentation/design_system/colors.dart';
import 'package:flutter_social_chat/presentation/design_system/widgets/custom_progress_indicator.dart';
import 'package:flutter_social_chat/presentation/design_system/widgets/custom_text.dart';

/// Component that displays the user's profile image
///
/// Uses a default image from a remote URL during onboarding
class OnboardingViewProfileImage extends StatelessWidget {
  const OnboardingViewProfileImage({super.key});

  // Default remote image URL
  static const String defaultImageUrl = 'https://pbs.twimg.com/profile_images/1870429866643869696/K1jmpXsk_400x400.jpg';

  @override
  Widget build(BuildContext context) {
    final appLocalizations = AppLocalizations.of(context);

    return Column(
      spacing: 12,
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildProfileAvatar(),
        CustomText(
          text: appLocalizations?.profilePhotoAdded ?? '',
          fontSize: 14,
          color: customGreyColor600,
          fontWeight: FontWeight.w500,
        ),
      ],
    );
  }

  Widget _buildProfileAvatar() {
    return CachedNetworkImage(
      imageUrl: defaultImageUrl,
      imageBuilder: (context, imageProvider) => Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          color: customGreyColor400,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(color: black.withValues(alpha: 0.1), offset: const Offset(0, 4), blurRadius: 10),
          ],
          image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
        ),
      ),
      placeholder: (context, url) => Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          color: customGreyColor400,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(color: black.withValues(alpha: 0.1), offset: const Offset(0, 4), blurRadius: 10),
          ],
        ),
        child: const CustomProgressIndicator(),
      ),
      errorWidget: (context, url, error) => Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          color: customGreyColor400,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(color: black.withValues(alpha: 0.1), offset: const Offset(0, 4), blurRadius: 10),
          ],
        ),
        child: const Icon(Icons.person_rounded, size: 60, color: white),
      ),
    );
  }
}
