import 'package:flutter/widgets.dart';

/// Auto-fills the viewport for a paginated list. [PaginationScrollController]
/// only fires when the user scrolls near the end — but a page that doesn't
/// overflow the screen can't be scrolled, so load-more would never trigger
/// even when more pages exist (a short page, or a tall tablet where one page
/// of rows doesn't reach the bottom).
///
/// After every build — first mount and each new page — it waits a frame and, if
/// the outer list *still* can't scroll, calls [onLoadMore] for another page. It
/// can't rely on [ScrollMetricsNotification] alone: that fires only when the
/// scroll *metrics* change, and appending rows to a list that's still shorter
/// than the viewport leaves `maxScrollExtent` pinned at `0`, so no notification
/// is dispatched and the fill stalls after a single page. The post-frame re-check
/// closes that gap; the notification path is kept for viewport changes
/// (rotation, keyboard) that resize an already-short list.
///
/// It judges overflow from [controller] (the outer list's controller) — NOT from
/// `notification.metrics` — so notifications bubbling up from a *nested*
/// scrollable (e.g. an inner shrink-wrapped `ReorderableListView`, whose own
/// `maxScrollExtent` is always `0`) don't keep retriggering once the outer list
/// is already scrollable.
///
/// [onLoadMore] must guard against redundant/at-end fetches (e.g.
/// `isLoadingMore || !canLoadMore`), which paces this loop and stops it at the
/// last page. As a backstop against a misbehaving backend that keeps advertising
/// more pages without adding height, [_maxConsecutiveFills] caps how many pages
/// are auto-pulled before the list becomes scrollable; the count resets the
/// moment it does (a healthy page overflows well within the cap). Wrap the
/// scrollable (or its `RefreshIndicator`) and pass the same controller the
/// scrollable uses.
///
/// IMPORTANT: the re-check rides on this widget rebuilding when a page lands, so
/// it must sit BELOW the `BlocBuilder`/state-builder that produces the list —
/// never above it. Nesting the builder inside (so only the inner list rebuilds)
/// leaves this widget static and strands the fill after page one.
class PaginationListener extends StatefulWidget {
  const PaginationListener({
    super.key,
    required this.controller,
    required this.onLoadMore,
    required this.child,
  });

  final ScrollController controller;
  final VoidCallback onLoadMore;
  final Widget child;

  @override
  State<PaginationListener> createState() => _PaginationListenerState();
}

class _PaginationListenerState extends State<PaginationListener> {
  /// Safety brake for the never-overflows case: stop auto-pulling after this
  /// many consecutive fills so a backend that reports `next` without adding
  /// items can't loop forever. A real page (limit ≈ 20) makes the list
  /// scrollable in one or two fills, far below this.
  static const int _maxConsecutiveFills = 20;

  int _fills = 0;

  // Coalesces the multiple schedule requests a single frame can produce (build
  // + a metrics notification) into one post-frame check.
  bool _checkScheduled = false;

  @override
  void initState() {
    super.initState();
    _scheduleFillCheck();
  }

  @override
  void didUpdateWidget(covariant PaginationListener oldWidget) {
    super.didUpdateWidget(oldWidget);
    // A new page (or any data rebuild) just landed — re-check whether the list
    // is tall enough to scroll yet.
    _scheduleFillCheck();
  }

  void _scheduleFillCheck() {
    if (_checkScheduled) return;
    _checkScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkScheduled = false;
      if (!mounted || !widget.controller.hasClients) return;
      if (widget.controller.position.maxScrollExtent > 0) {
        // Scrollable now — PaginationScrollController takes over; re-arm the
        // brake so a later shrink (refresh, filter) can fill again.
        _fills = 0;
        return;
      }
      if (_fills >= _maxConsecutiveFills) return;
      _fills++;
      widget.onLoadMore();
    });
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollMetricsNotification>(
      onNotification: (_) {
        if (widget.controller.hasClients &&
            widget.controller.position.maxScrollExtent == 0) {
          _scheduleFillCheck();
        }
        return false;
      },
      child: widget.child,
    );
  }
}
