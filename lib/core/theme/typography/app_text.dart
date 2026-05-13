import 'package:flutter/material.dart';

/// Thin [Text] wrapper kept for API stability. The theme now carries per-
/// locale font family + scale via [LocalizedFonts], so no extra work is needed
/// here — prefer using TextTheme styles (e.g. `context.textTheme.bodyMedium`)
/// directly so the configured family/scale flows through automatically.
class AppText extends StatelessWidget {
  const AppText(
    this.data, {
    super.key,
    this.style,
    this.textAlign,
    this.textDirection,
    this.maxLines,
    this.overflow,
    this.softWrap,
    this.textScaler,
    this.semanticsLabel,
  });

  final String data;
  final TextStyle? style;
  final TextAlign? textAlign;
  final TextDirection? textDirection;
  final int? maxLines;
  final TextOverflow? overflow;
  final bool? softWrap;
  final TextScaler? textScaler;
  final String? semanticsLabel;

  @override
  Widget build(BuildContext context) => Text(
        data,
        style: style,
        textAlign: textAlign,
        textDirection: textDirection,
        maxLines: maxLines,
        overflow: overflow,
        softWrap: softWrap,
        textScaler: textScaler,
        semanticsLabel: semanticsLabel,
      );
}
