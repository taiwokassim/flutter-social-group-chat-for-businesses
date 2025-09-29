import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_social_chat/presentation/design_system/colors.dart';

/// A search field for filtering channels
class DashboardViewSearchField extends StatelessWidget {
  const DashboardViewSearchField({super.key, required this.controller, required this.onSearchChanged});

  /// Text controller for the search field
  final TextEditingController controller;

  /// Callback when search text changes
  final Function(String) onSearchChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: TextField(
        controller: controller,
        onChanged: onSearchChanged,
        style: const TextStyle(fontSize: 16, color: customGreyColor800),
        decoration: InputDecoration(
          filled: true,
          fillColor: backgroundGrey,
          contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
          hintText: AppLocalizations.of(context)?.searchSomeone ?? '',
          hintStyle: const TextStyle(color: customGreyColor500, fontSize: 16),
          prefixIcon: const Icon(Icons.search, color: customGreyColor600),
          suffixIcon: controller.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.close, color: customGreyColor700),
                  onPressed: () {
                    controller.clear();
                    onSearchChanged('');
                  },
                )
              : null,
        ),
        cursorColor: customIndigoColor,
      ),
    );
  }
}
