import 'package:flutter/widgets.dart';
import 'package:flutter_starter/modules/pagination/presentation/widgets/widgets.dart';
import 'package:flutter_starter/modules/pagination/utils/utils.dart';

/// The two halves of a paged list in one place, so a list widget can stay
/// stateless: it owns the [PaginationScrollController] that asks for the
/// next page near the end, hands it to [builder] for the scrollable, and
/// wraps the result in a [PaginationListener] so a page too short to scroll
/// still pulls the next one.
///
/// Sit it BELOW the `BlocBuilder` that produces the rows (see
/// [PaginationListener]). [onLoadMore] is null when there is nothing more to
/// load; the bloc still guards against asking twice.
class PaginationScrollBuilder extends StatefulWidget {
  const PaginationScrollBuilder({
    super.key,
    required this.onLoadMore,
    required this.builder,
    this.controller,
  });

  final VoidCallback? onLoadMore;

  /// Builds the scrollable; give it the [ScrollController] passed in.
  final Widget Function(BuildContext context, ScrollController controller)
  builder;

  /// A controller the scrollable must use instead (a draggable sheet's). It
  /// isn't disposed here.
  final ScrollController? controller;

  @override
  State<PaginationScrollBuilder> createState() =>
      _PaginationScrollBuilderState();
}

class _PaginationScrollBuilderState extends State<PaginationScrollBuilder> {
  /// How close to the end (logical pixels) the next page is asked for, the
  /// same distance [PaginationScrollController] uses.
  static const double _threshold = 200;

  PaginationScrollController? _own;

  ScrollController get _controller => widget.controller ?? _own!;

  @override
  void initState() {
    super.initState();
    _attach();
  }

  @override
  void didUpdateWidget(covariant PaginationScrollBuilder oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller?.removeListener(_onOuterScroll);
      _attach();
    }
  }

  void _attach() {
    final outer = widget.controller;
    if (outer != null) {
      outer.addListener(_onOuterScroll);
    } else {
      _own ??= PaginationScrollController(onLoadMore: _loadMore);
    }
  }

  void _loadMore() => widget.onLoadMore?.call();

  /// [PaginationScrollController]'s rule, for a controller made elsewhere.
  void _onOuterScroll() {
    final outer = widget.controller;
    if (outer == null || !outer.hasClients) return;
    final position = outer.position;
    if (position.maxScrollExtent <= 0) return;
    if (position.pixels < position.maxScrollExtent - _threshold) return;
    _loadMore();
  }

  @override
  void dispose() {
    widget.controller?.removeListener(_onOuterScroll);
    _own?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PaginationListener(
      controller: _controller,
      onLoadMore: _loadMore,
      child: widget.builder(context, _controller),
    );
  }
}
