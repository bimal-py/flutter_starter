import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_starter/common/widgets/loading/loading.dart';
import 'package:flutter_starter/core/core.dart';

/// The blurred card shown by `context.showPopupLoading()`.
class PopupLoadingCard extends StatelessWidget {
  const PopupLoadingCard({super.key, this.message});

  final String? message;

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 1.5, sigmaY: 1.5),
      child: Center(
        child: Container(
          padding: EdgeInsets.all(24.r),
          constraints: BoxConstraints(minHeight: 150.r, minWidth: 150.r),
          decoration: BoxDecoration(
            color: context.colorScheme.surface,
            borderRadius: BorderRadius.circular(16.r),
            boxShadow: [
              BoxShadow(
                color: context.colorScheme.shadow.withValues(alpha: 0.12),
                blurRadius: 24.r,
                offset: Offset(0, 8.r),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              InkDrop(size: 30.r, color: context.colorScheme.primary),
              24.verticalSpace,
              Text(
                message ?? CommonStrings.loading,
                textAlign: TextAlign.center,
                style: context.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: context.colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
