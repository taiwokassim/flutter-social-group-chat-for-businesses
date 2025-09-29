import 'package:flutter/material.dart';
import 'package:flutter_social_chat/presentation/design_system/colors.dart';
import 'package:flutter_social_chat/presentation/design_system/widgets/custom_text.dart';

class ProfileViewContactInfoWidget extends StatelessWidget {
  const ProfileViewContactInfoWidget({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
    this.valueColor,
  });

  final IconData icon;
  final String title;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: customGreyColor600),
        const SizedBox(width: 12),
        CustomText(text: title, fontSize: 15, color: customGreyColor900),
        const Spacer(),
        CustomText(text: value, fontSize: 15, fontWeight: FontWeight.w500, color: valueColor ?? customGreyColor900),
      ],
    );
  }
}
