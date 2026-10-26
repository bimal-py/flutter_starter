import 'package:flutter/widgets.dart';

/// An [IndexedStack] that builds a child only when it is first shown, then
/// keeps it alive: each tab loads its data on the first visit, and switching
/// back never loads it again (pull-to-refresh does).
class LazyIndexedStack extends StatefulWidget {
  const LazyIndexedStack({
    super.key,
    required this.index,
    required this.children,
  });

  final int index;
  final List<Widget> children;

  @override
  State<LazyIndexedStack> createState() => _LazyIndexedStackState();
}

class _LazyIndexedStackState extends State<LazyIndexedStack> {
  final _shown = <int>{};

  @override
  Widget build(BuildContext context) {
    _shown.add(widget.index);
    return IndexedStack(
      index: widget.index,
      children: [
        for (var i = 0; i < widget.children.length; i++)
          _shown.contains(i) ? widget.children[i] : const SizedBox.shrink(),
      ],
    );
  }
}
