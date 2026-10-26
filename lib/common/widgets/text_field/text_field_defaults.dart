import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

/// Typing behaviour shared by every text field: no keyboard suggestions or
/// autocorrect, a capital first letter except where it would break the
/// value (email, numbers, phone, URLs, passwords), every word capitalised in
/// names and addresses ([TextInputType.name], [TextInputType.streetAddress]),
/// and the keyboard closing on a tap outside the field.
class TextFieldDefaults {
  TextFieldDefaults._();

  static const bool enableSuggestions = false;
  static const bool autocorrect = false;

  /// A box of more than one line starts its text (and hint) at the top.
  static TextAlignVertical? alignVertical(int? maxLines) =>
      maxLines == null || maxLines > 1 ? TextAlignVertical.top : null;

  /// `onTapOutside` of every field: tapping elsewhere closes the keyboard.
  static void unfocusOnTapOutside(PointerDownEvent _) =>
      FocusManager.instance.primaryFocus?.unfocus();

  static TextCapitalization capitalization(
    TextInputType? keyboardType, [
    TextCapitalization fallback = TextCapitalization.sentences,
  ]) {
    const raw = [
      TextInputType.emailAddress,
      TextInputType.number,
      TextInputType.phone,
      TextInputType.url,
      TextInputType.visiblePassword,
      TextInputType.datetime,
    ];
    const words = [TextInputType.name, TextInputType.streetAddress];
    final name = keyboardType?.toJson()['name'];
    bool among(List<TextInputType> types) =>
        types.any((t) => t.toJson()['name'] == name);
    if (among(raw)) return TextCapitalization.none;
    if (among(words)) return TextCapitalization.words;
    return fallback;
  }
}
