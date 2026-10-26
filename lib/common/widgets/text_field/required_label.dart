import 'package:flutter/material.dart';
import 'package:flutter_starter/core/core.dart';

/// A form field label that appends a red '*' when the field is compulsory.
class RequiredLabel extends StatelessWidget {
  const RequiredLabel(
    this.label, {
    super.key,
    this.isRequired = true,
    this.style,
  });

  final String label;
  final bool isRequired;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    final base =
        style ??
        context.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500);
    return Text.rich(
      TextSpan(
        text: label,
        style: base,
        children: isRequired
            ? [
                TextSpan(
                  text: ' *',
                  style: base?.copyWith(color: context.colorScheme.error),
                ),
              ]
            : null,
      ),
    );
  }
}
