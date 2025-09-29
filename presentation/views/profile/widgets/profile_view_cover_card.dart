import 'package:flutter/material.dart';
import 'package:flutter_social_chat/presentation/design_system/colors.dart';
import 'package:flutter_social_chat/presentation/gen/assets.gen.dart';
import 'package:flutter_social_chat/presentation/views/profile/widgets/profile_view_header.dart';

/// Card that displays the profile cover image with the user's header information
///
/// Features:
/// - Displays a cover image with darkened overlay
/// - Adds a gradient for better text visibility
/// - Shows the ProfileHeader with user information
/// - Uses proper border radius and shadows for a card-like appearance
class ProfileViewCoverCard extends StatelessWidget {
  const ProfileViewCoverCard({
    super.key,
    required this.userName,
    required this.userPhotoUrl,
    required this.userId,
    required this.userPhoneNumber,
  });

  final String userName;
  final String userPhotoUrl;
  final String userId;
  final String userPhoneNumber;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.22,
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 52, 16, 12),
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(Assets.images.flutter.path),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(black.withValues(alpha: 0.3), BlendMode.darken),
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: black.withValues(alpha: 0.2), blurRadius: 12, offset: const Offset(0, 5)),
        ],
      ),
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          // Gradient overlay for better text visibility
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [transparent, black.withValues(alpha: 0.7)],
                stops: const [0.6, 1],
              ),
            ),
          ),
          // User Info overlay
          Padding(
            padding: const EdgeInsets.all(12),
            child: ProfileViewHeader(
              userName: userName,
              userPhoneNumber: userPhoneNumber,
              userPhotoUrl: userPhotoUrl,
              userId: userId,
            ),
          ),
        ],
      ),
    );
  }
}
