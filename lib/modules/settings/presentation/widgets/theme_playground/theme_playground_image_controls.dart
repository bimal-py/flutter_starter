import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_starter/core/core.dart';
import 'package:flutter_starter/modules/settings/utils/constants/constants.dart';

class ThemePlaygroundImageControls extends StatelessWidget {
  const ThemePlaygroundImageControls({
    super.key,
    required this.imagePath,
    required this.onPick,
  });

  final String? imagePath;
  final VoidCallback onPick;

  @override
  Widget build(BuildContext context) {
    final path = imagePath;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (path != null)
            Container(
              height: 120.h,
              margin: EdgeInsets.only(bottom: 12.h),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: context.colorScheme.outlineVariant),
                image: DecorationImage(
                  image: FileImage(File(path)),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          FilledButton.tonalIcon(
            onPressed: onPick,
            icon: const Icon(Icons.image_outlined),
            label: Text(
              path == null
                  ? SettingsStrings.pickImage
                  : SettingsStrings.pickDifferentImage,
            ),
          ),
          if (path != null) ...[
            6.verticalSpace,
            Text(SettingsStrings.imageHint, style: context.textTheme.bodySmall),
          ],
        ],
      ),
    );
  }
}
