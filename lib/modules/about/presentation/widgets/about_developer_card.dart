import 'package:flutter/material.dart';
import 'package:flutter_starter/core/core.dart';
import 'package:flutter_starter/modules/about/presentation/widgets/widgets.dart';
import 'package:flutter_starter/modules/about/utils/constants/constants.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class AboutDeveloperCard extends StatelessWidget {
  const AboutDeveloperCard({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.r),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24.r,
              backgroundColor: colorScheme.primaryContainer,
              child: Icon(
                LucideIcons.user,
                color: colorScheme.onPrimaryContainer,
              ),
            ),
            12.horizontalSpace,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppConstants.developerName,
                    style: context.textTheme.titleMedium,
                  ),
                  Text(
                    AppConstants.developerRole,
                    style: context.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            AboutLinkButton(
              icon: LucideIcons.mail,
              tooltip: AboutStrings.email,
              onTap: () =>
                  const UrlHelper().launch('mailto:${AppUrls.developerEmail}'),
            ),
            // Lucide ships no brand logos, so GitHub gets the code icon.
            AboutLinkButton(
              icon: LucideIcons.code,
              tooltip: AboutStrings.github,
              onTap: () => const UrlHelper().launch(AppUrls.developerGithub),
            ),
            AboutLinkButton(
              icon: LucideIcons.globe,
              tooltip: AboutStrings.website,
              onTap: () => const UrlHelper().launch(AppUrls.developerWebsite),
            ),
          ],
        ),
      ),
    );
  }
}
