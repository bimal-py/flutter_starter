import 'package:flutter/material.dart';
import 'package:flutter_starter/core/core.dart';
import 'package:skeletonizer/skeletonizer.dart';

/// A shimmering list row (picture + two lines), for a next page loading
/// when the list's own row can't be used.
class ListRowSkeleton extends StatelessWidget {
  const ListRowSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Skeletonizer.zone(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        child: Row(
          children: [
            Bone.circle(size: 40.r),
            12.horizontalSpace,
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Bone.text(words: 3),
                  SizedBox(height: 6),
                  Bone.text(words: 2, fontSize: 12),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
