import 'package:flutter/material.dart';
import 'package:flutter_scale_kit/flutter_scale_kit.dart';
import 'package:loader_overlay/loader_overlay.dart';

/// Wraps the app in a [GlobalLoaderOverlay] so any descendant can call
/// `context.loaderOverlay.show()` / `.hide()` for a global busy indicator.
class LoadingOverlayWidget extends StatelessWidget {
  const LoadingOverlayWidget({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return GlobalLoaderOverlay(
      overlayWidgetBuilder: (_) => Center(
        child: Container(
          padding: EdgeInsets.all(20.r),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: const CircularProgressIndicator(),
        ),
      ),
      child: child,
    );
  }
}
