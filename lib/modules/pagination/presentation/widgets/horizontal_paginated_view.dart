import 'package:flutter/material.dart';
import 'package:flutter_starter/modules/pagination/domain/domain.dart';
import 'package:flutter_starter/core/core.dart';
import 'package:skeletonizer/skeletonizer.dart';

class HorizontalPaginatedView extends StatelessWidget {
  const HorizontalPaginatedView({
    super.key,
    required this.children,
    required this.pagination,
    required this.scrollController,
    this.physics = const AlwaysScrollableScrollPhysics(),
    this.loadingWidget,
  });
  final List<Widget> children;
  final PaginationPage? pagination;
  final ScrollController scrollController;
  final ScrollPhysics physics;
  final Widget? loadingWidget;
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: physics,
      controller: scrollController,
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: .start,
        crossAxisAlignment: .center,
        children: [
          ...children,
          8.horizontalSpace,
          if (!(pagination?.next.isNullOrEmpty ?? true)) ...[
            Center(
              child: Padding(
                padding: .all(12.r),
                child:
                    loadingWidget ??
                    Skeletonizer.zone(child: Bone.square(size: 48.r)),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
