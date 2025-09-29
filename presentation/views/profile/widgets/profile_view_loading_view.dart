import 'package:flutter/material.dart';
import 'package:flutter_social_chat/presentation/design_system/colors.dart';
import 'package:flutter_social_chat/presentation/design_system/widgets/custom_progress_indicator.dart';
import 'package:flutter_social_chat/presentation/design_system/widgets/custom_text.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ProfileViewLoadingView extends StatelessWidget {
  const ProfileViewLoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);

    return Center(
      child: Column(
        spacing: 16,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CustomProgressIndicator(progressIndicatorColor: customIndigoColor),
          CustomText(
            text: localization?.loadingProfile ?? '',
            fontSize: 16,
            color: customGreyColor700,
            fontWeight: FontWeight.w500,
          ),
        ],
      ),
    );
  }
}
