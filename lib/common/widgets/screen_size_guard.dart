import 'package:flutter/widgets.dart';

/// Never lets the widgets below it see a 0 x 0 screen.
///
/// Android reports a 0 x 0 view while the app is in the background, and iOS
/// can before the first frame. flutter_scale_kit turns a zero size into a
/// zero scale, and from zero no change counts as big enough to recompute it,
/// so every `.sp` text stayed 0 px tall after coming back: a blank app. Below
/// this widget the size is always the last real one. Until the first real
/// size arrives, nothing is built. Put it above `ScaleKitBuilder`.
class ScreenSizeGuard extends StatefulWidget {
  const ScreenSizeGuard({super.key, required this.child});

  final Widget child;

  @override
  State<ScreenSizeGuard> createState() => _ScreenSizeGuardState();
}

class _ScreenSizeGuardState extends State<ScreenSizeGuard> {
  Size? _lastRealSize;

  @override
  Widget build(BuildContext context) {
    final data = MediaQuery.of(context);
    if (!data.size.isEmpty) _lastRealSize = data.size;
    final size = _lastRealSize;
    if (size == null) return const SizedBox.shrink();
    // Always the same wrapper, so the app's state survives a 0 x 0 frame.
    return MediaQuery(
      data: data.copyWith(size: size),
      child: widget.child,
    );
  }
}
