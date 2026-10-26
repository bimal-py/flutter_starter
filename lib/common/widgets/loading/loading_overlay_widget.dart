import 'package:flutter/material.dart';
import 'package:loader_overlay/loader_overlay.dart';

/// Hosts the app-wide blocking loader. Show it with
/// `context.showPopupLoading()` while a request is in flight.
class LoadingOverlayWidget extends StatelessWidget {
  const LoadingOverlayWidget({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return GlobalLoaderOverlay(
      closeOnBackButton: false,
      overlayColor: Colors.transparent,
      // The barrier stays invisible, but it has to span the screen to swallow
      // taps: with `false` and no explicit overlayHeight/overlayWidth it
      // collapses to 0x0, so every tap still reached the page behind it.
      overlayWholeScreen: true,
      child: child,
    );
  }
}
