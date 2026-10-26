import 'package:flutter/material.dart';
import 'package:flutter_starter/common/common.dart';
import 'package:flutter_starter/core/core.dart';

/// The end of a paged list: shimmer rows while the next page loads, nothing
/// otherwise. Pass [indicator] to shimmer the list's own row instead.
class PaginationLoadingFooter extends StatelessWidget {
  const PaginationLoadingFooter({
    super.key,
    required this.isLoading,
    this.indicator,
    this.padding,
  });

  /// Usually `state.isLoadingMore`.
  final bool isLoading;

  final Widget? indicator;

  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    if (!isLoading) return const SizedBox.shrink();
    return Padding(
      padding: padding ?? EdgeInsets.symmetric(vertical: 8.r),
      child:
          indicator ??
          const Column(children: [ListRowSkeleton(), ListRowSkeleton()]),
    );
  }
}
