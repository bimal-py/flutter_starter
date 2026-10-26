import 'package:flutter/material.dart';

/// Makes a non-scrolling state widget (empty / error / single message)
/// pull-to-refresh-able and stretches it to fill the viewport.
///
/// [RefreshIndicator] only fires when its scrollable can be over-dragged, but a
/// short child on `ClampingScrollPhysics` (Android) can't be. This forces
/// [AlwaysScrollableScrollPhysics] so the gesture works anywhere on screen, and
/// pins the child to at least the viewport height so a centered state stays
/// centered instead of clinging to the top.
class RefreshableScrollView extends StatelessWidget {
  const RefreshableScrollView({
    super.key,
    required this.onRefresh,
    required this.child,
  });

  final Future<void> Function() onRefresh;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: LayoutBuilder(
        builder: (context, constraints) => SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: child,
          ),
        ),
      ),
    );
  }
}
