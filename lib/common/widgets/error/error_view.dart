import 'package:flutter/material.dart';
import 'package:flutter_starter/common/widgets/widgets.dart';
import 'package:flutter_starter/core/core.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Inline failure state of a screen or section: an illustration, a centred
/// title and optional message, and a retry button. [ErrorScreen] is the
/// full-page (Scaffold) variant.
class ErrorView extends StatelessWidget {
  const ErrorView({
    super.key,
    this.title,
    this.message,
    this.onRetry,
    this.retryLabel,
    this.imageWidget,
  });

  final String? title;
  final String? message;
  final VoidCallback? onRetry;
  final String? retryLabel;

  /// Overrides the default illustration.
  final Widget? imageWidget;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16.r),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          imageWidget ??
              SvgViewer(AssetRoutes.noDataFound, width: 160.r, height: 160.r),
          8.verticalSpace,
          Text(
            title ?? AppErrorStrings.somethingWentWrong,
            textAlign: TextAlign.center,
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.colorScheme.onSurface,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (message != null && message!.isNotEmpty) ...[
            8.verticalSpace,
            Text(
              message!,
              textAlign: TextAlign.center,
              style: context.textTheme.bodySmall?.copyWith(
                color: context.colorScheme.onSurfaceVariant,
                height: 1.5,
              ),
            ),
          ],
          if (onRetry != null) ...[
            24.verticalSpace,
            FilledButton.icon(
              onPressed: onRetry,
              icon: Icon(LucideIcons.rotateCw, size: 16.r),
              label: Text(retryLabel ?? AppErrorStrings.tryAgain),
            ),
          ],
        ],
      ),
    );
  }
}
