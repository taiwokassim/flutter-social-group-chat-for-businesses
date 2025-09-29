import 'package:flutter/material.dart';
import 'package:flutter_social_chat/presentation/design_system/colors.dart';
import 'package:flutter_social_chat/presentation/design_system/widgets/custom_text.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SmsVerificationConfirmationTextWithIcon extends StatelessWidget {
  const SmsVerificationConfirmationTextWithIcon({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final String confirmationText = AppLocalizations.of(context)?.confirmation ?? '';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Row(
        spacing: 16,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.verified_outlined, size: 28, color: white),
          ),
          Expanded(child: CustomText(text: confirmationText, color: white, fontWeight: FontWeight.w700, fontSize: 26)),
        ],
      ),
    );
  }
}
