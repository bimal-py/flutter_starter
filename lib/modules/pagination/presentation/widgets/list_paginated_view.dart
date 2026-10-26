import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_starter/modules/pagination/domain/domain.dart';
import 'package:flutter_starter/core/core.dart';

class ListPaginatedView extends StatelessWidget {
  const ListPaginatedView({
    super.key,
    required this.pagination,
    this.loadingWidget,
    this.loadingWidgetCount,
    this.physics = const AlwaysScrollableScrollPhysics(),
    this.scrollController,
    this.scrollDirection = .vertical,
    this.reverse = false,
    this.primary,
    this.shrinkWrap = false,
    this.padding,
    required this.separatorBuilder,
    required this.itemBuilder,
    this.itemCount,
    this.addAutomaticKeepAlives = true,
    this.addRepaintBoundaries = true,
    this.addSemanticIndexes = true,
    this.semanticChildCount,
    this.dragStartBehavior = .start,
    this.keyboardDismissBehavior,
    this.restorationId,
    this.clipBehavior = .hardEdge,
    this.hitTestBehavior = .opaque,
  });
  final PaginationPage? pagination;
  final Widget? loadingWidget;
  final int? loadingWidgetCount;
  final ScrollPhysics physics;
  final ScrollController? scrollController;
  final Axis scrollDirection;
  final bool reverse;
  final bool? primary;
  final bool shrinkWrap;
  final EdgeInsetsGeometry? padding;
  final Widget Function(BuildContext, int) separatorBuilder;
  final Widget? Function(BuildContext, int) itemBuilder;
  final int? itemCount;
  final bool addAutomaticKeepAlives;
  final bool addRepaintBoundaries;
  final bool addSemanticIndexes;
  final int? semanticChildCount;
  final DragStartBehavior dragStartBehavior;
  final ScrollViewKeyboardDismissBehavior? keyboardDismissBehavior;
  final String? restorationId;
  final Clip clipBehavior;
  final HitTestBehavior hitTestBehavior;
  @override
  Widget build(BuildContext context) {
    final hasNext = !(pagination?.next.isNullOrEmpty ?? true);

    final totalCount = hasNext
        ? (itemCount ?? 0) + (loadingWidgetCount ?? 0)
        : itemCount;
    return ListView.separated(
      separatorBuilder: separatorBuilder,
      physics: physics,
      scrollDirection: scrollDirection,
      controller: scrollController,
      reverse: reverse,
      primary: primary,
      shrinkWrap: shrinkWrap,
      padding: padding,
      itemCount: totalCount ?? 0,
      addAutomaticKeepAlives: addAutomaticKeepAlives,
      addRepaintBoundaries: addRepaintBoundaries,
      addSemanticIndexes: addSemanticIndexes,
      dragStartBehavior: dragStartBehavior,
      keyboardDismissBehavior: keyboardDismissBehavior,
      restorationId: restorationId,
      clipBehavior: clipBehavior,
      hitTestBehavior: hitTestBehavior,
      itemBuilder: (context, index) {
        if (index < (itemCount ?? 0)) {
          return itemBuilder(context, index);
        }
        return loadingWidget ?? SizedBox.shrink();
      },
    );
  }
}
