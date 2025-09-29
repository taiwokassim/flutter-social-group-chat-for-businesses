import 'package:flutter/material.dart';
import 'package:flutter_social_chat/presentation/design_system/colors.dart';
import 'package:flutter_social_chat/presentation/design_system/widgets/custom_text.dart';
import 'package:flutter_social_chat/presentation/views/profile/widgets/profile_view_image.dart';

class ProfileViewHeader extends StatelessWidget {
  const ProfileViewHeader({
    super.key,
    required this.userName,
    required this.userPhoneNumber,
    required this.userPhotoUrl,
    required this.userId,
  });

  final String userName;
  final String userPhoneNumber;
  final String userPhotoUrl;
  final String userId;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ProfileViewImage(userPhotoUrl: userPhotoUrl),
        const SizedBox(height: 8),
        CustomText(text: '@$userName', fontWeight: FontWeight.w700, fontSize: 18, color: white),
        CustomText(text: userId, fontWeight: FontWeight.w400, fontSize: 12, color: whiteWithOpacity30),
      ],
    );
  }
}
