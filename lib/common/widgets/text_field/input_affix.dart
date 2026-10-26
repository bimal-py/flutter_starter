import 'package:flutter/material.dart';
import 'package:flutter_starter/core/core.dart';

/// Unit or currency beside a field's value ("Rs.", "%", "kg"), always
/// visible. Use as `prefix` / `suffix` with [InputAffix.constraints]:
/// `prefixText` / `suffixText` stay hidden until the field is focused or
/// filled.
class InputAffix extends StatelessWidget {
  const InputAffix(this.text, {super.key, this.leading = true});

  final String text;

  /// Before the value (prefix) or after it (suffix).
  final bool leading;

  /// No minimum size, so the affix hugs its text.
  static const BoxConstraints constraints = BoxConstraints();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: leading
          ? EdgeInsets.only(left: 10.w, right: 4.w)
          : EdgeInsets.only(left: 4.w, right: 10.w),
      child: Text(
        text,
        style: context.textTheme.bodyMedium?.copyWith(
          color: context.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}
