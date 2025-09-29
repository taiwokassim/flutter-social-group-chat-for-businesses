import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_social_chat/presentation/design_system/colors.dart';
import 'package:flutter_social_chat/presentation/design_system/widgets/custom_progress_indicator.dart';

/// Displays the user's profile image with proper caching and loading states
///
/// Features:
/// - Circular image with white border
/// - Shows loading indicator while image loads
/// - Fallback icon if image fails to load
/// - Memory caching for better performance
class ProfileViewImage extends StatelessWidget {
  const ProfileViewImage({super.key, required this.userPhotoUrl});
  
  final String userPhotoUrl;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final imageSize = size.width * 0.22;

    return Container(
      width: imageSize,
      height: imageSize,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: white, width: 3),
        boxShadow: [
          BoxShadow(color: black.withValues(alpha: 0.2), blurRadius: 8, offset: const Offset(0, 3)),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(imageSize),
        child: CachedNetworkImage(
          imageUrl: userPhotoUrl,
          fit: BoxFit.cover,
          fadeInDuration: const Duration(milliseconds: 200),
          memCacheHeight: (imageSize * MediaQuery.of(context).devicePixelRatio).toInt(),
          memCacheWidth: (imageSize * MediaQuery.of(context).devicePixelRatio).toInt(),
          placeholder: (context, url) => Container(
            color: customGreyColor800,
            child: const CustomProgressIndicator(progressIndicatorColor: white, strokeWidth: 2),
          ),
          errorWidget: (context, url, error) {
            return Container(color: customGreyColor800, child: const Icon(Icons.person, color: white, size: 30));
          },
        ),
      ),
    );
  }
}
