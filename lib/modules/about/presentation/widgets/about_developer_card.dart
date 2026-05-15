import 'package:flutter/material.dart';
import 'package:flutter_starter/core/core.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class AboutDeveloperCard extends StatelessWidget {
  const AboutDeveloperCard({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: EdgeInsets.all(16.r),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24.r,
              backgroundColor: theme.colorScheme.primaryContainer,
              child: Icon(
                LucideIcons.user,
                color: theme.colorScheme.onPrimaryContainer,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppConstants.developerName,
                    style: theme.textTheme.titleMedium,
                  ),
                  Text(
                    AppConstants.developerRole,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            _LinkButton(
              icon: LucideIcons.mail,
              tooltip: 'Email',
              onTap: () => const UrlHelper().launch(
                'mailto:${AppUrls.developerEmail}',
              ),
            ),
            _LinkButton(
              icon: LucideIcons.code,
              tooltip: 'GitHub',
              onTap: () => const UrlHelper().launch(AppUrls.developerGithub),
            ),
            _LinkButton(
              icon: LucideIcons.globe,
              tooltip: 'Website',
              onTap: () => const UrlHelper().launch(AppUrls.developerWebsite),
            ),
          ],
        ),
      ),
    );
  }
}

class _LinkButton extends StatelessWidget {
  const _LinkButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final Future<void> Function() onTap;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(icon, size: 20.r),
      tooltip: tooltip,
      onPressed: () async {
        try {
          await onTap();
        } catch (e) {
          if (context.mounted) {
            CustomSnackbar.show(
              type: ToastType.error,
              message: AppErrorHandler.getErrorMessage(e),
            );
          }
        }
      },
    );
  }
}
