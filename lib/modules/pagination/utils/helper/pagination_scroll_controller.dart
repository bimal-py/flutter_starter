import 'package:flutter/widgets.dart';

/// A [ScrollController] that calls [onLoadMore] when the user nears the end of
/// an *actually overflowing* list. It skips the common pitfall where a short,
/// non-scrolling list (`maxScrollExtent == 0`) makes `pixels >= maxScrollExtent
/// - threshold` always true and fires every frame. The caller still decides
/// whether to act (e.g. skip when already loading or there are no more pages)
/// inside [onLoadMore].
class PaginationScrollController extends ScrollController {
  PaginationScrollController({required this.onLoadMore, this.threshold = 200}) {
    addListener(_onScroll);
  }

  final VoidCallback onLoadMore;
  final double threshold;

  void _onScroll() {
    if (!hasClients) return;
    final p = position;
    if (p.maxScrollExtent <= 0) return;
    if (p.pixels < p.maxScrollExtent - threshold) return;
    onLoadMore();
  }

  @override
  void dispose() {
    removeListener(_onScroll);
    super.dispose();
  }
}
