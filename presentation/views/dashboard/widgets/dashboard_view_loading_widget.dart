import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_social_chat/presentation/design_system/colors.dart';
import 'package:flutter_social_chat/presentation/design_system/widgets/custom_progress_indicator.dart';
import 'package:flutter_social_chat/presentation/design_system/widgets/custom_text.dart';

/// Loading state widget for the Channels page
class DashboardViewLoadingWidget extends StatelessWidget {
  const DashboardViewLoadingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        spacing: 24,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CustomProgressIndicator(size: 56, progressIndicatorColor: customIndigoColor),
          CustomText(text: AppLocalizations.of(context)?.loadingChats ?? '', fontSize: 16, color: customGreyColor700),
        ],
      ),
    );
  }
}
