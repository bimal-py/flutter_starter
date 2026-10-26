import 'package:flutter/material.dart';
import 'package:flutter_starter/core/core.dart';

/// Wraps a form control that has no error slot of its own (a dropdown, a
/// picker, a chip group) and shows [error] beneath it when set.
class FieldWithError extends StatelessWidget {
  const FieldWithError({super.key, required this.child, this.error});

  final Widget child;
  final String? error;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        child,
        if (error != null) ...[
          6.verticalSpace,
          Text(
            error!,
            style: context.textTheme.bodySmall?.copyWith(
              color: context.colorScheme.error,
            ),
          ),
        ],
      ],
    );
  }
}
