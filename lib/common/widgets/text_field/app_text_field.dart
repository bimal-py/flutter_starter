import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_starter/common/widgets/text_field/text_field.dart';
import 'package:flutter_starter/core/core.dart';

/// A labelled [TextFormField] with the app's typing defaults
/// ([TextFieldDefaults]). Borders, fill and colours come from the theme's
/// `inputDecorationTheme`, so restyle the field there, not here.
class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    required this.label,
    this.controller,
    this.hint,
    this.helperText,
    this.errorText,
    this.keyboardType,
    this.textInputAction,
    this.textCapitalization = TextCapitalization.sentences,
    this.inputFormatters,
    this.validator,
    this.autofillHints,
    this.focusNode,
    this.prefix,
    this.suffix,
    this.obscureText = false,
    this.obscuringCharacter = '•',
    this.readOnly = false,
    this.enabled = true,
    this.isRequired = false,
    this.autofocus = false,
    this.maxLines = 1,
    this.maxLength,
    this.onChanged,
    this.onSubmitted,
    this.onTap,
  });

  final String label;
  final String? hint;
  final String? helperText;
  final String? errorText;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final TextCapitalization textCapitalization;
  final List<TextInputFormatter>? inputFormatters;
  final FormFieldValidator<String>? validator;
  final Iterable<String>? autofillHints;
  final FocusNode? focusNode;
  final Widget? prefix;
  final Widget? suffix;
  final bool obscureText;
  final String obscuringCharacter;
  final bool readOnly;
  final bool enabled;

  /// Appends a red '*' to the label to mark the field as compulsory.
  final bool isRequired;
  final bool autofocus;
  final int maxLines;
  final int? maxLength;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final lines = obscureText ? 1 : maxLines;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label.isNotEmpty) ...[
          RequiredLabel(label, isRequired: isRequired),
          8.verticalSpace,
        ],
        TextFormField(
          controller: controller,
          focusNode: focusNode,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          textCapitalization: obscureText
              ? TextCapitalization.none
              : TextFieldDefaults.capitalization(
                  keyboardType,
                  textCapitalization,
                ),
          inputFormatters: inputFormatters,
          validator: validator,
          autofillHints: autofillHints,
          autocorrect: TextFieldDefaults.autocorrect,
          enableSuggestions: TextFieldDefaults.enableSuggestions,
          obscureText: obscureText,
          obscuringCharacter: obscuringCharacter,
          readOnly: readOnly,
          enabled: enabled,
          autofocus: autofocus,
          maxLines: lines,
          textAlignVertical: TextFieldDefaults.alignVertical(lines),
          maxLength: maxLength,
          onChanged: onChanged,
          onFieldSubmitted: onSubmitted,
          onTap: onTap,
          onTapOutside: TextFieldDefaults.unfocusOnTapOutside,
          decoration: InputDecoration(
            hintText: hint,
            helperText: helperText,
            helperMaxLines: 3,
            errorText: errorText,
            counterText: '',
            prefixIcon: prefix,
            suffixIcon: suffix,
          ),
        ),
      ],
    );
  }
}
