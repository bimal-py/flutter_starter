import 'package:flutter/material.dart';
import 'package:flutter_starter/common/common.dart';
import 'package:flutter_starter/modules/pagination/domain/domain.dart';

class CustomPaginatedListView extends StatelessWidget {
  const CustomPaginatedListView({
    required this.data,
    required this.itemBuilder,
    super.key,
    required this.pagination,
    required this.scrollController,
    this.separator = const SizedBox.shrink(),
    this.separatorHeight,
    this.physics = const AlwaysScrollableScrollPhysics(),
    this.shrinkWrap = false,
  });
  final List<dynamic> data;
  final IndexedWidgetBuilder itemBuilder;
  final PaginationPage pagination;
  final ScrollController scrollController;
  final Widget separator;
  final double? separatorHeight;
  final ScrollPhysics physics;
  final bool shrinkWrap;
  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: shrinkWrap,
      physics: physics,
      controller: scrollController,
      separatorBuilder: (context, index) {
        return separatorHeight == null
            ? separator
            : SizedBox(height: separatorHeight);
      },
      itemCount: data.length + 1,
      itemBuilder: (context, index) {
        if (index == data.length) {
          return pagination.next == ""
              ? const SizedBox.shrink()
              : const ListRowSkeleton();
        } else {
          return itemBuilder(context, index);
        }
      },
    );
  }
}
